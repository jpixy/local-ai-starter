# Makefile for local-ai-starter (Ollama only)

.PHONY: help install start stop status test clean

# Default target
help:
	@echo "Local AI Starter - Ollama Management"
	@echo ""
	@echo "Available commands:"
	@echo "  install    Install Ollama and download qwen2.5:7b model"
	@echo "  start      Start Ollama service"
	@echo "  stop       Stop Ollama service"
	@echo "  status     Check Ollama service status"
	@echo "  test       Test Ollama API"
	@echo "  models     List installed models"
	@echo "  clean      Remove Ollama models and data"

# Install Ollama and download model
install:
	@echo "Installing Ollama and downloading model..."
	./setup_ollama.sh

# Start Ollama service
start:
	@echo "Starting Ollama service..."
	@if pgrep -x "ollama" > /dev/null; then \
		echo "Ollama is already running"; \
	else \
		ollama serve & \
		sleep 2; \
		echo "Ollama started on http://localhost:11434"; \
	fi

# Stop Ollama service
stop:
	@echo "Stopping Ollama service..."
	@pkill ollama || echo "Ollama is not running"

# Check service status
status:
	@echo "Checking Ollama status..."
	@if pgrep -x "ollama" > /dev/null; then \
		echo "✓ Ollama is running"; \
		curl -s http://localhost:11434/api/tags | grep -o '"name":"[^"]*"' | sed 's/"name":"//;s/"//g' | while read model; do \
			echo "  - Model: $$model"; \
		done; \
	else \
		echo "✗ Ollama is not running"; \
	fi

# Test Ollama API
test:
	@echo "Testing Ollama API..."
	@curl -s http://localhost:11434/api/generate \
		-d '{"model": "qwen2.5:7b", "prompt": "Say hello in one word", "stream": false}' \
		| grep -o '"response":"[^"]*"' | sed 's/"response":"//;s/"//g' || \
		echo "Error: Ollama API test failed"

# List installed models
models:
	@echo "Installed models:"
	@ollama list

# Clean Ollama data
clean:
	@echo "This will remove all Ollama models and data."
	@echo "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@pkill ollama || true
	@rm -rf ~/.ollama
	@echo "Ollama data cleaned"
