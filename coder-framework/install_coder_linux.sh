#!/bin/bash

# Ensure Python is installed and PATH is configured
./install_python.sh

# Function to install coder
install_coder() {
    echo "Installing coder..."
    pip3 install https://storage.googleapis.com/flow-coder/coder-0.88-py3-none-any.whl
    echo "Coder installed successfully."
}

# Main script execution
install_coder

echo "Coder installation completed. Please restart your terminal or run 'source ~/.bashrc' or 'source ~/.zshrc' to apply PATH changes."