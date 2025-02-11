#!/bin/bash

# Function to install Homebrew
install_homebrew() {
    if command -v brew &> /dev/null; then
        if [ -n "$1" ]; then
            echo "$1 Homebrew is already installed."
        else
            echo "Homebrew is already installed."
        fi
    else
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_homebrew "$1"
fi