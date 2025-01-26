#!/bin/bash

# Ensure Python is installed and PATH is configured
./install_python.sh

# Function to install coder
install_coder() {
    echo "Installing coder..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        python3 -m venv coder_env
        source coder_env/bin/activate
        pip install coder
    else
        pip3 install coder
    fi
    echo "Coder installed successfully."
}

# Main script execution
install_coder

echo "Coder installation completed. Please restart your terminal or run 'source ~/.bashrc' or 'source ~/.zshrc' to apply PATH changes."