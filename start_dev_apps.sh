#!/bin/bash

# Load the function to choose the operating system
source "$(dirname "$0")/utils/choose_os.sh"

# Function to print and execute a script
execute_script() {
    local script_path="$1"
    echo "Executing: $script_path"
    $script_path
}

# Function to start development applications on macOS
start_apps_mac() {
    execute_script "./mac/close_apps.sh"
    execute_script "./github/connect_git_ssh_account.sh"
    execute_script "./mac/open_apps.sh"
    execute_script "./mac/open_terminal_tabs.sh"
}

# Function to start development applications on Linux
start_apps_linux() {
    execute_script "./linux/close_apps.sh"
    execute_script "./github/connect_git_ssh_account.sh"
    execute_script "./linux/open_apps.sh"
    execute_script "./linux/open_terminal_tabs.sh"
}

# Function to start development applications on Windows
start_apps_windows() {
    execute_script "./windows/close_apps.sh"
    execute_script "./github/connect_git_ssh_account.sh"
    execute_script "./windows/open_apps.bat"
    execute_script "./windows/open_terminal_tabs.bat"
}

# Main function to start development applications
main() {
    os_choice=$(choose_os)
    echo "Operating system chosen: $os_choice"

    case "$os_choice" in
        macOS)
            start_apps_mac
            ;;
        Linux)
            start_apps_linux
            ;;
        Windows)
            start_apps_windows
            ;;
        *)
            echo "Unsupported operating system."
            exit 1
            ;;
    esac
}

# Execute the main function
main