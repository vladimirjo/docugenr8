#!/bin/bash

# Get the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define the filename you want to check
FILE=".pypi"

# Check if the file exists
if [ -e "$DIR/$FILE" ]; then
    export PROD_PYPI_TOKEN="$(cat "$DIR/$FILE")"
    return 0
else
    echo "File '$FILE' does not exist in the same directory as the script."
    return -1
fi
