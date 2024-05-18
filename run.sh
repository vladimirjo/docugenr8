#!/bin/bash

# MAIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
FILE_VERSION=$(sed 's/[^0-9.]//g' "./version.txt")
PACKAGE_NAME="docugenr8"
PYPI_FILE=".pypi"

# Define a success message
success() {
    local prefix="\e[1;32m"
    local sufix="\e[0m"
    local result="\n${prefix}$1${sufix}"
    echo -e "$result"
}

# Define a warning message
warning() {
    local prefix="\e[1;31m"
    local sufix="\e[0m"
    local result="\n${prefix}$1${sufix}"
    echo -e "$result"
}

# Define a warning message
failure() {
    local prefix="\e[1;31m"
    local sufix="\e[0m"
    local result="\n${prefix}!EXECUTION FAILED!${sufix}"
    echo -e "$result"
}

# Function to check if .venv directory exists
check_venv() {
    if [ -d ".venv" ]; then
        return 0  # True, directory exists
    else
        return 1  # False, directory does not exist
    fi
}

remove_build_and_dist() {
    if [ -e "./build" ]; then
        success "Deleting build directory..."
        rm -rf "./build"
    fi

    if [ -e "./dist" ]; then
        success "Deleting dist directory..."
        rm -rf "./dist"
    fi
}

check_version_file(){
    # Fetch package versions from Test PyPI
    pypi_versions=$(curl -sSL https://pypi.org/simple/${PACKAGE_NAME}/ | grep -o '<a [^>]*>.*</a>' | sed -e 's/<[^>]*>//g')

    # Check if version exists
    if echo "$pypi_versions" | grep -q "$FILE_VERSION"; then
        return 1
    else
        return 0
    fi
}

# check existance of .pypi
set_local_prod_pypi_token() {
    # Check if the token file exists
    if [ -e "./$PYPI_FILE" ]; then
        # Read the token from the file
        success "Local token file "./$PYPI_FILE" is used to set PROD_PYPI_TOKEN."
        export PROD_PYPI_TOKEN=$(cat "./$PYPI_FILE")
    fi
}

check_prod_pypi_env() {
    if [[ -n "$PROD_PYPI_TOKEN" && "$PROD_PYPI_TOKEN" == pypi-* ]]; then
        return 0
    else
        return 1
    fi
}

publish() {
    set_local_prod_pypi_token

    if check_prod_pypi_env; then
        success "Environment variable PYPI_TOKEN is set and starts with 'pypi-'."
    else
        warning "Environment variable PYPI_TOKEN is either not set or does not start with 'pypi-'."
        failure
        return 1
    fi

    check_version_file
    if [ $? -eq 0 ]; then
        success "Version $FILE_VERSION does not exist on PyPI"
    else
        warning "Version $FILE_VERSION exists on PyPI"
        failure
        return 1
    fi

    if check_venv; then
        source .venv/bin/activate
        success "Virtual environment is activated."
    fi

    remove_build_and_dist

    # Run the commands and show output in the shell
    success "Running build process..."
    python -m build --sdist --wheel .

    success "Publishing package on PyPI..."
    twine upload dist/* --username=__token__ --password="$PROD_PYPI_TOKEN"

    if check_venv; then
        deactivate
        success "Virtual environment is deactivated."
    fi
}

check_code(){
    if check_venv; then
        source .venv/bin/activate
        success "Virtual environment is activated."
    fi

    local check_result=0
    ruff check
    if [ $? -ne 0 ]; then
        check_result=1
        warning "Linting Failed"
    else
        success "Linting Successful"
    fi

    ruff format --check
    if [ $? -ne 0 ]; then
        check_result=1
        warning "Formatting Failed"
    else
        success "Formatting Successful"
    fi

    mypy src/
    if [ $? -ne 0 ]; then
        check_result=1
        warning "Type Check Failed"
    else
        success "Type Check Successful"
    fi

    pytest --cov=docugenr8 tests/
    if [ $? -ne 0 ]; then
        check_result=1
        warning "Tests Failed"
    else
        success "Tests Successful"
    fi

    check_version_file
    if [ $? -ne 0 ]; then
        check_result=1
        warning "Version $FILE_VERSION exists on PyPI"
    else
        success "Version $FILE_VERSION does not exist on PyPI"
    fi

    if check_venv; then
        deactivate
        success "Virtual environment is deactivated."
    fi

    if [ "$check_result" -eq 0 ]; then
        success "Code Check successful."
        exit 0
    else
        warning "Code Check failed."
        failure
        exit 1
    fi
}



show_usage() {
    echo "Usage: $0 {check|publish}"
    exit 1
}

# Check if at least one argument is passed
if [ $# -lt 1 ]; then
    show_usage
    exit 1
fi

# Handle different arguments
case "$1" in
    check)
        check_code
        ;;
    publish)
        publish
        ;;
    *)
        echo "Invalid option: $1"
        show_usage
        ;;
esac
