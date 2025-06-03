#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors_message.sh"

# Function to detect the operating system
detect_os() {
    print_info "Detecting the operating system..."
    case "$(uname -s)" in
        Darwin)
            print_success "Operating System detected: macOS"
            print "macOS"
            ;;
        Linux)
            print_success "Operating System detected: Linux"
            print "Linux"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            print_success "Operating System detected: Windows"
            print "Windows"
            ;;
        *)
            print_error "Unsupported Operating System"
            exit 1
            ;;
    esac
}