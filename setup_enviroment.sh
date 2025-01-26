#!/bin/bash

# TODO - esse script precisa criar o arquivo .env.local e colocar as variáveis necessárias dentro dele
# TODO - não está setando corretamente a variável HOME sempre coloca "" a mais e não deve ser com aspas duplas 

# Function to install apps on macOS
install_apps_mac() {
    echo "Starting installation of apps for macOS..."
    ./mac/setup/setup_iterm.sh
    ./mac/setup/install_apps.sh
    ./mac/setup/update_apps.sh
    ./mac/setup/setup_terminal.sh
    #./mac/setup/setup_docker.sh
    #./vscode/install_plugins.sh
}

# Function to install apps on Linux (Debian-based)
install_apps_linux() {
    echo "Starting installation of apps for Linux..."
    ./linux/setup/install_apps.sh
    #./linux/setup/update_apps.sh
    #./linux/setup/setup_terminal.sh
    #./linux/setup/setup_docker.sh
    #./vscode/install_plugins.sh
}

# Detect the operating system and execute the corresponding script
detect_and_install_apps() {
    echo "Detecting the operating system..."

    # Detect the operating system
    case "$(uname -s)" in
        Darwin)
            echo "macOS detected."
            install_apps_mac
            ;;

        Linux)
            echo "Linux detected."
            install_apps_linux
            ;;

        *)
            echo "Unsupported operating system."
            exit 1
            ;;
    esac
}

# Execute the script
source "$(dirname "$0")/utils/load_env.sh"
load_env
detect_and_install_apps