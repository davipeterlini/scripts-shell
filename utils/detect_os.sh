#!/bin/bash

source "$(dirname "$0")/../../utils/colors_message.sh"

# Function to detect the operating system
detect_os() {
    print_info "Detecting the operating system..."
    case "$(uname -s)" in
        Darwin)
            print_success "Operating System detected: macOS"
            echo "macOS"
            ;;
        Linux)
            print_success "Operating System detected: Linux"
            echo "Linux"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            print_success "Operating System detected: Windows"
            echo "Windows"
            ;;
        *)
            print_error "Unsupported Operating System"
            exit 1
            ;;
    esac
}