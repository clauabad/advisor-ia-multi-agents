terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Using local backend - state will be stored in terraform.tfstate in this directory
  # This is automatically gitignored for security
}

provider "aws" {
  region = var.aws_region
}

# Data source for current caller identity
data "aws_caller_identity" "current" {}

# ========================================
# Aurora Serverless v2 PostgreSQL Cluster
# ========================================

# Random password for database
resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Random suffix for names
resource "random_id" "suffix" {
  byte_length = 4
}

# Secrets Manager secret for database credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "advisor-aurora-credentials-${random_id.suffix.hex}"
  recovery_window_in_days = 0  # For development - immediate deletion

  tags = {
    Project = "advisor"
    Part    = "5"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "advisoradmin"
    password = random_password.db_password.result
  })
}

# Default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "aurora" {
  name       = "advisor-aurora-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Project = "advisor"
    Part    = "5"
  }
}

# Security group for Aurora
resource "aws_security_group" "aurora" {
  name        = "advisor-aurora-sg"
  description = "Security group for Advisor Aurora cluster"
  vpc_id      = data.aws_vpc.default.id

  # Allow PostgreSQL access from within VPC
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "advisor"
    Part    = "5"
  }
}

# -------------------------------------------------
# Service-linked role for RDS (fixes IAM error)
# -------------------------------------------------
resource "aws_iam_service_linked_role" "rds" {
  aws_service_name = "rds.amazonaws.com"
}

# Aurora Serverless v2 Cluster (PostgreSQL)
resource "aws_rds_cluster" "aurora" {
  depends_on = [
    aws_iam_service_linked_role.rds
  ]

  cluster_identifier = "advisor-aurora-cluster"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"   # required for Serverless v2
  engine_version     = "15.12"         # adjust if your region supports a different version

  database_name   = "advisor"
  master_username = "advisoradmin"
  master_password = random_password.db_password.result

  # Serverless v2 scaling configuration
  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  # Enable Data API (RDS Data Service)
  enable_http_endpoint = true

  # Networking
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  # Backup and maintenance
  backup_retention_period     = 1             # <= 1 day to respect free-tier restriction
  preferred_backup_window     = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  # Development settings
  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Project = "advisor"
    Part    = "5"
  }
}

# Aurora Serverless v2 Instance
resource "aws_rds_cluster_instance" "aurora" {
  identifier         = "advisor-aurora-instance-1"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  performance_insights_enabled = false  # Save costs in development

  tags = {
    Project = "advisor"
    Part    = "5"
  }
}

# ========================================
# IAM role for Lambda to access Aurora Data API
# ========================================

resource "aws_iam_role" "lambda_aurora_role" {
  name = "advisor-lambda-aurora-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = "advisor"
    Part    = "5"
  }
}

# IAM policy for Data API + Secrets + Logs
resource "aws_iam_role_policy" "lambda_aurora_policy" {
  name = "advisor-lambda-aurora-policy"
  role = aws_iam_role.lambda_aurora_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # RDS Data API access
      {
        Effect = "Allow"
        Action = [
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ]
        Resource = aws_rds_cluster.aurora.arn
      },
      # Secrets Manager (DB credentials)
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.db_credentials.arn
      },
      # CloudWatch Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

# Attach basic Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_aurora_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
