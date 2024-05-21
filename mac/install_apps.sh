#!/bin/bash

# Check if Homebrew is installed, install if not
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Update Homebrew
brew update --auto-update
brew update

# Function to install software if it's not already installed
install_if_not_installed() {
    local name="$1"
    local brew_name="${2:-$1}"

    # Check if the software is already installed
    if brew list --formula | grep -q "^${brew_name}\$"; then
        echo "$name is already installed."
    else
        echo "Installing $name..."
        brew install $brew_name
    fi
}

# Tools Install 
install_if_not_installed "Git" "git"
install_if_not_installed "Wget" "wget"
install_if_not_installed "Python" "python"

# TODO - Adding another application

# Softwares to install
install_if_not_installed "iTerm2" "iterm2"
install_if_not_installed "Rambox" "rambox"
install_if_not_installed "Google Chrome" "google-chrome"
install_if_not_installed "Meld" "meld"
install_if_not_installed "IntelliJ IDEA" "intellij-idea"
install_if_not_installed "DBeaver" "dbeaver-community"
install_if_not_installed "Postman" "postman"
install_if_not_installed "OBS Studio" "obs"
install_if_not_installed "Android Studio" "android-studio"
install_if_not_installed "Spotify" "spotify"
install_if_not_installed "Rancher Desktop" "rancher-cli"
install_if_not_installed "Google Drive" "google-drive"
install_if_not_installed "VirtualBox" "virtualbox"
install_if_not_installed "AltTab" " --cask alt-tab"
install_if_not_installed "Visual Studio Code" "visual-studio-code"
install_if_not_installed "VLC" "vlc"
install_if_not_installed "Zoom" "zoom"
install_if_not_installed "Flameshot" "flameshot"
install_if_not_installed "Wireshark" "wireshark"
install_if_not_installed "Xcode" "xcode"
install_if_not_installed "node" "node"

# Clean up Homebrew caches, etc, after installation
brew cleanup