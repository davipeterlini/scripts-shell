#!/bin/bash

# Function to install a single app using Homebrew
install_app() {
    local app="$1"
    echo "Installing $app..."
    brew install "$app"
}

# Main function to handle app installation
main() {
    if [ "$#" -eq 0 ]; then
        echo "No app specified for installation."
        exit 1
    fi

    # Install the specified app
    install_app "$1"
}

main "$@"