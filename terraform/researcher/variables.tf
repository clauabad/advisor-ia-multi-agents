variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "openai_api_key" {
  description = "OpenAI API key for the researcher agent"
  type        = string
  sensitive   = true
}

variable "advisor_api_endpoint" {
  description = "Advisor API endpoint"
  type        = string
}

variable "advisor_api_key" {
  description = "Advisor API key from"
  type        = string
  sensitive   = true
}

variable "scheduler_enabled" {
  description = "Enable automated research scheduler"
  type        = bool
  default     = false
}

variable "tavily_api_key" {
  description = "Tavily API key"
  type        = string
  sensitive   = true
}