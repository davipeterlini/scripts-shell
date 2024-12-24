#!/bin/bash

# Function to display a menu using dialog
display_menu() {
    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 3 \
        1 "Basic Apps" on \
        2 "Development Apps" off \
        3 "All Linux Apps" off)

    echo "$choices"
}

# Function to load environment variables from .env file
load_env() {
    if [ -f .env ]; then
        export $(grep -v '^#' .env | xargs)
    else
        echo ".env file not found. Exiting..."
        exit 1
    fi
}

# Function to install apps on Linux
install_apps_linux() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        sudo apt-get install -y "$app"
    done
}

# Function to install basic apps
install_basic_apps() {
    echo "Installing basic apps..."
    IFS=',' read -r -a basic_apps <<< "$INSTALL_APPS_BASIC"
    install_apps_linux "${basic_apps[@]}"
}

# Function to install development apps
install_dev_apps() {
    echo "Installing development apps..."
    IFS=',' read -r -a dev_apps <<< "$INSTALL_APPS_DEV"
    install_apps_linux "${dev_apps[@]}"
}

# Function to install all Linux apps
install_all_linux_apps() {
    echo "Installing all Linux apps..."
    IFS=',' read -r -a linux_apps <<< "$APPS_TO_INSTALL_LINUX"
    install_apps_linux "${linux_apps[@]}"
}

main() {
    # Load environment variables
    load_env

    # Check if dialog is installed
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        sudo apt-get install -y dialog
    fi

    choices=$(display_menu)

    if [[ "$choices" == *"1"* ]]; then
        install_basic_apps
    fi

    if [[ "$choices" == *"2"* ]]; then
        install_dev_apps
    fi

    if [[ "$choices" == *"3"* ]]; then
        install_all_linux_apps
    fi
}

main