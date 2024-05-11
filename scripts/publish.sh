#!/bin/bash

# Define a function
success() {
    local prefix1="\e[1;32m"
    local prefix2="========================================\n"
    local sufix1="\n========================================"
    local sufix2="\e[0m"
    local result="${prefix1}${prefix2}$1${sufix1}${sufix2}"
    echo "$result"
}

# Define a function
warning() {
    local prefix1="\e[1;31m"
    local prefix2="========================================\n"
    local sufix1="\n========================================"
    local sufix2="\e[0m"
    local result="${prefix1}${prefix2}$1${sufix1}${sufix2}"
    echo "$result"
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

    # Activate virtual environment to run build inside
    source .venv/bin/activate
    echo -e "$(success "Virtual environment is activated")"


    # Clean build and dist directories
    ./scripts/clean.sh
    echo -e "$(success "Deleting build and dist directories successful")"


    # Run the commands and show output in the shell
    echo -e "$(success "Running build process")"
    python -m build --sdist --wheel .

    echo -e "$(success "Publishing package on PyPI")"
    twine upload dist/* --username=__token__ --password="$PROD_PYPI_TOKEN"
    deactivate
else
    echo -e "$(warning "Package version exists already on PyPI")"
fi
