#!/bin/bash

# Ollama installation and configuration script
echo "=== Starting Ollama Installation ==="

# Check if Ollama is already installed
if command -v ollama &> /dev/null; then
    echo "Ollama is already installed, version: $(ollama --version)"
else
    echo "Installing Ollama..."
    # Use official installation script
    curl -fsSL https://ollama.ai/install.sh | sh
    
    # Check if installation was successful
    if command -v ollama &> /dev/null; then
        echo "SUCCESS Ollama installation completed!"
    else
        echo "ERROR Ollama installation failed, please check network connection or install manually"
        exit 1
    fi
fi

echo "=== Starting Ollama Service ==="
# Start Ollama service in background
ollama serve &
sleep 5

echo "=== Downloading Qwen 7B Model ==="
# Download qwen2.5:7b model
echo "Downloading Qwen 2.5 7B model, this may take several minutes..."
ollama pull qwen2.5:7b

# Verify model download success
if ollama list | grep -q "qwen2.5:7b"; then
    echo "SUCCESS Qwen 2.5 7B model downloaded successfully!"
else
    echo "ERROR Qwen 2.5 7B model download failed"
    exit 1
fi

echo "=== Testing Model Execution ==="
# Simple model test
echo "Testing model response..."
echo "Hello" | ollama run qwen2.5:7b

echo "=== Ollama and Qwen 2.5 7B Setup Complete! ==="
echo "API service running at: http://localhost:11434"
echo "You can interact with the model using:"
echo "  ollama run qwen2.5:7b"
echo "Or call via API endpoint: http://localhost:11434/api/generate"
