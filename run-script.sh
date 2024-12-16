#!/bin/bash

# Check if virtual environment directory exists
if [ ! -d ".venv" ]; then
    echo "Error: Virtual environment directory .venv not found"
    exit 1
fi

# Check if Python file exists
if [ ! -f "message.py" ]; then
    echo "Error: Python file message.py not found"
    exit 1
fi

# Activate virtual environment and run Python file
source .venv/bin/activate
if [ $? -eq 0 ]; then
    echo "Successfully activated virtual environment"
    python message.py
    deactivate
else
    echo "Error: Failed to activate virtual environment"
    exit 1
fi
