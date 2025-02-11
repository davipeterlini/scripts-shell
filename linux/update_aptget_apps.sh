#!/bin/bash

# Function to update all APT packages
update_apt-get_apps() {
    echo "Updating APT packages..."
    sudo apt update && sudo apt upgrade -y
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    update_apt-get_apps
    echo "APT packages updated successfully."
fi