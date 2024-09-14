#!/bin/bash

# Function to print and execute a script
execute_script() {
    local script_path="$1"
    echo "Executing: $script_path"
    $script_path
}

# Function to start development applications on macOS
start_apps_mac() {
    execute_script "./github/connect_git_ssh_account.sh"
    execute_script "./mac/close_apps.sh"
    execute_script "./mac/open_apps.sh"
}

# Function to start development applications on Linux
start_apps_linux() {
    execute_script "./github/connect_git_ssh_account.sh"
    execute_script "./linux/close_apps.sh"
    execute_script "./linux/open_apps.sh"
}

# Function to start development applications on Windows
start_apps_windows() {
    execute_script "./github/connect_git_ssh_account.sh"
    execute_script "./windows/close_apps.sh"
    execute_script "./windows/start_dev_apps.bat"
    execute_script "./windows/open_apps.bat"
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