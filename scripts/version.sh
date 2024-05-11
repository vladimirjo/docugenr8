#!/bin/bash

# Read version from version.txt file and remove non-numerical characters
version=$(sed 's/[^0-9.]//g' version.txt)

# Package name
package_name="docugenr8"

# Fetch package versions from Test PyPI
versions=$(curl -sSL https://pypi.org/simple/${package_name}/ | grep -o '<a [^>]*>.*</a>' | sed -e 's/<[^>]*>//g')
echo $versions

# Check if version exists
if echo "$versions" | grep -q "$version"; then
    echo "Version $version exists on PyPI"
    return -1
else
    echo "Version $version does not exist on PyPI"
    return 0
fi
