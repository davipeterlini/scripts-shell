#!/bin/bash

# Function to install Python
install_python() {
    echo "Installing Python..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update
        sudo apt install -y python3 python3-pip
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install python
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "Please install Python manually from https://www.python.org/downloads/windows/"
        exit 1
    else
        echo "Unsupported OS. Please install Python manually."
        exit 1
    fi
    echo "Python installed successfully."
}

# Function to configure PATH
configure_path() {
    echo "Configuring PATH..."
    SHELL_CONFIG_FILE="$HOME/.zshrc"
    PATH_ENTRY='export PATH=$PATH:$HOME/.local/bin'

    if ! grep -Fxq "$PATH_ENTRY" $SHELL_CONFIG_FILE; then
        echo '' >> $SHELL_CONFIG_FILE
        echo $PATH_ENTRY >> $SHELL_CONFIG_FILE
        source $SHELL_CONFIG_FILE
        echo "PATH configured successfully in $SHELL_CONFIG_FILE."
    else
        echo "PATH entry already exists in $SHELL_CONFIG_FILE."
    fi
}

# Function to verify Python installation
verify_python() {
    echo "Verifying Python installation..."
    python3 --version
    if [ $? -eq 0 ]; then
        echo "Python is installed and working correctly."
    else
        echo "Python installation failed. Please check the installation steps."
        exit 1
    fi
}

# Main script execution
install_python
configure_path
verify_python

echo "Python installation and PATH configuration completed. Please restart your terminal or run 'source ~/.zshrc' to apply PATH changes."