#!/usr/bin/env python3
"""
Test script for Ollama Qwen 7B client
Tests both sync and async functionality
"""

import asyncio
import time
from ollama_client import create_client, create_async_client, OllamaConfig


def test_sync_client():
    """Test synchronous client functionality"""
    print("=== Testing Sync Client ===")
    
    # Create client
    client = create_client()
    
    # Health check
    print("1. Health check...")
    if not client.health_check():
        print("ERROR: Ollama service is not running")
        return False
    print("SUCCESS: Service is running")
    
    # List models
    print("2. Listing available models...")
    try:
        models = client.list_models()
        print(f"Available models: {len(models)}")
        for model in models:
            print(f"  - {model.get('name', 'Unknown')}")
    except Exception as e:
        print(f"ERROR: Failed to list models: {e}")
        return False
    
    # Test generation
    print("3. Testing text generation...")
    try:
        start_time = time.time()
        result = client.generate("What is artificial intelligence?", temperature=0.7)
        end_time = time.time()
        
        response = result.get('response', 'No response')
        print(f"Response (took {end_time - start_time:.2f}s):")
        print(f"  {response[:200]}...")
        
    except Exception as e:
        print(f"ERROR: Generation failed: {e}")
        return False
    
    # Test chat
    print("4. Testing chat interface...")
    try:
        messages = [
            {"role": "user", "content": "Hello! Can you help me with Python programming?"}
        ]
        start_time = time.time()
        result = client.chat(messages)
        end_time = time.time()
        
        response = result.get('message', {}).get('content', 'No response')
        print(f"Chat response (took {end_time - start_time:.2f}s):")
        print(f"  {response[:200]}...")
        
    except Exception as e:
        print(f"ERROR: Chat failed: {e}")
        return False
    
    # Test streaming
    print("5. Testing streaming generation...")
    try:
        print("Stream response:")
        for chunk in client.generate_stream("Count from 1 to 5"):
            if chunk.get('response'):
                print(chunk['response'], end='', flush=True)
            if chunk.get('done'):
                break
        print()  # New line
        
    except Exception as e:
        print(f"ERROR: Streaming failed: {e}")
        return False
    
    print("SUCCESS: All sync tests passed!")
    return True


async def test_async_client():
    """Test asynchronous client functionality"""
    print("\n=== Testing Async Client ===")
    
    try:
        async with create_async_client() as client:
            # Test generation
            print("1. Testing async generation...")
            start_time = time.time()
            result = await client.generate("What is machine learning?", temperature=0.7)
            end_time = time.time()
            
            response = result.get('response', 'No response')
            print(f"Async response (took {end_time - start_time:.2f}s):")
            print(f"  {response[:200]}...")
            
            # Test chat
            print("2. Testing async chat...")
            messages = [
                {"role": "user", "content": "Explain quantum computing in simple terms"}
            ]
            start_time = time.time()
            result = await client.chat(messages)
            end_time = time.time()
            
            response = result.get('message', {}).get('content', 'No response')
            print(f"Async chat response (took {end_time - start_time:.2f}s):")
            print(f"  {response[:200]}...")
            
            # Test async streaming
            print("3. Testing async streaming...")
            print("Async stream response:")
            async for chunk in client.generate_stream("List 3 benefits of AI"):
                if chunk.get('response'):
                    print(chunk['response'], end='', flush=True)
                if chunk.get('done'):
                    break
            print()  # New line
            
    except Exception as e:
        print(f"ERROR: Async test failed: {e}")
        return False
    
    print("SUCCESS: All async tests passed!")
    return True


def test_config():
    """Test configuration loading"""
    print("\n=== Testing Configuration ===")
    
    # Test default config
    config = OllamaConfig()
    print(f"Default config: {config.host}:{config.port}, model: {config.model}")
    
    # Test environment config
    config_env = OllamaConfig.from_env()
    print(f"Environment config: {config_env.host}:{config_env.port}, model: {config_env.model}")
    
    # Test custom config
    config_custom = OllamaConfig(host="127.0.0.1", port=8080, model="custom:model", timeout=30)
    print(f"Custom config: {config_custom.host}:{config_custom.port}, model: {config_custom.model}")
    
    print("SUCCESS: Configuration tests passed!")
    return True


def main():
    """Main test function"""
    print("Starting Ollama Client Tests")
    print("=" * 50)
    
    # Test configuration
    if not test_config():
        return 1
    
    # Test sync client
    if not test_sync_client():
        return 1
    
    # Test async client
    if not asyncio.run(test_async_client()):
        return 1
    
    print("\n" + "=" * 50)
    print("SUCCESS: All tests completed successfully!")
    print("Your Ollama Qwen 7B setup is working correctly.")
    return 0


if __name__ == "__main__":
    exit(main())
