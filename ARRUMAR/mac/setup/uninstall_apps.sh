#!/bin/bash

# Function to uninstall a single app on macOS
uninstall_app_mac() {
    local app="$1"
    brew uninstall --cask "$app"
}

main() {
    if [ -z "$1" ]; then
        echo "Usage: $0 <app_name>"
        exit 1
    fi

    local app="$1"
    echo "Uninstalling $app..."
    uninstall_app_mac "$app"
    echo "$app uninstalled successfully."
}

main "$@"