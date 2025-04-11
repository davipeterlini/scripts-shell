#!/bin/bash

# Function to verify if the coder package is installed
verify_coder_installation() {
    echo "Verifying coder installation..."
    if command -v coder &> /dev/null; then
        echo "Coder is installed successfully."
        coder --version
    else
        echo "Coder is not installed."
        exit 1
    fi
}

# Main script execution
verify_coder_installation