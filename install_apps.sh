#!/bin/bash

# Function to display a menu using dialog
display_menu() {
    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 3 \
        1 "Basic Apps" on \
        2 "Development Apps" off \
        3 "All macOS Apps" off)

    echo "$choices"
}

# Function to install apps on Linux
install_apps_linux() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        sudo apt-get install -y "$app"
    done
}

# Function to install apps on macOS
install_apps_mac() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        brew install "$app"
    done
}

# Function to install basic apps
install_basic_apps() {
    echo "Installing basic apps..."
    IFS=',' read -r -a basic_apps <<< "$INSTALL_APPS_BASIC"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        install_apps_linux "${basic_apps[@]}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        install_apps_mac "${basic_apps[@]}"
    else
        echo "Unsupported OS."
        exit 1
    fi
}

# Function to install development apps
install_dev_apps() {
    echo "Installing development apps..."
    IFS=',' read -r -a dev_apps <<< "$INSTALL_APPS_DEV"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        install_apps_linux "${dev_apps[@]}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        install_apps_mac "${dev_apps[@]}"
    else
        echo "Unsupported OS."
        exit 1
    fi
}

# Function to install all macOS apps
install_all_mac_apps() {
    echo "Installing all macOS apps..."
    IFS=',' read -r -a mac_apps <<< "$APPS_TO_INSTALL_MAC"
    install_apps_mac "${mac_apps[@]}"
}

main() {
    # Load environment variables
    source "$(dirname "$0")/utils/load_env.sh"
    load_env

    # Check if dialog is installed
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y dialog
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install dialog
        else
            echo "Unsupported OS."
            exit 1
        fi
    fi

    choices=$(display_menu)

    if [[ "$choices" == *"1"* ]]; then
        install_basic_apps
    fi

    if [[ "$choices" == *"2"* ]]; then
        install_dev_apps
    fi

    if [[ "$choices" == *"3"* ]]; then
        install_all_mac_apps
    fi
}

main