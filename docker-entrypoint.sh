#!/bin/bash

# Docker entrypoint script
echo "Starting Local AI Service..."

# Start Ollama service in background
echo "Starting Ollama service..."
ollama serve &

# Wait for Ollama to be ready
echo "Waiting for Ollama to start..."
sleep 10

# Pull Qwen model if not exists
echo "Checking for Qwen 7B model..."
if ! ollama list | grep -q "qwen:7b"; then
    echo "Downloading Qwen 7B model..."
    ollama pull qwen:7b
fi

# Start API server
echo "Starting API server..."
python api_server.py
