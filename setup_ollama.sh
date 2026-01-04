#!/bin/bash

# Ollama installation and configuration script
# Downloads only qwen2.5:7b by default (recommended for media_organizer)

set -e

echo "=== Ollama Installation Script ==="
echo ""

# Check if Ollama is already installed
if command -v ollama &> /dev/null; then
    echo "✓ Ollama is already installed"
    ollama --version 2>/dev/null || echo "  (version unknown)"
else
    echo "Installing Ollama..."
    curl -fsSL https://ollama.ai/install.sh | sh
    
    if command -v ollama &> /dev/null; then
        echo "✓ Ollama installation completed!"
    else
        echo "✗ Ollama installation failed"
        echo "  Please check network connection or install manually"
        exit 1
    fi
fi

echo ""
echo "=== Starting Ollama Service ==="

# Stop any existing ollama process
pkill ollama 2>/dev/null || true
sleep 1

# Start Ollama service
ollama serve &
OLLAMA_PID=$!
sleep 3

# Check if started
if ! pgrep -x "ollama" > /dev/null; then
    echo "✗ Failed to start Ollama"
    exit 1
fi
echo "✓ Ollama started (PID: $OLLAMA_PID)"

echo ""
echo "=== Downloading Qwen 2.5 7B Model (4.7 GB) ==="
echo "This is the recommended model for media_organizer"
echo ""

ollama pull qwen2.5:7b

if ollama list | grep -q "qwen2.5:7b"; then
    echo ""
    echo "✓ qwen2.5:7b model downloaded successfully!"
else
    echo "✗ qwen2.5:7b model download failed"
    exit 1
fi

echo ""
echo "=== Testing Model ==="
response=$(curl -s http://localhost:11434/api/generate \
    -d '{"model": "qwen2.5:7b", "prompt": "Say hi", "stream": false}' \
    | grep -o '"response":"[^"]*"' | head -1)

if [ -n "$response" ]; then
    echo "✓ Model test passed"
else
    echo "⚠ Model test returned empty response"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Installed models:"
ollama list
echo ""

SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")

echo "API service running at:"
echo "  - Local:    http://localhost:11434"
echo "  - External: http://$SERVER_IP:11434"
echo ""
echo "Quick test:"
echo "  curl http://localhost:11434/api/generate -d '{\"model\": \"qwen2.5:7b\", \"prompt\": \"Hello\", \"stream\": false}'"
echo ""
echo "Optional: Download larger models for better quality:"
echo "  ollama pull qwen2.5:32b  # 19 GB"
echo "  ollama pull qwen2.5:72b  # 47 GB"
echo ""
echo "Next steps:"
echo "  - Use 'make status' to check service"
echo "  - Use 'make test' to test API"
