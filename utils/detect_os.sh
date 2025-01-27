#!/bin/bash

# Function to detect the operating system
detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macOS"
            ;;
        Linux)
            echo "Linux"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo "Windows"
            ;;
        *)
            echo "Unsupported OS"
            exit 1
            ;;
    esac
}