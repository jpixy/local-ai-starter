# Local AI Starter with Ollama and Qwen 7B

A complete solution for running Qwen 7B model locally using Ollama with Python client library integration.

## Features

- **Easy Setup**: Automated installation script for Ollama and Qwen 7B
- **Python Integration**: Both synchronous and asynchronous client libraries  
- **Secure Configuration**: Environment-based configuration management
- **Comprehensive Testing**: Full test suite with examples
- **Production Ready**: Timeout controls, error handling, and logging

## Quick Start

### Prerequisites

- Linux, macOS, or Windows
- Python 3.8+
- 8GB+ RAM (16GB+ recommended)
- 10GB+ available disk space
- Stable internet connection

### Installation

#### Option 1: Using Poetry (Recommended)

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd local-ai-starter
```

2. **Setup with Poetry**
```bash
# Install Poetry if not already installed
curl -sSL https://install.python-poetry.org | python3 -

# Install dependencies (Poetry will automatically create and manage virtual environment)
poetry install

# Or use automated setup script
chmod +x poetry_setup.sh
./poetry_setup.sh

# Or use Makefile
make setup
```

3. **Setup Ollama and Qwen 2.5 7B**
```bash
./setup_ollama.sh
# or
make run-ollama
```

4. **Configure environment**
```bash
cp .env.example .env
# Edit .env file as needed (default model is qwen2.5:7b)
```

5. **Test installation**
```bash
poetry run python test_client.py
# or
make test
```

#### Option 2: Using pip (Traditional - Not Recommended)

**Note**: Poetry is the recommended approach as it provides better dependency management.

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd local-ai-starter
```

2. **Setup with pip**
```bash
python -m venv venv
source venv/bin/activate  # Linux/macOS
# or venv\Scripts\activate  # Windows

pip install -r requirements.txt
```

3. **Run setup script**
```bash
chmod +x setup_ollama.sh
./setup_ollama.sh
```

4. **Configure environment**
```bash
cp .env.example .env
# Edit .env file as needed (default model is qwen2.5:7b)
```

5. **Test installation**
```bash
python test_client.py
```

## Usage

### Basic Example

```python
from ollama_client import create_client

# Create client
client = create_client()

# Health check
if client.health_check():
    # Generate text
    response = client.generate("What is artificial intelligence?")
    print(response['response'])
```

### Chat Interface

```python
# Chat conversation
messages = [
    {"role": "user", "content": "Hello! Can you help me with Python?"}
]

response = client.chat(messages)
print(response['message']['content'])
```

### Streaming Response

```python
# Stream generation for real-time response
for chunk in client.generate_stream("Explain machine learning"):
    if chunk.get('response'):
        print(chunk['response'], end='', flush=True)
    if chunk.get('done'):
        break
```

### Async Usage

```python
import asyncio
from ollama_client import create_async_client

async def async_example():
    async with create_async_client() as client:
        result = await client.generate("What is deep learning?")
        print(result['response'])

asyncio.run(async_example())
```

## Configuration

### Environment Variables

Configure via `.env` file:

```bash
OLLAMA_HOST=localhost
OLLAMA_PORT=11434
OLLAMA_MODEL=qwen:7b
OLLAMA_TIMEOUT=60
```

### Custom Configuration

```python
from ollama_client import OllamaConfig, OllamaClient

config = OllamaConfig(
    host="192.168.1.100",
    port=11434,
    model="qwen:7b",
    timeout=30
)

client = OllamaClient(config)
```

## API Reference

### OllamaClient

- `generate(prompt, **kwargs)` - Generate single response
- `generate_stream(prompt, **kwargs)` - Stream response generation
- `chat(messages, **kwargs)` - Chat interface
- `list_models()` - Get available models
- `health_check()` - Service health check

### AsyncOllamaClient

Same methods as OllamaClient but with async/await support.

## Development

### Using Poetry (Recommended)

```bash
# Activate virtual environment
poetry shell

# Add new dependency
poetry add requests

# Add development dependency
poetry add --group dev pytest

# Run commands in virtual environment
poetry run python test_client.py

# Install with optional features
poetry install --extras "data api"
```

### Using Makefile

```bash
# Show available commands
make help

# Setup project
make setup

# Run tests
make test

# Format code
make format

# Run linting
make lint
```

## Testing

Run the test suite:

**With Poetry:**
```bash
poetry run python test_client.py
# or
make test
```

**With pip:**
```bash
python test_client.py
```

Tests include:
- Service connectivity
- Model listing
- Text generation
- Chat interface
- Streaming responses
- Async functionality

## Documentation

- [中文文档](docs/zh/README.md) - Chinese documentation
- **[快速部署指南](docs/zh/quick-start.md)** - Quick deployment and testing guide
- [安装指南](docs/zh/installation.md) - Installation guide
- [第三方集成指南](docs/zh/third-party-integration.md) - Third-party integration guide

## Troubleshooting

### Service Not Running

```bash
# Check if Ollama is running
ps aux | grep ollama

# Start service manually
ollama serve
```

### Model Download Issues

```bash
# Re-download model
ollama rm qwen:7b
ollama pull qwen:7b
```

### Performance Issues

- Ensure sufficient RAM available
- Check system load
- Adjust timeout settings
- Consider using smaller models

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
- Create an issue in this repository
- Check the [Chinese documentation](docs/zh/) for detailed guides
- Review the test scripts for usage examples

## Acknowledgments

- [Ollama](https://ollama.ai/) for the excellent local LLM runtime
- [Qwen](https://github.com/QwenLM/Qwen) for the language model
- Contributors and community feedback