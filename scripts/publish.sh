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

# Run pypi_env.sh
source ./scripts/pypi_env.sh

# Check if pypi_env.sh was successful
if [ $? -eq 0 ]; then
    echo -e "$(success "PROD_PYPI_TOKEN environent variable is set")"
else
    echo -e "$(warning "PROD_PYPI_TOKEN environent variable is NOT set")"

fi

# Run version.sh
source ./scripts/version.sh

# Check if version.sh was successful
if [ $? -eq 0 ]; then
    echo -e "$(success "Package version can be published on PyPI")"

    # Activate virtual environment to run build inside if needed
    check_venv
    if [ $? -eq 0 ]; then
        source .venv/bin/activate
        echo -e "$(success "Virtual environment is activated")"
    fi

    # Clean build and dist directories
    ./scripts/clean.sh
    echo -e "$(success "Deleting build and dist directories successful")"


    # Run the commands and show output in the shell
    echo -e "$(success "Running build process")"
    python -m build --sdist --wheel .

    echo -e "$(success "Publishing package on PyPI")"
    twine upload dist/* --username=__token__ --password="$PROD_PYPI_TOKEN"

    # Deactivate virtual environment to run build inside if needed
    check_venv
    if [ $? -eq 0 ]; then
        deactivate
        echo -e "$(success "Virtual environment is deactivated")"
    fi
else
    echo -e "$(warning "Package version exists already on PyPI")"
fi
