#!/bin/bash

# Unified script for installing development IDEs on macOS and Linux
# - Visual Studio Code
# - IntelliJ IDEA Ultimate
# - IntelliJ IDEA Community Edition

# Imports Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/generic_utils.sh"

# Constants
readonly PKG_MANAGER_APT="apt"
readonly PKG_MANAGER_DNF="dnf"
readonly PKG_MANAGER_PACMAN="pacman"
readonly PKG_MANAGER_ZYPPER="zypper"
readonly INSTALL_METHOD_FLATPAK="flatpak"

#####################################################
# macOS specific functions
#####################################################

# Configure macOS environment for IDE installation
setup_mac_environment() {
    print_info "Setting up macOS environment for IDE installation..."
    install_homebrew_mac
}

# Install Homebrew on macOS
install_homebrew_mac() {
    if ! command_exists brew; then
        print_info "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH if needed
        if [[ $(uname -m) == "arm64" ]]; then
            # For Apple Silicon (M1/M2)
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        print_info "Homebrew is already installed."
    fi
}

# Helper function to install or update brew cask
install_or_update_brew_cask() {
    local cask_name=$1
    local display_name=$2
    
    if brew list --cask $cask_name &>/dev/null; then
        print_info "$display_name is already installed. Updating..."
        brew upgrade --cask $cask_name
    else
        brew install --cask $cask_name
    fi
    
    print_info "$display_name installed/updated successfully!"
}

# Install Visual Studio Code on macOS
install_vscode_macos() {
    print_info "Installing Visual Studio Code..."
    install_or_update_brew_cask "visual-studio-code" "Visual Studio Code"
}

# Install IntelliJ IDEA Ultimate on macOS
install_intellij_ultimate_macos() {
    print_info "Installing IntelliJ IDEA Ultimate..."
    install_or_update_brew_cask "intellij-idea" "IntelliJ IDEA Ultimate"
}

# Install IntelliJ IDEA Community Edition on macOS
install_intellij_community_macos() {
    print_info "Installing IntelliJ IDEA Community Edition..."
    install_or_update_brew_cask "intellij-idea-ce" "IntelliJ IDEA Community Edition"
}

#####################################################
# Linux specific functions
#####################################################

# Configure Linux environment for IDE installation
setup_linux_environment() {
    print_info "Setting up Linux environment for Flatpak installation..."
    __detect_package_manager
    __install_dependencies
    __check_and_install_flatpak
}

# Detect package manager on Linux
__detect_package_manager() {
    if command_exists apt; then
        PKG_MANAGER=$PKG_MANAGER_APT
        PKG_UPDATE="apt update"
        PKG_INSTALL="apt install -y"
    elif command_exists dnf; then
        PKG_MANAGER=$PKG_MANAGER_DNF
        PKG_UPDATE="dnf check-update"
        PKG_INSTALL="dnf install -y"
    elif command_exists pacman; then
        PKG_MANAGER=$PKG_MANAGER_PACMAN
        PKG_UPDATE="pacman -Sy"
        PKG_INSTALL="pacman -S --noconfirm"
    elif command_exists zypper; then
        PKG_MANAGER=$PKG_MANAGER_ZYPPER
        PKG_UPDATE="zypper refresh"
        PKG_INSTALL="zypper install -y"
    else
        print_error "Could not detect a compatible package manager."
        exit 1
    fi
}

# Install common dependencies on Linux
__install_dependencies() {
    print_info "Installing necessary dependencies..."
    sudo $PKG_UPDATE
    
    case $PKG_MANAGER in
        $PKG_MANAGER_APT)
            sudo $PKG_INSTALL curl wget apt-transport-https gnupg software-properties-common
            ;;
        $PKG_MANAGER_DNF)
            sudo $PKG_INSTALL curl wget
            ;;
        $PKG_MANAGER_PACMAN)
            sudo $PKG_INSTALL curl wget
            ;;
        $PKG_MANAGER_ZYPPER)
            sudo $PKG_INSTALL curl wget
            ;;
    esac
}

