#!/bin/bash

# Function to choose the operating system
choose_os() {
    echo "Choose the operating system to start development applications:"
    echo "1) macOS"
    echo "2) Linux"
    echo "3) Windows"
    read -p "Enter the number corresponding to your choice (or press Enter to auto-detect): " os_choice

    case "$os_choice" in
        1)
            echo "macOS chosen."
            echo "macOS"
            ;;
        2)
            echo "Linux chosen."
            echo "Linux"
            ;;
        3)
            echo "Windows chosen."
            echo "Windows"
            ;;
        *)
            echo "No valid choice made. Auto-detecting the operating system..."
            case "$(uname -s)" in
                Darwin)
                    echo "macOS detected."
                    echo "macOS"
                    ;;
                Linux)
                    echo "Linux detected."
                    echo "Linux"
                    ;;
                CYGWIN*|MINGW32*|MSYS*|MINGW*)
                    echo "Windows detected."
                    echo "Windows"
                    ;;
                *)
                    echo "Unsupported operating system."
                    exit 1
                    ;;
            esac
            ;;
    esac
}