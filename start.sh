#!/bin/bash

DOCUGENR8_SHARED="../docugenr8-shared"
DOCUGENR8_CORE="../docugenr8-core"
DOCUGENR8_PDF="../docugenr8-pdf"
LOCAL_DEV=false

# Function to check if Python 3.10 is installed
check_python_version() {
    if command -v python3.10 &> /dev/null; then
        # Python 3.10 command is available, now check the version
        local python_version
        python_version=$(python3.10 --version 2>&1)
        if [[ $python_version == "Python 3.10"* ]]; then
            echo "Python 3.10 is installed: $python_version"
            return 0
        else
            echo "Python 3.10 command exists but the version is different: $python_version"
            return 1
        fi
    else
        echo "Python 3.10 is not installed."
        return 1
    fi
}

# Function to check if .venv directory exists
check_venv() {
    if [ -d ".venv" ]; then
        return 0  # True, directory exists
    else
        return 1  # False, directory does not exist
    fi
}

setup() {
    # Install Python 3.10
    if ! check_python_version; then
        sudo apt update
        sudo apt install -y python3.10 python3.10-venv
    fi

    # Update pip
    python3.10 -m pip install --upgrade pip

    # Create and activate virtual environment
    if ! check_venv; then
        python3.10 -m venv .venv
    fi
    # shellcheck source=/dev/null
    source .venv/bin/activate

    # Install dev requirements from pyproject.toml
    python3.10 -m pip install -e ".[dev]"

    if [[ "$LOCAL_DEV" == "true" ]]; then
        python3.10 -m pip install -e $DOCUGENR8_SHARED
        python3.10 -m pip install -e $DOCUGENR8_CORE
        python3.10 -m pip install -e $DOCUGENR8_PDF
    fi

    # Deactivate venv
    if check_venv; then
        deactivate
    fi

    # Start VSCode
    if command -v code &> /dev/null
    then
        code .
    else
        echo "vscode could not be found."
    fi
}

show_usage() {
    echo "Usage: $0 {remote|local}"
    exit 1
}

# Check if at least one argument is passed
if [ $# -lt 1 ]; then
    show_usage
fi

# Handle different arguments
case "$1" in
    remote)
        setup
        ;;
    local)
        LOCAL_DEV=true
        setup
        ;;
    *)
        echo "Invalid option: $1"
        show_usage
        ;;
esac
