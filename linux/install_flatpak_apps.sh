#!/bin/bash

# Function to install apps using flatpak
_install_flatpak_apps() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        echo "Installing $app via flatpak..."
        sudo flatpak install -y "$app"
    done
}

# Function to install Homebrew
_install_flatpak() {    
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
install_flatpak_apps() {
    # Install Homebflatpakrew if not installed
    _install_flatpak

    # Install the provided apps
    _install_flatpak_apps "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_flatpak_apps "$@"
fi