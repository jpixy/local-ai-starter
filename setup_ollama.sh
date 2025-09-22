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

echo "=== Configuring Ollama for External Access ==="
# Configure Ollama for external access
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/environment.conf << EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_PORT=11434"
EOF

# Reload systemd and restart ollama
sudo systemctl daemon-reload
sudo systemctl restart ollama

echo "=== Downloading Qwen Models ==="
# Download qwen2.5 models
echo "Downloading Qwen 2.5 32B model (this may take 30+ minutes)..."
ollama pull qwen2.5:32b

echo "Downloading Qwen 2.5 72B model (this may take 60+ minutes)..."
ollama pull qwen2.5:72b

# Verify model download success
if ollama list | grep -q "qwen2.5:32b"; then
    echo "SUCCESS Qwen 2.5 32B model downloaded successfully!"
else
    echo "ERROR Qwen 2.5 32B model download failed"
    exit 1
fi

if ollama list | grep -q "qwen2.5:72b"; then
    echo "SUCCESS Qwen 2.5 72B model downloaded successfully!"
else
    echo "WARNING Qwen 2.5 72B model download may have failed"
fi

echo "=== Testing Model Execution ==="
# Simple model test
echo "Testing 32B model response..."
echo "Hello" | ollama run qwen2.5:32b

echo "=== Ollama and Qwen Models Setup Complete! ==="
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "API service running at:"
echo "  - Local: http://localhost:11434"
echo "  - External: http://$SERVER_IP:11434"
echo
echo "You can interact with the models using:"
echo "  ollama run qwen2.5:32b"
echo "  ollama run qwen2.5:72b"
echo
echo "Or call via API endpoint:"
echo "  curl http://$SERVER_IP:11434/api/generate -X POST -H 'Content-Type: application/json' -d '{\"model\": \"qwen2.5:32b\", \"prompt\": \"Hello\", \"stream\": false}'"
echo
echo "Next steps:"
echo "  - Use ./start-complete.sh for Docker Compose deployment"
echo "  - Use ./test-complete.sh for comprehensive testing"
