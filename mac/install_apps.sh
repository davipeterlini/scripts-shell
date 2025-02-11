#!/bin/bash

# Function to install a single app using Homebrew and check its version
install_app() {
    local app="$1"
    echo "Installing $app..."
    brew install "$app"

    # Check and display the version of the installed app
    if command -v "$app" &> /dev/null; then
        echo "$app version: $($app --version)"
    else
        echo "Failed to install $app or unable to check version."
    fi
}

# Main function to handle app installation
main() {
    if [ "$#" -eq 0 ]; then
        echo "No apps specified for installation."
        exit 1
    fi

    # Install each specified app
    for app in "$@"; do
        install_app "$app"
    done
}

main "$@"