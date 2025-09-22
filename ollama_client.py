"""
Ollama Qwen 7B Python Client
Provides sync and async interfaces to access local Ollama service
"""

import asyncio
import json
import logging
import os
from typing import Dict, List, Optional, AsyncGenerator, Generator
import requests
import aiohttp
from dataclasses import dataclass


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class OllamaConfig:
    """Ollama configuration class"""
    host: str = "localhost"
    port: int = 11434
    model: str = "qwen2.5:7b"
    timeout: int = 60  # Maximum 60 seconds as per requirements
    
    @classmethod
    def from_env(cls) -> 'OllamaConfig':
        """Create config from environment variables"""
        return cls(
            host=os.getenv("OLLAMA_HOST", "localhost"),
            port=int(os.getenv("OLLAMA_PORT", "11434")),
            model=os.getenv("OLLAMA_MODEL", "qwen2.5:7b"),
            timeout=int(os.getenv("OLLAMA_TIMEOUT", "60"))
        )
    
    @property
    def base_url(self) -> str:
        return f"http://{self.host}:{self.port}"


class OllamaClient:
    """Ollama synchronous client"""
    
    def __init__(self, config: Optional[OllamaConfig] = None):
        self.config = config or OllamaConfig.from_env()
        self.session = requests.Session()
        self.session.timeout = self.config.timeout
    
    def generate(self, prompt: str, **kwargs) -> Dict:
        """
        Generate single response
        
        Args:
            prompt: Input prompt
            **kwargs: Additional parameters (temperature, top_p, max_tokens, etc.)
            
        Returns:
            Dict: Response dictionary
        """
        url = f"{self.config.base_url}/api/generate"
        
        payload = {
            "model": self.config.model,
            "prompt": prompt,
            "stream": False,
            **kwargs
        }
        
        try:
            response = self.session.post(url, json=payload)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            logger.error(f"Generate request failed: {e}")
            raise
    
    def generate_stream(self, prompt: str, **kwargs) -> Generator[Dict, None, None]:
        """
        Stream generate response
        
        Args:
            prompt: Input prompt
            **kwargs: Additional parameters
            
        Yields:
            Dict: Each response chunk
        """
        url = f"{self.config.base_url}/api/generate"
        
        payload = {
            "model": self.config.model,
            "prompt": prompt,
            "stream": True,
            **kwargs
        }
        
        try:
            response = self.session.post(url, json=payload, stream=True)
            response.raise_for_status()
            
            for line in response.iter_lines(decode_unicode=True):
                if line:
                    try:
                        data = json.loads(line)
                        yield data
                    except json.JSONDecodeError:
                        continue
                        
        except requests.RequestException as e:
            logger.error(f"Stream generate request failed: {e}")
            raise
    
    def chat(self, messages: List[Dict[str, str]], **kwargs) -> Dict:
        """
        Chat interface
        
        Args:
            messages: Message list, format: [{"role": "user", "content": "..."}]
            **kwargs: Additional parameters
            
        Returns:
            Dict: Chat response
        """
        url = f"{self.config.base_url}/api/chat"
        
        payload = {
            "model": self.config.model,
            "messages": messages,
            "stream": False,
            **kwargs
        }
        
        try:
            response = self.session.post(url, json=payload)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            logger.error(f"Chat request failed: {e}")
            raise
    
    def list_models(self) -> List[Dict]:
        """Get available models list"""
        url = f"{self.config.base_url}/api/tags"
        
        try:
            response = self.session.get(url)
            response.raise_for_status()
            return response.json().get("models", [])
        except requests.RequestException as e:
            logger.error(f"List models request failed: {e}")
            raise
    
    def health_check(self) -> bool:
        """Health check"""
        try:
            response = self.session.get(f"{self.config.base_url}/api/tags")
            return response.status_code == 200
        except requests.RequestException:
            return False


class AsyncOllamaClient:
    """Ollama asynchronous client"""
    
    def __init__(self, config: Optional[OllamaConfig] = None):
        self.config = config or OllamaConfig.from_env()
        self.session: Optional[aiohttp.ClientSession] = None
    
    async def __aenter__(self):
        self.session = aiohttp.ClientSession(
            timeout=aiohttp.ClientTimeout(total=self.config.timeout)
        )
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()
    
    async def generate(self, prompt: str, **kwargs) -> Dict:
        """Async generate single response"""
        if not self.session:
            raise RuntimeError("Please use async with statement or call create_session()")
        
        url = f"{self.config.base_url}/api/generate"
        
        payload = {
            "model": self.config.model,
            "prompt": prompt,
            "stream": False,
            **kwargs
        }
        
        try:
            async with self.session.post(url, json=payload) as response:
                response.raise_for_status()
                return await response.json()
        except aiohttp.ClientError as e:
            logger.error(f"Async generate request failed: {e}")
            raise
    
    async def generate_stream(self, prompt: str, **kwargs) -> AsyncGenerator[Dict, None]:
        """Async stream generate response"""
        if not self.session:
            raise RuntimeError("Please use async with statement or call create_session()")
        
        url = f"{self.config.base_url}/api/generate"
        
        payload = {
            "model": self.config.model,
            "prompt": prompt,
            "stream": True,
            **kwargs
        }
        
        try:
            async with self.session.post(url, json=payload) as response:
                response.raise_for_status()
                
                async for line in response.content:
                    line = line.decode('utf-8').strip()
                    if line:
                        try:
                            data = json.loads(line)
                            yield data
                        except json.JSONDecodeError:
                            continue
                            
        except aiohttp.ClientError as e:
            logger.error(f"Async stream generate request failed: {e}")
            raise
    
    async def chat(self, messages: List[Dict[str, str]], **kwargs) -> Dict:
        """Async chat interface"""
        if not self.session:
            raise RuntimeError("Please use async with statement or call create_session()")
        
        url = f"{self.config.base_url}/api/chat"
        
        payload = {
            "model": self.config.model,
            "messages": messages,
            "stream": False,
            **kwargs
        }
        
        try:
            async with self.session.post(url, json=payload) as response:
                response.raise_for_status()
                return await response.json()
        except aiohttp.ClientError as e:
            logger.error(f"Async chat request failed: {e}")
            raise
    
    async def create_session(self):
        """Manually create session (if not using async with)"""
        self.session = aiohttp.ClientSession(
            timeout=aiohttp.ClientTimeout(total=self.config.timeout)
        )
    
    async def close_session(self):
        """Manually close session"""
        if self.session:
            await self.session.close()
            self.session = None


def create_client(host: str = "localhost", port: int = 11434, model: str = "qwen2.5:7b") -> OllamaClient:
    """Convenience function: create sync client"""
    config = OllamaConfig(host=host, port=port, model=model)
    return OllamaClient(config)


def create_async_client(host: str = "localhost", port: int = 11434, model: str = "qwen2.5:7b") -> AsyncOllamaClient:
    """Convenience function: create async client"""
    config = OllamaConfig(host=host, port=port, model=model)
    return AsyncOllamaClient(config)


if __name__ == "__main__":
    # Quick test
    client = create_client()
    
    if client.health_check():
        print("SUCCESS Ollama service connection normal")
        
        # Test generation
        result = client.generate("Hello, please introduce yourself")
        print(f"Model response: {result.get('response', 'No response')}")
    else:
        print("ERROR Ollama service connection failed, please ensure service is running")