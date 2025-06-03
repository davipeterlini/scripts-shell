#!/bin/bash

source "$(dirname "$0")/../../utils/colors_message.sh"

# Function to choose the operating system
choose_os() {
    print_header "Choose the operating system to start development applications:"
    echo "1) macOS"
    echo "2) Linux"
    echo "3) Windows"
    read -p "Enter the number corresponding to your choice (or press Enter to auto-detect): " os_choice

    case "$os_choice" in
        1)
            print_success "macOS chosen."
            echo "macOS"
            ;;
        2)
            print_success "Linux chosen."
            echo "Linux"
            ;;
        3)
            print_success "Windows chosen."
            echo "Windows"
            ;;
        *)
            print_alert "No valid choice made. Auto-detecting the operating system..."
            case "$(uname -s)" in
                Darwin)
                    print_success "macOS detected."
                    echo "macOS"
                    ;;
                Linux)
                    print_success "Linux detected."
                    echo "Linux"
                    ;;
                CYGWIN*|MINGW32*|MSYS*|MINGW*)
                    print_success "Windows detected."
                    echo "Windows"
                    ;;
                *)
                    print_error "Unsupported operating system."
                    exit 1
                    ;;
            esac
            ;;
    esac
}