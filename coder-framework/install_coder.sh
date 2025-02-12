#!/bin/bash

# Ensure Python is installed and PATH is configured
source "$(dirname "$0")/install_python.sh"

# Function to install coder
install_coder() {
    echo "Installing coder..."
    python3 -m venv coder_env
    source coder_env/bin/activate
    pip install --upgrade pip
    pip install https://storage.googleapis.com/flow-coder/coder-0.88-py3-none-any.whl
    deactivate
    echo "Coder installed successfully."
}

# Function to configure PATH
configure_path() {
    echo "Configuring PATH..."
    SHELL_CONFIG_FILE="$HOME/.zshrc"
    PATH_ENTRY='export PATH=$PATH:$(pwd)/coder_env/bin'

    if ! grep -Fxq "$PATH_ENTRY" $SHELL_CONFIG_FILE; then
        echo '' >> $SHELL_CONFIG_FILE
        echo $PATH_ENTRY >> $SHELL_CONFIG_FILE
        source $SHELL_CONFIG_FILE
        echo "PATH configured successfully in $SHELL_CONFIG_FILE."
    else
        echo "PATH entry already exists in $SHELL_CONFIG_FILE."
    fi
}

# Main script execution
install_coder
configure_path

echo "Coder installation completed. Please restart your terminal or run 'source ~/.zshrc' to apply PATH changes."