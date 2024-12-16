#!/bin/bash

# Export project directory as environment variable
export CODECLIP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Project directory: $CODECLIP_DIR"

# Check if virtual environment directory exists
if [ ! -d "$CODECLIP_DIR/.venv" ]; then
    echo "Error: Virtual environment directory .venv not found"
    exit 1
fi

# Check if Python file exists
if [ ! -f "$CODECLIP_DIR/message.py" ]; then
    echo "Error: Python file message.py not found"
    exit 1
fi

# Activate virtual environment and run Python file
source "$CODECLIP_DIR/.venv/bin/activate"
if [ $? -eq 0 ]; then
    echo "Successfully activated virtual environment"
    python "$CODECLIP_DIR/message.py"
    deactivate
else
    echo "Error: Failed to activate virtual environment"
    exit 1
fi