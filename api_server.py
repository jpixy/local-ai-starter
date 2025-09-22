#!/usr/bin/env python3
"""
FastAPI server wrapper for Ollama client
Provides REST API interface for third-party applications
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import asyncio
import logging
from ollama_client import create_client, create_async_client, OllamaConfig

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# FastAPI app
app = FastAPI(
    title="Local AI API Server",
    description="REST API wrapper for Ollama Qwen 7B",
    version="1.0.0"
)

# CORS middleware for cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure according to your security needs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global client instance
ai_client = None


# Request/Response models
class GenerateRequest(BaseModel):
    prompt: str
    temperature: Optional[float] = 0.7
    top_p: Optional[float] = 0.9
    max_tokens: Optional[int] = 2048


class ChatMessage(BaseModel):
    role: str  # "user" or "assistant"
    content: str


class ChatRequest(BaseModel):
    messages: List[ChatMessage]
    temperature: Optional[float] = 0.7
    top_p: Optional[float] = 0.9
    max_tokens: Optional[int] = 2048


class GenerateResponse(BaseModel):
    response: str
    model: str
    created_at: Optional[str] = None
    done: bool = True


class ChatResponse(BaseModel):
    message: ChatMessage
    model: str
    created_at: Optional[str] = None
    done: bool = True


class HealthResponse(BaseModel):
    status: str
    message: str
    ollama_available: bool


class ModelsResponse(BaseModel):
    models: List[Dict[str, Any]]


@app.on_event("startup")
async def startup_event():
    """Initialize AI client on startup"""
    global ai_client
    try:
        ai_client = create_client()
        if not ai_client.health_check():
            logger.error("Ollama service is not available")
        else:
            logger.info("AI client initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize AI client: {e}")


@app.get("/", response_model=Dict[str, str])
async def root():
    """Root endpoint"""
    return {
        "message": "Local AI API Server",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    if ai_client is None:
        raise HTTPException(status_code=503, detail="AI client not initialized")
    
    ollama_available = ai_client.health_check()
    
    return HealthResponse(
        status="healthy" if ollama_available else "degraded",
        message="Service is running" if ollama_available else "Ollama service unavailable",
        ollama_available=ollama_available
    )


@app.get("/models", response_model=ModelsResponse)
async def list_models():
    """List available models"""
    if ai_client is None:
        raise HTTPException(status_code=503, detail="AI client not initialized")
    
    try:
        models = ai_client.list_models()
        return ModelsResponse(models=models)
    except Exception as e:
        logger.error(f"Failed to list models: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/generate", response_model=GenerateResponse)
async def generate_text(request: GenerateRequest):
    """Generate text from prompt"""
    if ai_client is None:
        raise HTTPException(status_code=503, detail="AI client not initialized")
    
    try:
        kwargs = {}
        if request.temperature is not None:
            kwargs['temperature'] = request.temperature
        if request.top_p is not None:
            kwargs['top_p'] = request.top_p
        if request.max_tokens is not None:
            kwargs['max_tokens'] = request.max_tokens
        
        result = ai_client.generate(request.prompt, **kwargs)
        
        return GenerateResponse(
            response=result.get('response', ''),
            model=result.get('model', 'unknown'),
            created_at=result.get('created_at'),
            done=result.get('done', True)
        )
    except Exception as e:
        logger.error(f"Generation failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/chat", response_model=ChatResponse)
async def chat_completion(request: ChatRequest):
    """Chat completion endpoint"""
    if ai_client is None:
        raise HTTPException(status_code=503, detail="AI client not initialized")
    
    try:
        # Convert Pydantic models to dict
        messages = [{"role": msg.role, "content": msg.content} for msg in request.messages]
        
        kwargs = {}
        if request.temperature is not None:
            kwargs['temperature'] = request.temperature
        if request.top_p is not None:
            kwargs['top_p'] = request.top_p
        if request.max_tokens is not None:
            kwargs['max_tokens'] = request.max_tokens
        
        result = ai_client.chat(messages, **kwargs)
        
        response_message = result.get('message', {})
        
        return ChatResponse(
            message=ChatMessage(
                role=response_message.get('role', 'assistant'),
                content=response_message.get('content', '')
            ),
            model=result.get('model', 'unknown'),
            created_at=result.get('created_at'),
            done=result.get('done', True)
        )
    except Exception as e:
        logger.error(f"Chat completion failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/generate/stream")
async def generate_stream(request: GenerateRequest):
    """Stream generate text (Server-Sent Events)"""
    if ai_client is None:
        raise HTTPException(status_code=503, detail="AI client not initialized")
    
    from fastapi.responses import StreamingResponse
    import json
    
    def generate():
        try:
            kwargs = {}
            if request.temperature is not None:
                kwargs['temperature'] = request.temperature
            if request.top_p is not None:
                kwargs['top_p'] = request.top_p
            if request.max_tokens is not None:
                kwargs['max_tokens'] = request.max_tokens
            
            for chunk in ai_client.generate_stream(request.prompt, **kwargs):
                yield f"data: {json.dumps(chunk)}\n\n"
                if chunk.get('done'):
                    break
        except Exception as e:
            error_chunk = {"error": str(e), "done": True}
            yield f"data: {json.dumps(error_chunk)}\n\n"
    
    return StreamingResponse(generate(), media_type="text/plain")


if __name__ == "__main__":
    import uvicorn
    
    # Configuration
    host = "0.0.0.0"
    port = 8000
    
    print(f"Starting Local AI API Server at http://{host}:{port}")
    print("API Documentation: http://localhost:8000/docs")
    
    uvicorn.run(app, host=host, port=port, log_level="info")
