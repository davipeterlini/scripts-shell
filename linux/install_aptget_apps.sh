#!/bin/bash

# Function to install apps using apt-get
install_apt_get_apps() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        echo "Installing $app via apt-get..."
        sudo apt-get install -y "$@"
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_apt_get_apps "$@"
fi