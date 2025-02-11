#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/utils/load_env.sh"
load_env

# Load OS detection script
source "$(dirname "$0")/utils/detect_os.sh"

# Function to install and configure npm on macOS
setup_npm_mac() {
    echo "Setting up npm on macOS..."
    brew install npm
}

# Function to install and configure npm on Linux
setup_npm_linux() {
    echo "Setting up npm on Linux..."
    sudo apt update
    sudo apt install -y npm
}

# Function to install and configure npm on Windows
setup_npm_windows() {
    echo "Setting up npm on Windows..."
    choco install npm
}

# Function to configure npm paths in the profile
configure_npm_paths() {
    local profile_file="$HOME/.zshrc"
    echo "Configuring npm paths in $profile_file..."

    {
        echo '# NPM configuration'
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"'
        echo 'NPM_CONFIG_PREFIX="$HOME/.npm-global"'
    } >> "$profile_file"

    source "$profile_file"
}

# Main function to detect OS and setup npm accordingly
main() {
    # Detect the operating system
    os=$(detect_os)
    echo "Detected OS: $os"

    case "$os" in
        macOS)
            setup_npm_mac
            ;;
        Linux)
            setup_npm_linux
            ;;
        Windows)
            setup_npm_windows
            ;;
        *)
            echo "Unsupported operating system."
            exit 1
            ;;
    esac

    # Configure npm paths
    configure_npm_paths
}

main