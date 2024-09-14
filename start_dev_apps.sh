#!/bin/bash

# Function to start development applications on macOS
start_apps_mac() {
    echo "Executing: ./github/connect_git_ssh_account.sh"
    ./github/connect_git_ssh_account.sh
    echo "Executing: ./mac/close_apps.sh"
    ./mac/close_apps.sh
    echo "Executing: ./mac/open_apps.sh"
    ./mac/open_apps.sh
}

# Function to start development applications on Linux
start_apps_linux() {
    echo "Executing: ./github/connect_git_ssh_account.sh"
    ./github/connect_git_ssh_account.sh
    echo "Executing: ./linux/close_apps.sh"
    ./linux/close_apps.sh
    echo "Executing: ./linux/open_apps.sh"
    ./linux/open_apps.sh
}

# Function to start development applications on Windows
start_apps_windows() {
    echo "Executing: ./github/connect_git_ssh_account.sh"
    ./github/connect_git_ssh_account.sh
    echo "Executing: ./windows/close_apps.sh"
    ./windows/close_apps.sh
    echo "Executing: ./windows/start_dev_apps.bat"
    ./windows/start_dev_apps.bat
    echo "Executing: ./windows/open_apps.bat"
    ./windows/open_apps.bat
}

# Function to detect the operating system and execute the corresponding script
detect_and_start_apps() {
    echo "Detecting the operating system..."

    case "$(uname -s)" in
        Darwin)
            echo "macOS detected."
            start_apps_mac
            ;;
        Linux)
            echo "Linux detected."
            start_apps_linux
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo "Windows detected."
            start_apps_windows
            ;;
        *)
            echo "Unsupported operating system."
            exit 1
            ;;
    esac
}

# Main function to start development applications
main() {
    echo "Choose the operating system to start development applications:"
    echo "1) macOS"
    echo "2) Linux"
    echo "3) Windows"
    read -p "Enter the number corresponding to your choice (or press Enter to auto-detect): " os_choice

    case "$os_choice" in
        1)
            echo "macOS chosen."
            start_apps_mac
            ;;
        2)
            echo "Linux chosen."
            start_apps_linux
            ;;
        3)
            echo "Windows chosen."
            start_apps_windows
            ;;
        *)
            echo "No valid choice made. Auto-detecting the operating system..."
            detect_and_start_apps
            ;;
    esac
}

# Execute the main function
main