#!/bin/bash

# Load environment variables and utility functions
    source "$(dirname "$0")/utils/load_env.sh"
    load_env

    source "$(dirname "$0")/utils/detect_os.sh"

# Function to install additional apps and configurations on macOS
setup_mac() {
    ./mac/setup/setup_iterm.sh
}

# Function to install additional apps and configurations on Linux (Debian-based)
# setup_linux() {
#     # Add Linux-specific setup steps here
# }

# Detect the operating system and execute the corresponding script
detect_and_install_apps() {
    echo "Detecting the operating system..."

    # Detect the operating system
    os=$(detect_os)
    echo "Detected OS: $os"

    # Install selected apps
    ./install_apps.sh
    ./vscode/install_plugins.sh

    case "$os" in
        macOS)
            echo "macOS detected."
            setup_mac
            ;;
        Linux)
            echo "Linux detected."
            setup_linux
            ;;
        *)
            echo "Unsupported operating system."
            exit 1
            ;;
    esac
}

# Execute the script
detect_and_install_apps