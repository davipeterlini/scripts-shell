#!/bin/bash

# Load environment variables from .env file
source "$(dirname "$0")/../shell/load_env.sh"
load_env_and_var "APPS_TO_CLOSE_PERSONAL"

# Function to close all specified applications
close_all_apps() {
    echo "Closing all specified applications..."
    IFS=', ' read -r -a apps <<< "$APPS_TO_CLOSE_PERSONAL"
    for app in "${apps[@]}"; do
        echo "Closing $app..."
        pkill -f "$app" || killall "$app"
    done
    echo "All specified applications have been closed."
}

main() {
    # Ask the user if they want to close all specified applications
    read -p "Do you really want to close all specified applications? (y/n): " close_apps_choice

    if [ "$close_apps_choice" == "y" ] || [ "$close_apps_choice" == "Y" ]; then
        close_all_apps
    else
        echo "Skipping closing of applications."
    fi

    echo "Starting fundamental development applications for macOS..."

    # Check and start Rancher Desktop
    if open -Ra "Rancher Desktop"; then
        echo "Starting Rancher Desktop..."
        open -a Rancher\ Desktop
    else
        echo "Rancher Desktop is not installed. Consider installing it via install_apps.sh."
    fi

    # Check and start Visual Studio Code
    if open -Ra "Visual Studio Code"; then
        echo "Starting Visual Studio Code..."
        open -a Visual\ Studio\ Code
    else
        echo "Visual Studio Code is not installed. Consider installing it via install_apps.sh."
    fi

    # Check and start iTerm2
    if open -Ra "iTerm"; then
        echo "Starting iTerm2..."
        open -a iTerm
    else
        echo "iTerm2 is not installed. Consider installing it via install_apps.sh."
    fi

    # Check and start Google Chrome
    if open -Ra "Google Chrome"; then
        echo "Starting Google Chrome..."
        open -a "Google Chrome"
    else
        echo "Google Chrome is not installed. Consider installing it via install_apps.sh."
    fi

    # Check and start Rambox
    if open -Ra "Rambox"; then
        echo "Starting Rambox..."
        open -a Rambox
    else
        echo "Rambox is not installed. Consider installing it via install_apps.sh."
    fi

    echo "All fundamental development applications have been checked and started where available."
}

# Execute the main function
main