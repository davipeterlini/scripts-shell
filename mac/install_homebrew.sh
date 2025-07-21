#!/bin/bash

source "$(dirname "$0")/utils/colors_message.sh"

install_homebrew() {
    # Check if Homebrew is already installed
    if command -v brew &> /dev/null; then
        print_alert "Homebrew is already installed."
    else
        # Install Homebrew
        print_success "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Disabling Analytics
        brew analytics off

        # Add Homebrew to PATH
        print_success "Adding Homebrew to PATH..."
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_homebrew "$@"
fi