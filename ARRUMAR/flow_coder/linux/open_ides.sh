#!/bin/bash

# Script to open different IDEs (VSCode, JetBrains Ultimate, JetBrains Community Edition)
# across different operating systems (macOS, Linux)

# Imports Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/generic_utils.sh"

# ===== Constants =====
readonly SCRIPT_VERSION="1.0.0"
readonly OS="$(uname -s)"

# ===== Utility Functions =====
print_usage() {
    echo "Usage: $0 [vscode|ultimate|community] [path]"
    echo "  vscode    - Open VSCode"
    echo "  ultimate  - Open JetBrains Ultimate Edition"
    echo "  community - Open JetBrains Community Edition"
    echo "  path      - Optional path to open in the IDE"
}

# ===== IDE Opener Functions =====
open_vscode_linux() {
    if command_exists code; then
        code "$@"
    else
        print_error "VSCode not found. Please install it or check your PATH."
        return 1
    fi
}

open_vscode_macos() {
    if command_exists code; then
        code "$@"
    elif [ -d "/Applications/Visual Studio Code.app" ]; then
        open -a "Visual Studio Code" "$@"
    else
        print_error "VSCode not found. Please install it."
        return 1
    fi
}

open_vscode() {
    print_info "Opening VSCode..."
    case "$OS" in
        Linux*) open_vscode_linux "$@" ;;
        Darwin*) open_vscode_macos "$@" ;;
        *) print_error "Unsupported operating system for this script." ;;
    esac
}

open_jetbrains_ultimate_linux() {
    if command_exists idea; then
        idea "$@"
    else
        print_error "JetBrains Ultimate not found. Please install it or check your PATH."
        return 1
    fi
}

open_jetbrains_ultimate_macos() {
    if [ -d "/Applications/IntelliJ IDEA.app" ]; then
        open -a "IntelliJ IDEA" "$@"
    else
        print_error "JetBrains Ultimate not found. Please install it."
        return 1
    fi
}

open_jetbrains_ultimate() {
    print_info "Opening JetBrains IntelliJ IDEA Ultimate..."
    case "$OS" in
        Linux*) open_jetbrains_ultimate_linux "$@" ;;
        Darwin*) open_jetbrains_ultimate_macos "$@" ;;
        *) print_error "Unsupported operating system for this script." ;;
    esac
}

open_jetbrains_community_linux() {
    if command_exists idea-ce; then
        idea-ce "$@"
    else
        print_error "JetBrains Community Edition not found. Please install it or check your PATH."
        return 1
    fi
}

open_jetbrains_community_macos() {
    if [ -d "/Applications/IntelliJ IDEA CE.app" ]; then
        open -a "IntelliJ IDEA CE" "$@"
    else
        print_error "JetBrains Community Edition not found. Please install it."
        return 1
    fi
}

open_jetbrains_community() {
    print_info "Opening JetBrains IntelliJ IDEA Community Edition..."
    case "$OS" in
        Linux*) open_jetbrains_community_linux "$@" ;;
        Darwin*) open_jetbrains_community_macos "$@" ;;
        *) print_error "Unsupported operating system for this script." ;;
    esac
}

# Install Flow Coder in all supported IDEs
open_all() {
    local os_type=$1
    
    open_vscode "$os_type"

    open_jetbrains_community 

    open_jetbrains_ultimate
}

# Show menu function
show_menu() {
    echo "===== Open IDE Menu ====="
    echo "1. Open VSCode"
    echo "2. Open JetBrains IntelliJ IDEA Ultimate"
    echo "3. Open JetBrains IntelliJ IDEA Community Edition"
    echo "4. Exit"
    echo "=========================="
}

# Function to handle the interactive menu
run_interactive_menu() {
    local project_path=""
    
    # Ask for project path
    read -p "Enter project path (leave empty for current directory): " project_path
    
    # If empty, use current directory
    if [ -z "$project_path" ]; then
        project_path="."
    fi
    
    # Validate path
    if [ ! -d "$project_path" ]; then
        print_error "Invalid path: $project_path"
        return 1
    fi
    
    while true; do
        show_menu
        read -p "Choose an option (1-4): " choice
        
        case $choice in
            1)
                open_vscode "$project_path"
                ;;
            2)
                open_jetbrains_ultimate "$project_path"
                ;;
            3)
                open_jetbrains_community "$project_path"
                ;;
            4)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Command line mode function
run_command_line_mode() {
    local ide="$1"
    shift  # Remove the first argument, leaving any path arguments

    case "$ide" in
        vscode)
            open_vscode "$@"
            ;;
        ultimate)
            open_jetbrains_ultimate "$@"
            ;;
        community)
            open_jetbrains_community "$@"
            ;;
        *)
            print_error "Unknown IDE: $ide"
            print_info "Supported IDEs: vscode, ultimate, community"
            print_usage
            exit 1
            ;;
    esac
}

# ===== Main =====
open_ides() {
    print_header "Open IDEs for test Flow Coder installation..."

    local os="$1"
    if [[ -z "$os" ]]; then
        detect_os
    fi

    # Check if script is being called directly or from another script
    local is_direct_call=0
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        is_direct_call=1
    fi
    
    # # If called with arguments, use command line mode
    # if [ "$#" -gt 0 ]; then
    #     run_command_line_mode "$@"
    #     return $?
    # fi

    # If called from another script, install all tools automatically
    if [[ $is_direct_call -eq 0 ]]; then
        if ! confirm_action "Do you want Open Vscode and Jetbrains ?"; then
            print_info "Skipping install"
            return 0
        fi
        open_all "$os_type"
        return 0
    fi
    
    # Run interactive menu for direct calls
    run_interactive_menu
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  open_ides "$@"
fi