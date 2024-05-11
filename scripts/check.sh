#!/bin/bash

# Define a success message
success() {
    local prefix="\e[1;32m========================================\n\e[1;32m"
    local sufix="\n\e[1;32m========================================\e[0m"
    local result="${prefix}$1${sufix}"
    echo "$result"
}

# Define a warning message
warning() {
    local prefix="\e[1;31m========================================\n\e[1;31m"
    local sufix="\n\e[1;31m========================================\e[0m"
    local result="${prefix}$1${sufix}"
    echo "$result"
}

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
    echo ".venv directory is not present."
fi

check_result=0
ruff check
if [ $? -ne 0 ]; then
    check_result=1
    echo -e "$(warning "Linting Failed")"
else
    echo -e "$(success "Linting Successful")"
fi

ruff format --check
if [ $? -ne 0 ]; then
    check_result=1
    echo -e "$(warning "Formatting Failed")"
else
    echo -e "$(success "Formatting Successful")"
fi

mypy src/
if [ $? -ne 0 ]; then
    check_result=1
    echo -e "$(warning "Check Type Failed")"
else
    echo -e "$(success "Check Type Successful")"
fi

pytest --cov=docugenr8 tests/
if [ $? -ne 0 ]; then
    check_result=1
    echo -e "$(warning "Tests Failed")"
else
    echo -e "$(success "Tests Successful")"
fi

source ./scripts/version.sh
if [ $? -ne 0 ]; then
    check_result=1
    echo -e "$(warning "Version exists on PyPI")"
else
    echo -e "$(success "Version does not exists on PyPI")"
fi

# Deactivate virtual environment
check_venv
if [ $? -eq 0 ]; then
    deactivate
else
    echo ".venv directory is not present."
fi

if [ "$check_result" -eq 0 ]; then
    echo -e "$(success "Code Check successful.")"
    exit 0
else
    echo -e "$(warning "Code Check failed.")"
    exit 1
fi