# Check and install Flatpak if needed
__check_and_install_flatpak() {
    if ! command_exists flatpak; then
        print_info "Flatpak not found. Installing..."
        
        case $PKG_MANAGER in
            $PKG_MANAGER_APT)
                sudo $PKG_UPDATE
                sudo $PKG_INSTALL flatpak gnome-software-plugin-flatpak
                ;;
            $PKG_MANAGER_DNF)
                sudo $PKG_INSTALL flatpak
                ;;
            $PKG_MANAGER_PACMAN)
                sudo $PKG_INSTALL flatpak
                ;;
            $PKG_MANAGER_ZYPPER)
                sudo $PKG_INSTALL flatpak
                ;;
        esac
        
        # Add Flathub repository
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        
        print_info "Flatpak installed successfully!"
        print_alert "It's recommended to restart your system to ensure Flatpak is properly integrated."
        read -p "Do you want to continue without restarting? (y/n): " choice
        if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
            print_info "Please restart your system and run this script again."
            exit 0
        fi
    else
        # Ensure Flathub repository is added
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        print_info "Flatpak is already installed."
    fi
}

# Helper function to install Flatpak apps
install_flatpak_app() {
    local app_id=$1
    local display_name=$2
    
    print_info "Installing $display_name via Flatpak..."
    
    if flatpak list | grep -q "$app_id"; then
        print_info "$display_name is already installed. Updating..."
        flatpak update --assumeyes "$app_id"
    else
        flatpak install --assumeyes flathub "$app_id"
    fi
    
    print_info "$display_name installed/updated successfully via Flatpak!"
}

# Install Visual Studio Code on Linux via Flatpak
install_vscode_linux() {
    install_flatpak_app "com.visualstudio.code" "Visual Studio Code"
}

# Install IntelliJ IDEA Ultimate on Linux via Flatpak
install_intellij_ultimate_linux() {
    install_flatpak_app "com.jetbrains.IntelliJ-IDEA-Ultimate" "IntelliJ IDEA Ultimate"
}

# Install IntelliJ IDEA Community Edition on Linux via Flatpak
install_intellij_community_linux() {
    install_flatpak_app "com.jetbrains.IntelliJ-IDEA-Community" "IntelliJ IDEA Community Edition"
}

#####################################################
# Unified installation functions
#####################################################

# Generic function to install based on OS
install_based_on_os() {
    local app_name=$1
    local macos_function=$2
    local linux_function=$3
    
    if [[ "$os" == "macOS" ]]; then
        $macos_function
    elif [[ "$os" == "Ubuntu" ]]; then
        $linux_function
    else
        print_error "Unsupported operating system for $app_name installation"
    fi
}

# Install Visual Studio Code
install_vscode() {
    install_based_on_os "Visual Studio Code" install_vscode_macos install_vscode_linux
}

# Install IntelliJ IDEA Ultimate
install_intellij_ultimate() {
    install_based_on_os "IntelliJ IDEA Ultimate" install_intellij_ultimate_macos install_intellij_ultimate_linux
}

# Install IntelliJ IDEA Community Edition
install_intellij_community() {
    install_based_on_os "IntelliJ IDEA Community Edition" install_intellij_community_macos install_intellij_community_linux
}

# Setup environment based on OS
setup_environment() {
    install_based_on_os "Setup Environment" setup_mac_environment setup_linux_environment
}

# Install all IDEs
install_all_ides() {
    install_vscode
    install_intellij_ultimate
    install_intellij_community
    print_info "All IDEs installed successfully!"
}

# Installation menu
show_menu() {
    echo "===== Development IDE Installation ====="
    echo "1. Install Visual Studio Code"
    echo "2. Install IntelliJ IDEA Ultimate"
    echo "3. Install IntelliJ IDEA Community Edition"
    echo "4. Install all IDEs"
    echo "5. Exit"
    echo "===================================================="
}

# Function to handle the interactive menu
run_interactive_menu() {
    while true; do
        show_menu
        read -p "Choose an option (1-5): " choice
        
        case $choice in
            1)
                install_vscode
                ;;
            2)
                install_intellij_ultimate
                ;;
            3)
                install_intellij_community
                ;;
            4)
                install_all_ides
                ;;
            5)
                print_info "Exiting installer..."
                exit 0
                ;;
            *)
                print_alert "Invalid option. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

#####################################################
# Main program
#####################################################

install_ides() {
    print_header "Installing Development IDEs..."

    local os="$1"
    if [[ -z "$os" ]]; then
        detect_os
    fi

    # Check if script is being called directly or from another script
    local is_direct_call=0
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        is_direct_call=1
    fi

    # If called from another script, install all tools automatically
    if [[ $is_direct_call -eq 0 ]]; then
        if ! get_user_confirmation "Do you want to install VS Code, IntelliJ IDEA Ultimate and IntelliJ IDEA Community Edition?"; then
            print_info "Skipping installation"
            return 0
        fi
        setup_environment
        install_all_ides
        return 0
    fi

    # Run interactive menu for direct calls
    setup_environment
    run_interactive_menu
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_ides "$@"
fi