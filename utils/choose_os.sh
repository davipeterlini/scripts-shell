#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors_message.sh"

# Function to choose the operating system
choose_os() {
    print_header "Choose the operating system to start development applications:"
    print "1) macOS"
    print "2) Linux"
    print "3) Windows"
    read -p "Enter the number corresponding to your choice (or press Enter to auto-detect): " os_choice

    case "$os_choice" in
        1)
            print_success "macOS selected."
            print "macOS"
            ;;
        2)
            print_success "Linux selected."
            print "Linux"
            ;;
        3)
            print_success "Windows selected."
            print "Windows"
            ;;
        *)
            print_alert "No valid choice was made. Auto-detecting operating system..."
            case "$(uname -s)" in
                Darwin)
                    print_success "macOS detected."
                    print "macOS"
                    ;;
                Linux)
                    print_success "Linux detected."
                    print "Linux"
                    ;;
                CYGWIN*|MINGW32*|MSYS*|MINGW*)
                    print_success "Windows detected."
                    print "Windows"
                    ;;
                *)
                    print_error "Unsupported operating system."
                    exit 1
                    ;;
            esac
            ;;
    esac
}