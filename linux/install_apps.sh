#!/bin/bash

# Update APT packages and indexes
echo "Updating APT packages and indexes..."
sudo apt update

# Function to install software if it's not already installed
install_if_not_installed() {
    local preparation="$1"
    local name="$2"

    # Check if the software is already installed
    if dpkg -l | grep -qw "$name"; then
        echo "$name is already installed."
    else
        echo "Installing $name..."
        $preparation
        sudo apt install -y $name

    fi
}

# Software to install (use APT package names)
install_if_not_installed "xclip"
install_if_not_installed "git"
install_if_not_installed "wget"
install_if_not_installed "python3"
install_if_not_installed "gnome-terminal" 
#install_if_not_installed "rambox"          # Check if available via APT, otherwise might need Snap or Flatpak
#install_if_not_installed "google-chrome-stable" #
install_if_not_installed "meld"
install_if_not_installed "intellij-idea-community"  # or 'intellij-idea-ultimate' for the paid version
#install_if_not_installed "dbeaver-ce" #
#install_if_not_installed "postman"   #
install_if_not_installed "obs-studio"
#install_if_not_installed "android-studio"
install_if_not_installed "curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list" "spotify-client"
#install_if_not_installed "rancher-desktop"  # May need to install via other means if not available on APT
#install_if_not_installed "google-drive-ocamlfuse"  # May need to configure after installation
install_if_not_installed "virtualbox"
install_if_not_installed "code"  
install_if_not_installed "vlc"
install_if_not_installed "zoom"              # For Zoom, you may need to download and install manually if not available via APT
install_if_not_installed "flameshot"
install_if_not_installed "wireshark"         # You may be asked to configure user permissions during installation

# Cleaning up unnecessary packages after installation
echo "Cleaning up unnecessary packages..."
sudo apt autoremove -y
