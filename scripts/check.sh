#!/bin/bash

# Function to check if all commands return 0


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
else
    echo ".venv directory is not present. Create a virtual environment first."
fi

check_result=0
ruff check
if [ $? -ne 0 ]; then
    check_result=1
fi

ruff format --check
if [ $? -ne 0 ]; then
    check_result=1
fi

mypy src/
if [ $? -ne 0 ]; then
    check_result=1
fi

pytest --cov=docugenr8 tests/
if [ $? -ne 0 ]; then
    check_result=1
fi

source ./scripts/version.sh
if [ $? -ne 0 ]; then
    check_result=1
fi

# Deactivate virtual environment
check_venv
if [ $? -eq 0 ]; then
    deactivate
else
    echo ".venv directory is not present. Create a virtual environment first."
fi

if [ "$check_result" -eq 0 ]; then
    echo -e "\e[1;32mCode Check successful.\e[0m"
    exit 0
else
    echo -e "\e[1;31mCode Check failed.\e[0m"
    exit 1
fi
