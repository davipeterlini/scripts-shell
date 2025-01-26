#!/bin/bash

# TODO - ao instalar o script está buscando o nome com espaço - Warning: No available formula with the name " flameshot".
# TODO - feche todos os apps antes de executar a instalação, isso para o momento que for instalar o app, check se estiver aberto e feche

# Function to display a menu using dialog
display_menu() {
    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 3 \
        1 "Basic Apps" on \
        2 "Development Apps" off \
        3 "All macOS Apps" off)

    echo "$choices"
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
    IFS=',' read -r -a basic_apps <<< "$INSTALL_APPS_BASIC_MAC"
    install_apps_mac "${basic_apps[@]}"
}

# Function to install development apps
install_dev_apps() {
    echo "Installing development apps..."
    IFS=',' read -r -a dev_apps <<< "$INSTALL_APPS_DEV_MAC"
    install_apps_mac "${dev_apps[@]}"
}

# Function to install all macOS apps
install_all_apps() {
    echo "Installing all macOS apps..."
    IFS=',' read -r -a basic_apps <<< "$INSTALL_APPS_BASIC_MAC"
    IFS=',' read -r -a dev_apps <<< "$INSTALL_APPS_DEV_MAC"
    all_apps=("${basic_apps[@]}" "${dev_apps[@]}")
    install_apps_mac "${all_apps[@]}"
}

main() {
    # Redefine HOME to ensure proper handling of paths
    export HOME=$(eval echo ~)

    # Load environment variables
    source "$(dirname "$0")/../../utils/load_env.sh"
    load_env

    # Check if dialog is installed
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        if ! brew install dialog; then
            echo "Failed to install dialog. Please check your Homebrew setup." >&2
            exit 1
        fi
    fi

    # Display the menu and capture choices
    choices=$(display_menu)

    # Install selected apps based on choices
    if [[ "$choices" == *"1"* ]]; then
        install_basic_apps
    fi

    if [[ "$choices" == *"2"* ]]; then
        install_dev_apps
    fi

    if [[ "$choices" == *"3"* ]]; then
        install_all_apps
    fi
}

main
