#!/bin/bash

# Script to open UTM Documents folder in Finder
# This script opens the UTM Documents folder located at ~/Library/Containers/com.utmapp.UTM/Data/Documents

# Check if the directory exists
if [ -d ~/Library/Containers/com.utmapp.UTM/Data/Documents ]; then
    # Open the directory in Finder
    open ~/Library/Containers/com.utmapp.UTM/Data/Documents
    echo "UTM Documents folder opened in Finder."
else
    echo "Error: UTM Documents folder not found at ~/Library/Containers/com.utmapp.UTM/Data/Documents"
    exit 1
fi