#!/bin/bash

set -e

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to download and install a .dmg file
install_dmg() {
    local app_name=$1
    local url=$2
    local volume_name=$3
    local app_path=$4

    print_message "Installing $app_name..." "$YELLOW"
    
    # Download the .dmg file
    curl -L -o "/tmp/${app_name}.dmg" "$url"
    
    # Mount the .dmg file
    hdiutil attach "/tmp/${app_name}.dmg"
    
    # Copy the application to the Applications folder
    cp -R "/Volumes/${volume_name}/${app_path}" /Applications
    
    # Unmount the .dmg file
    hdiutil detach "/Volumes/${volume_name}"
    
    # Remove the downloaded .dmg file
    rm "/tmp/${app_name}.dmg"
    
    print_message "$app_name installed successfully." "$GREEN"
}

# Function to download and install a .pkg file
install_pkg() {
    local app_name=$1
    local url=$2

    print_message "Installing $app_name..." "$YELLOW"
    
    # Download the .pkg file
    curl -L -o "/tmp/${app_name}.pkg" "$url"
    
    # Install the .pkg file
    sudo installer -pkg "/tmp/${app_name}.pkg" -target /
    
    # Remove the downloaded .pkg file
    rm "/tmp/${app_name}.pkg"
    
    print_message "$app_name installed successfully." "$GREEN"
}

# Function to download and install a .zip file
install_zip() {
    local app_name=$1
    local url=$2

    print_message "Installing $app_name..." "$YELLOW"
    
    # Download the .zip file
    curl -L -o "/tmp/${app_name}.zip" "$url"
    
    # Unzip the file
    unzip -q "/tmp/${app_name}.zip" -d /Applications
    
    # Remove the downloaded .zip file
    rm "/tmp/${app_name}.zip"
    
    print_message "$app_name installed successfully." "$GREEN"
}

# Install basic apps
install_dmg "Google Chrome" "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" "Google Chrome" "Google Chrome.app"
install_dmg "Flameshot" "https://github.com/flameshot-org/flameshot/releases/download/v0.10.2/flameshot-0.10.2-mac.dmg" "flameshot" "flameshot.app"
install_dmg "Rambox" "https://rambox.app/download/mac" "Rambox" "Rambox.app"
install_dmg "Spotify" "https://download.scdn.co/SpotifyInstaller.zip" "Spotify" "Spotify.app"
install_dmg "OBS Studio" "https://cdn-fastly.obsproject.com/downloads/obs-mac-27.2.4.dmg" "OBS" "OBS.app"
install_dmg "Google Drive" "https://dl.google.com/drive-file-stream/GoogleDrive.dmg" "Install Google Drive" "Google Drive.app"
install_pkg "Zoom" "https://zoom.us/client/latest/Zoom.pkg"
install_zip "AltTab" "https://github.com/lwouis/alt-tab-macos/releases/latest/download/AltTab.zip"

# Install dev apps
install_pkg "Git" "https://sourceforge.net/projects/git-osx-installer/files/latest/download"
install_pkg "Node.js" "https://nodejs.org/dist/v14.17.0/node-v14.17.0.pkg"
install_pkg "Python" "https://www.python.org/ftp/python/3.9.5/python-3.9.5-macosx10.9.pkg"
install_pkg "Wget" "https://rudix.org/packages/wget.pkg"
install_pkg "Colima" "https://github.com/abiosoft/colima/releases/download/v0.4.0/colima-Darwin-x86_64.tar.gz"
install_pkg "Go" "https://golang.org/dl/go1.16.4.darwin-amd64.pkg"
install_dmg "Meld" "https://github.com/yousseb/meld/releases/download/osx-19/meldmerge.dmg" "Meld" "Meld.app"
install_dmg "DBeaver" "https://dbeaver.io/files/dbeaver-ce-latest-macos.dmg" "DBeaver" "DBeaver.app"
install_dmg "Postman" "https://dl.pstmn.io/download/latest/osx" "Postman" "Postman.app"
install_dmg "Docker" "https://desktop.docker.com/mac/stable/Docker.dmg" "Docker" "Docker.app"
install_dmg "Robo 3T" "https://download.robomongo.org/1.4.3/mac/robo3t-1.4.3-darwin-x86_64.dmg" "Robo 3T 1.4.3" "Robo 3T.app"
install_dmg "IntelliJ IDEA" "https://download.jetbrains.com/idea/ideaIC-2021.1.2.dmg" "IntelliJ IDEA CE" "IntelliJ IDEA CE.app"
install_dmg "VirtualBox" "https://download.virtualbox.org/virtualbox/6.1.22/VirtualBox-6.1.22-144080-OSX.dmg" "VirtualBox" "VirtualBox.app"
install_dmg "Wireshark" "https://1.na.dl.wireshark.org/osx/Wireshark%203.4.5%20Intel%2064.dmg" "Wireshark" "Wireshark.app"
install_zip "Visual Studio Code" "https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal"
install_zip "Flutter" "https://storage.googleapis.com/flutter_infra/releases/stable/macos/flutter_macos_2.2.1-stable.zip"
install_sh "Miniconda" "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"

# Install other apps
install_pkg "Rancher CLI" "https://github.com/rancher/cli/releases/download/v2.4.11/rancher-darwin-amd64-v2.4.11.tar.gz"
install_dmg "Android Studio" "https://redirector.gvt1.com/edgedl/android/studio/install/4.2.1.0/android-studio-ide-202.7351085-mac.dmg" "Android Studio" "Android Studio.app"
xcode-select --install # Install Xcode Command Line Tools

print_message "All applications have been installed successfully!" "$GREEN"