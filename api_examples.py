#!/usr/bin/env python3
"""
REST API examples for Ollama Qwen 7B
Demonstrates direct HTTP API usage without Python client library
"""

import json
import requests
import time
from typing import Dict, Any
import asyncio
import aiohttp


# Ollama API endpoints
BASE_URL = "http://localhost:11434"
ENDPOINTS = {
    "generate": f"{BASE_URL}/api/generate",
    "chat": f"{BASE_URL}/api/chat", 
    "tags": f"{BASE_URL}/api/tags",
    "pull": f"{BASE_URL}/api/pull",
    "push": f"{BASE_URL}/api/push",
    "create": f"{BASE_URL}/api/create",
    "delete": f"{BASE_URL}/api/delete",
    "copy": f"{BASE_URL}/api/copy",
    "show": f"{BASE_URL}/api/show"
}


def test_health_check() -> bool:
    """Test if Ollama service is running"""
    try:
        response = requests.get(ENDPOINTS["tags"], timeout=5)
        return response.status_code == 200
    except requests.RequestException:
        return False


def list_models() -> Dict[str, Any]:
    """Get list of available models via REST API"""
    try:
        response = requests.get(ENDPOINTS["tags"])
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        return {"error": str(e)}


def generate_text(prompt: str, model: str = "qwen:7b", stream: bool = False) -> Dict[str, Any]:
    """Generate text via REST API"""
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": stream
    }
    
    try:
        response = requests.post(ENDPOINTS["generate"], json=payload)
        response.raise_for_status()
        
        if stream:
            # Handle streaming response
            full_response = ""
            for line in response.iter_lines(decode_unicode=True):
                if line:
                    try:
                        chunk = json.loads(line)
                        if chunk.get("response"):
                            full_response += chunk["response"]
                        if chunk.get("done"):
                            return {"response": full_response, "done": True}
                    except json.JSONDecodeError:
                        continue
            return {"response": full_response, "done": True}
        else:
            return response.json()
            
    except requests.RequestException as e:
        return {"error": str(e)}


def chat_conversation(messages: list, model: str = "qwen:7b") -> Dict[str, Any]:
    """Chat via REST API"""
    payload = {
        "model": model,
        "messages": messages,
        "stream": False
    }
    
    try:
        response = requests.post(ENDPOINTS["chat"], json=payload)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        return {"error": str(e)}


async def async_generate_text(prompt: str, model: str = "qwen:7b") -> Dict[str, Any]:
    """Async generate text via REST API"""
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False
    }
    
    try:
        async with aiohttp.ClientSession() as session:
            async with session.post(ENDPOINTS["generate"], json=payload) as response:
                response.raise_for_status()
                return await response.json()
    except aiohttp.ClientError as e:
        return {"error": str(e)}


def parallel_requests_demo():
    """Demonstrate parallel API calls"""
    import concurrent.futures
    import threading
    
    prompts = [
        "What is artificial intelligence?",
        "Explain machine learning",
        "What is deep learning?",
        "How does neural network work?",
        "What is natural language processing?"
    ]
    
    print("=== Parallel REST API Calls Demo ===")
    start_time = time.time()
    
    # Using ThreadPoolExecutor for parallel requests
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
        # Submit all requests
        future_to_prompt = {
            executor.submit(generate_text, prompt): prompt 
            for prompt in prompts
        }
        
        results = []
        for future in concurrent.futures.as_completed(future_to_prompt):
            prompt = future_to_prompt[future]
            try:
                result = future.result()
                response_text = result.get('response', 'No response')[:100] + "..."
                results.append({
                    "prompt": prompt,
                    "response": response_text,
                    "thread": threading.current_thread().name
                })
                print(f"Completed: {prompt[:30]}... -> {response_text}")
            except Exception as e:
                print(f"Error with prompt '{prompt}': {e}")
    
    end_time = time.time()
    print(f"\nParallel execution completed in {end_time - start_time:.2f} seconds")
    print(f"Processed {len(results)} requests")
    
    return results


async def async_parallel_demo():
    """Demonstrate async parallel API calls"""
    prompts = [
        "What is quantum computing?",
        "Explain blockchain technology",
        "What is cloud computing?"
    ]
    
    print("\n=== Async Parallel API Calls Demo ===")
    start_time = time.time()
    
    # Create tasks for parallel execution
    tasks = [async_generate_text(prompt) for prompt in prompts]
    
    # Wait for all tasks to complete
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    end_time = time.time()
    
    for i, (prompt, result) in enumerate(zip(prompts, results)):
        if isinstance(result, Exception):
            print(f"Error with prompt {i+1}: {result}")
        else:
            response_text = result.get('response', 'No response')[:100] + "..."
            print(f"Async task {i+1}: {prompt[:30]}... -> {response_text}")
    
    print(f"\nAsync parallel execution completed in {end_time - start_time:.2f} seconds")
    return results


def curl_examples():
    """Print curl command examples for direct API usage"""
    print("\n=== cURL Examples for Direct API Usage ===")
    
    print("\n1. Health Check:")
    print("curl http://localhost:11434/api/tags")
    
    print("\n2. Generate Text:")
    print("""curl -X POST http://localhost:11434/api/generate \\
  -H "Content-Type: application/json" \\
  -d '{
    "model": "qwen:7b",
    "prompt": "What is artificial intelligence?",
    "stream": false
  }'""")
    
    print("\n3. Chat:")
    print("""curl -X POST http://localhost:11434/api/chat \\
  -H "Content-Type: application/json" \\
  -d '{
    "model": "qwen:7b",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ]
  }'""")
    
    print("\n4. Streaming Response:")
    print("""curl -X POST http://localhost:11434/api/generate \\
  -H "Content-Type: application/json" \\
  -d '{
    "model": "qwen:7b",
    "prompt": "Tell me a story",
    "stream": true
  }'""")


def main():
    """Main demonstration function"""
    print("Ollama REST API Examples")
    print("=" * 50)
    
    # Health check
    if not test_health_check():
        print("ERROR: Ollama service is not running on http://localhost:11434")
        print("Please start Ollama service first: ollama serve")
        return 1
    
    print("SUCCESS: Ollama service is running")
    
    # List models
    print("\n1. Available Models:")
    models = list_models()
    if "error" in models:
        print(f"Error: {models['error']}")
    else:
        for model in models.get("models", []):
            print(f"  - {model.get('name', 'Unknown')}")
    
    # Simple generation
    print("\n2. Simple Text Generation:")
    result = generate_text("What is machine learning in one sentence?")
    if "error" in result:
        print(f"Error: {result['error']}")
    else:
        print(f"Response: {result.get('response', 'No response')}")
    
    # Chat example
    print("\n3. Chat Example:")
    messages = [{"role": "user", "content": "Hello! Can you help me with Python?"}]
    chat_result = chat_conversation(messages)
    if "error" in chat_result:
        print(f"Error: {chat_result['error']}")
    else:
        response = chat_result.get('message', {}).get('content', 'No response')
        print(f"Chat Response: {response}")
    
    # Parallel requests demo
    parallel_requests_demo()
    
    # Async parallel demo
    print("\nRunning async parallel demo...")
    asyncio.run(async_parallel_demo())
    
    # Show curl examples
    curl_examples()
    
    print("\n" + "=" * 50)
    print("REST API examples completed!")
    return 0


if __name__ == "__main__":
    exit(main())
