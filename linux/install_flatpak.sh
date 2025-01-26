#!/bin/bash

# Function to install Flatpak if not installed
install_flatpak() {
    if ! command -v flatpak &> /dev/null; then
        echo "Flatpak not found. Installing Flatpak..."
        sudo apt update
        sudo apt install -y flatpak
        sudo apt install -y gnome-software-plugin-flatpak
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        echo "Flatpak is already installed."
    fi
}

# Execute the function
install_flatpak