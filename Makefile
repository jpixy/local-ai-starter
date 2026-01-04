# Makefile for local-ai-starter (Ollama only)

.PHONY: help install start stop status test clean models

# Default target
help:
	@echo "Local AI Starter - Ollama Management"
	@echo ""
	@echo "Quick Start:"
	@echo "  make install   Install Ollama and download qwen2.5:7b model"
	@echo "  make start     Start Ollama service"
	@echo "  make test      Test Ollama API"
	@echo ""
	@echo "All commands:"
	@echo "  install        Install Ollama and download qwen2.5:7b model"
	@echo "  start          Start Ollama service"
	@echo "  stop           Stop Ollama service"
	@echo "  status         Check Ollama service status"
	@echo "  test           Test Ollama API"
	@echo "  models         List installed models"
	@echo "  pull-32b       Download qwen2.5:32b model (19 GB)"
	@echo "  pull-72b       Download qwen2.5:72b model (47 GB)"
	@echo "  clean          Remove Ollama models and data"

# Install Ollama and download 7B model (recommended for media_organizer)
install:
	@echo "=== Installing Ollama ==="
	@if command -v ollama > /dev/null 2>&1; then \
		echo "✓ Ollama already installed: $$(ollama --version 2>/dev/null || echo 'unknown')"; \
	else \
		echo "Installing Ollama..."; \
		curl -fsSL https://ollama.ai/install.sh | sh; \
	fi
	@echo ""
	@echo "=== Starting Ollama service ==="
	@$(MAKE) -s start
	@sleep 2
	@echo ""
	@echo "=== Downloading qwen2.5:7b model (4.7 GB) ==="
	@ollama pull qwen2.5:7b
	@echo ""
	@echo "=== Installation complete ==="
	@ollama list

# Start Ollama service
start:
	@if pgrep -x "ollama" > /dev/null; then \
		echo "✓ Ollama is already running"; \
	else \
		echo "Starting Ollama..."; \
		ollama serve > /dev/null 2>&1 & \
		sleep 2; \
		if pgrep -x "ollama" > /dev/null; then \
			echo "✓ Ollama started on http://localhost:11434"; \
		else \
			echo "✗ Failed to start Ollama"; \
			exit 1; \
		fi \
	fi

# Stop Ollama service
stop:
	@echo "Stopping Ollama..."
	@pkill ollama 2>/dev/null && echo "✓ Ollama stopped" || echo "Ollama is not running"

# Check service status
status:
	@echo "=== Ollama Status ==="
	@if pgrep -x "ollama" > /dev/null; then \
		echo "✓ Ollama is running"; \
		echo ""; \
		echo "Models:"; \
		ollama list 2>/dev/null || echo "  (none)"; \
	else \
		echo "✗ Ollama is not running"; \
		echo "  Run 'make start' to start the service"; \
	fi

# Test Ollama API
test:
	@echo "=== Testing Ollama API ==="
	@if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then \
		echo "✗ Ollama is not responding"; \
		echo "  Run 'make start' first"; \
		exit 1; \
	fi
	@echo "Testing qwen2.5:7b..."
	@response=$$(curl -s http://localhost:11434/api/generate \
		-d '{"model": "qwen2.5:7b", "prompt": "Say hello in Chinese (one word)", "stream": false}' \
		2>/dev/null | grep -o '"response":"[^"]*"' | sed 's/"response":"//;s/"//g'); \
	if [ -n "$$response" ]; then \
		echo "✓ Response: $$response"; \
	else \
		echo "✗ No response (model may not be downloaded)"; \
		echo "  Run 'ollama pull qwen2.5:7b' to download"; \
	fi

# List installed models
models:
	@echo "=== Installed Models ==="
	@ollama list 2>/dev/null || echo "Ollama is not running"

# Download larger models (optional)
pull-32b:
	@echo "Downloading qwen2.5:32b (19 GB)..."
	@ollama pull qwen2.5:32b

pull-72b:
	@echo "Downloading qwen2.5:72b (47 GB)..."
	@ollama pull qwen2.5:72b

# Clean Ollama data
clean:
	@echo "This will remove ALL Ollama models and data."
	@echo "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@pkill ollama 2>/dev/null || true
	@rm -rf ~/.ollama
	@echo "✓ Ollama data cleaned"
