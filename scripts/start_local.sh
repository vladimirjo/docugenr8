#!/bin/bash

# docugenr8-shared directory
docugenr8_shared="/mnt/c/dev/docugenr8/docugenr8-shared"

# docugenr8-core directory
docugenr8_core="/mnt/c/dev/docugenr8/docugenr8-core"

# docugenr8-pdf directory
docugenr8_pdf="/mnt/c/dev/docugenr8/docugenr8-pdf"

# Install Python 3.10
sudo apt update
sudo apt install -y python3.10 python3.10-venv

# Update pip
python3.10 -m pip install --upgrade pip

# Create and activate virtual environment
python3.10 -m venv .venv
source .venv/bin/activate

# Install dev requirements from pyproject.toml
python3.10 -m pip install -e ".[dev]"
# python3.10 -m pip uninstall docugenr8-core docugenr8-shared docugenr8-pdf
python3.10 -m pip install -e $docugenr8_shared
python3.10 -m pip install -e $docugenr8_core
python3.10 -m pip install -e $docugenr8_pdf


# Deactivate venv
deactivate

# Start VSCode
if command -v code &> /dev/null
then
    code .
else
    echo "vscode could not be found."
fi
