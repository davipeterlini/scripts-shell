#!/bin/bash

# Script for installing UTM on different operating systems
# Supports: macOS, Ubuntu and other Linux distributions

# Constants
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# ===== Utility Functions =====
print_message() {
    local type=$1
    local message=$2
    
    case $type in
        "info") echo -e "${GREEN}[INFO]${NC} $message" ;;
        "warn") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "error") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

command_exists() {
    command -v "$1" &> /dev/null
}

# ===== macOS Installation =====
install_via_homebrew() {
    print_message "info" "Homebrew found, installing UTM..."
    brew install --cask utm
}

install_via_direct_download() {
    print_message "info" "Homebrew not found. Installing via direct download..."
    
    # Create temporary directory
    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || exit 1
    
    # Get the latest UTM version
    local latest_url=$(curl -s https://github.com/utmapp/UTM/releases/latest | grep -o 'https://github.com/utmapp/UTM/releases/tag/v[0-9.]*' | head -1)
    local version=$(echo "$latest_url" | grep -o 'v[0-9.]*')
    
    # Download URL
    local download_url="https://github.com/utmapp/UTM/releases/download/$version/UTM.dmg"
    
    print_message "info" "Downloading UTM $version..."
    curl -L -o UTM.dmg "$download_url"
    
    print_message "info" "Mounting DMG image..."
    hdiutil attach UTM.dmg
    
    print_message "info" "Copying UTM to Applications folder..."
    cp -R "/Volumes/UTM/UTM.app" /Applications/
    
    print_message "info" "Unmounting DMG image..."
    hdiutil detach "/Volumes/UTM"
    
    print_message "info" "Cleaning up temporary files..."
    cd - || exit 1
    rm -rf "$tmp_dir"
}

install_macos() {
    print_message "info" "Detected macOS. Starting UTM installation..."
    
    if command_exists brew; then
        install_via_homebrew
    else
        install_via_direct_download
    fi
    
    print_message "info" "UTM has been successfully installed! You can find it in the Applications folder."
}

# ===== Linux Installation =====
install_flatpak() {
    # Add Flathub repository if it doesn't exist
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # Install UTM
    flatpak install -y flathub com.utmapp.UTM
    
    print_message "info" "UTM has been successfully installed! You can start it from the applications menu or by running 'flatpak run com.utmapp.UTM'"
}

install_flatpak_first() {
    print_message "info" "Flatpak not found. Installing Flatpak first..."
    
    # Detect the distribution
    if command_exists apt; then
        # Debian/Ubuntu-based
        sudo apt update
        sudo apt install -y flatpak gnome-software-plugin-flatpak
    elif command_exists dnf; then
        # Fedora/RHEL-based
        sudo dnf install -y flatpak
    elif command_exists pacman; then
        # Arch-based
        sudo pacman -Sy --noconfirm flatpak
    elif command_exists zypper; then
        # openSUSE
        sudo zypper install -y flatpak
    else
        print_message "error" "Could not identify a compatible package manager. Please install Flatpak manually and run this script again."
        exit 1
    fi
    
    install_flatpak
}

install_ubuntu() {
    print_message "info" "Detected Ubuntu. Starting UTM installation via Flatpak..."
    
    # Check if Flatpak is installed
    if ! command_exists flatpak; then
        print_message "info" "Installing Flatpak..."
        sudo apt update
        sudo apt install -y flatpak gnome-software-plugin-flatpak
        
        # Add Flathub repository
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Install UTM via Flatpak
    install_flatpak
}

install_linux() {
    print_message "info" "Detected Linux. Starting UTM installation..."
    
    # Check which package manager is available
    if command_exists flatpak; then
        print_message "info" "Flatpak found, installing UTM via Flatpak..."
        install_flatpak
    else
        install_flatpak_first
    fi
}

# ===== Main =====
install_utm() {
    # Detect the operating system
    local os="$(uname -s)"
    case "${os}" in
        Darwin*)
            install_macos
            ;;
        Linux*)
            # Check if it's Ubuntu
            if [ -f /etc/lsb-release ] && grep -q "Ubuntu" /etc/lsb-release; then
                install_ubuntu
            else
                install_linux
            fi
            ;;
        *)
            print_message "error" "Unsupported operating system: ${os}"
            exit 1
            ;;
    esac
}

# Execute main only if the script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_utm "$@"
fi