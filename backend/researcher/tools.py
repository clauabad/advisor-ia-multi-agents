"""
Tools for the Advisor Researcher agent
"""
import os
from typing import Dict, Any, List
from datetime import datetime, UTC
import httpx
from agents import function_tool
from tenacity import retry, stop_after_attempt, wait_exponential

# Configuration from environment
ADVISOR_API_ENDPOINT = os.getenv("ADVISOR_API_ENDPOINT")
ADVISOR_API_KEY = os.getenv("ADVISOR_API_KEY")


def _ingest(document: Dict[str, Any]) -> Dict[str, Any]:
    """Internal function to make the actual API call."""
    with httpx.Client() as client:
        response = client.post(
            ADVISOR_API_ENDPOINT,
            json=document,
            headers={"x-api-key": ADVISOR_API_KEY},
            timeout=30.0
        )
        response.raise_for_status()
        return response.json()


@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=10)
)
def ingest_with_retries(document: Dict[str, Any]) -> Dict[str, Any]:
    """Ingest with retry logic for SageMaker cold starts."""
    return _ingest(document)


@function_tool
def ingest_financial_document(topic: str, analysis: str) -> Dict[str, Any]:
    """
    Ingest a financial document into the Advisor knowledge base.
    
    Args:
        topic: The topic or subject of the analysis (e.g., "AAPL Stock Analysis", "Retirement Planning Guide")
        analysis: Detailed analysis or advice with specific data and insights
    
    Returns:
        Dictionary with success status and document ID
    """
    if not ADVISOR_API_ENDPOINT or not ADVISOR_API_KEY:
        return {
            "success": False,
            "error": "Advisor API not configured. Running in local mode."
        }
    
    document = {
        "text": analysis,
        "metadata": {
            "topic": topic,
            "timestamp": datetime.now(UTC).isoformat()
        }
    }
    
    try:
        result = ingest_with_retries(document)
        return {
            "success": True,
            "document_id": result.get("document_id"),  # Changed from documentId
            "message": f"Successfully ingested analysis for {topic}"
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }

@function_tool
def tavily_search(query: str, max_results: int = 5) -> List[Dict[str, Any]]:
    """
    Search the web for current information using Tavily API.
    
    Args:
        query: Search query (e.g., "Tesla stock price 2026", "Apple earnings report")
        max_results: Maximum number of results to return (default 5)
    
    Returns:
        List of search results with title, url, and content snippets
    """
    tavily_api_key = os.getenv("TAVILY_API_KEY")
    
    if not tavily_api_key:
        return [{"error": "Tavily API key not configured"}]
    
    try:
        with httpx.Client() as client:
            response = client.post(
                "https://api.tavily.com/search",
                json={
                    "api_key": tavily_api_key,
                    "query": query,
                    "max_results": max_results,
                    "search_depth": "basic",
                    "include_answer": True,
                    "include_raw_content": False,
                },
                timeout=30.0
            )
            response.raise_for_status()
            data = response.json()
            
            results = []
            if data.get("answer"):
                results.append({
                    "type": "answer",
                    "content": data["answer"]
                })
            
            for result in data.get("results", []):
                results.append({
                    "title": result.get("title", ""),
                    "url": result.get("url", ""),
                    "content": result.get("content", ""),
                    "score": result.get("score", 0)
                })
            
            return results
            
    except Exception as e:
        return [{"error": f"Search failed: {str(e)}"}]