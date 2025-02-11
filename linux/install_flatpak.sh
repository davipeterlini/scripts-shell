#!/bin/bash

# Function to install Homebrew
install_flatpak() {    
    if command -v flatpak &> /dev/null; then
        if [ -n "$1" ]; then
            echo "$1 Flatpak is already installed."
        else
            echo "Flatpak is already installed."
        fi
    else
        echo "Installing Flatpak..."
        sudo apt update
        sudo apt install -y flatpak
        sudo apt install -y gnome-software-plugin-flatpak
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_flatpak "$1"
fi