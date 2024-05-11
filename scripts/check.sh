#!/bin/bash

# Function to check if .venv directory exists
check_venv() {
    if [ -d ".venv" ]; then
        return 0  # True, directory exists
    else
        return 1  # False, directory does not exist
    fi
}

# Activate virtual environment
check_venv
if [ $? -eq 0 ]; then
    source .venv/bin/activate
    ruff check
    ruff format
    mypy src/
    pytest --cov=docugenr8 tests/
    deactivate
else
    echo ".venv directory is not present. Create a virtual environment first."
fi
