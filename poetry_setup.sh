#!/bin/bash

# Poetry setup script for local-ai-starter
echo "=== Poetry Setup for Local AI Starter ==="

# Check if Poetry is installed
if command -v poetry &> /dev/null; then
    echo "Poetry is already installed, version: $(poetry --version)"
else
    echo "Installing Poetry..."
    # Install Poetry using official installer
    curl -sSL https://install.python-poetry.org | python3 -
    
    # Add Poetry to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    # Check if installation was successful
    if command -v poetry &> /dev/null; then
        echo "SUCCESS Poetry installation completed!"
    else
        echo "ERROR Poetry installation failed"
        echo "Please add $HOME/.local/bin to your PATH manually:"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
        exit 1
    fi
fi

echo "=== Configuring Poetry ==="
# Configure Poetry to create virtual environments in project directory
poetry config virtualenvs.in-project true
poetry config virtualenvs.prefer-active-python true

echo "=== Installing Dependencies ==="
# Install project dependencies
poetry install

# Install optional extras if desired
echo "Available extras:"
echo "  - data: pandas, numpy for data processing"
echo "  - api: fastapi, uvicorn for web API"
echo "  - full: all optional dependencies"
echo ""
echo "To install extras later, use:"
echo "  poetry install --extras \"data api\""

echo "=== Poetry Setup Complete! ==="
echo "Virtual environment created in: .venv/"
echo ""
echo "Usage commands:"
echo "  poetry shell                 # Activate virtual environment"
echo "  poetry install               # Install dependencies"
echo "  poetry add <package>         # Add new dependency"
echo "  poetry add --group dev <pkg> # Add development dependency"
echo "  poetry run python script.py  # Run script in virtual environment"
echo "  poetry run local-ai-test     # Run test suite"
echo ""
echo "To activate the environment:"
echo "  poetry shell"
echo "Or run commands with:"
echo "  poetry run python test_client.py"
