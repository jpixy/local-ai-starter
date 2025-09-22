# Makefile for local-ai-starter project

.PHONY: help install install-poetry setup test lint format clean run-ollama run-test

# Default target
help:
	@echo "Available commands:"
	@echo "  install-poetry  Install Poetry package manager"
	@echo "  setup          Setup project with Poetry"
	@echo "  setup-pip      Setup project with pip (traditional)"
	@echo "  install        Install dependencies (Poetry)"
	@echo "  install-pip    Install dependencies (pip)"
	@echo "  test           Run test suite"
	@echo "  lint           Run linting tools"
	@echo "  format         Format code"
	@echo "  clean          Clean cache and temporary files"
	@echo "  run-ollama     Setup and run Ollama"
	@echo "  run-test       Run client tests"

# Poetry installation
install-poetry:
	@echo "Installing Poetry..."
	curl -sSL https://install.python-poetry.org | python3 -
	@echo "Add Poetry to PATH: export PATH=\"$$HOME/.local/bin:$$PATH\""

# Poetry setup
setup:
	@echo "Setting up project with Poetry..."
	./poetry_setup.sh

# Traditional pip setup
setup-pip:
	@echo "Setting up project with pip..."
	python3 -m venv venv
	. venv/bin/activate && pip install --upgrade pip
	. venv/bin/activate && pip install -r requirements.txt

# Install dependencies with Poetry
install:
	poetry install

# Install dependencies with pip
install-pip:
	pip install -r requirements.txt

# Install with all extras
install-full:
	poetry install --extras "full"

# Run tests
test:
	poetry run python test_client.py

# Run tests with pip environment
test-pip:
	python test_client.py

# Linting
lint:
	poetry run black --check .
	poetry run isort --check-only .
	poetry run flake8 .
	poetry run mypy ollama_client.py

# Format code
format:
	poetry run black .
	poetry run isort .

# Clean cache and temporary files
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name ".mypy_cache" -exec rm -rf {} +

# Clean temporary example files (according to user requirements)
clean-examples:
	@echo "Cleaning temporary example files..."
	rm -f api_examples.py

# Ollama setup
run-ollama:
	@echo "Setting up Ollama and Qwen 7B..."
	./setup_ollama.sh

# Run client tests
run-test:
	@echo "Running client tests..."
	poetry run python test_client.py

# Development server (if using FastAPI extra)
dev-server:
	poetry run uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Export requirements.txt from Poetry (requires poetry-plugin-export)
export-requirements:
	@echo "Installing poetry export plugin..."
	poetry self add poetry-plugin-export
	poetry export -f requirements.txt --output requirements.txt --without-hashes
	poetry export -f requirements.txt --output requirements-dev.txt --with dev --without-hashes

# Update dependencies
update:
	poetry update

# Show dependency tree
show-deps:
	poetry show --tree

# Check for security vulnerabilities
security-check:
	poetry run pip-audit

# Build package
build:
	poetry build

# Publish package (requires authentication)
publish:
	poetry publish

# Install pre-commit hooks
install-hooks:
	poetry run pre-commit install
