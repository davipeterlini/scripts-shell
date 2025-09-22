#!/bin/bash

# Script to install Mac applications from official sources or Apple Store
# No package managers are used, only official installation methods

# Get the absolute directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the utils scripts
source "$SCRIPT_DIR/../utils/bash_tools.sh"
source "$SCRIPT_DIR/../utils/colors_message.sh"

# Source the global environment variables
ENV_GLOBAL_PATH="../assets/.env.global"
if [ -f "$ENV_GLOBAL_PATH" ]; then
    source "$ENV_GLOBAL_PATH"
else
    echo -e "${RED}Error: Global environment file not found at $ENV_GLOBAL_PATH${NC}"
    exit 1
fi

# Function to check if an application is already installed
check_app_installed() {
    local app_name="$1"
    local app_path="/Applications/${app_name}.app"

    if [ -d "$app_path" ]; then
        return 0 # App exists
    else
        return 1 # App doesn't exist
    fi
}

# Function to check how an application was installed
check_installation_method() {
    local app_name="$1"
    local app_path="/Applications/${app_name}.app"

    if [ ! -d "$app_path" ]; then
        print_error "${app_name} is not installed."
        return 1
    fi

    # Check if it's from Mac App Store
    if [ -d "$app_path/Contents/_MASReceipt" ]; then
        print_success "${app_name} is installed from Mac App Store."
        return 0
    fi

    # Check for Homebrew installation
    brew_info=$(brew list --cask 2>/dev/null | grep -i "$(echo $app_name | tr '[:upper:]' '[:lower:]')" 2>/dev/null)
    if [ -n "$brew_info" ]; then
        print_alert "${app_name} is installed via Homebrew."
        return 0
    fi

    # If no specific method detected, it's likely a direct download
    print_info "${app_name} appears to be installed via direct download."
    return 0
}

# Function to remove an application
remove_application() {
    local app_name="$1"
    local app_path="/Applications/${app_name}.app"

    if [ ! -d "$app_path" ]; then
        print_error "${app_name} is not installed."
        return 1
    fi

    print_alert "Removing ${app_name}..."

    # Check if it's from Mac App Store
    if [ -d "$app_path/Contents/_MASReceipt" ]; then
        print_alert "${app_name} is from Mac App Store. Removing using 'trash' command..."
        # Using trash command if available, otherwise move to trash
        if command -v trash &>/dev/null; then
            trash "$app_path"
        else
            rm -rf "$app_path"
        fi
        print_success "${app_name} moved to trash."
        return 0
    fi

    # Check for Homebrew installation
    brew_info=$(brew list --cask 2>/dev/null | grep -i "$(echo $app_name | tr '[:upper:]' '[:lower:]')" 2>/dev/null)
    if [ -n "$brew_info" ]; then
        print_alert "${app_name} is installed via Homebrew. Please use 'brew uninstall' to remove it properly."
        return 1
    fi

    # Direct download - move to trash
    print_alert "Removing ${app_name} (direct download)..."
    if command -v trash &>/dev/null; then
        trash "$app_path"
    else
        rm -rf "$app_path"
    fi
    print_success "${app_name} moved to trash."
    return 0
}

# Function to check if app is installed and handle reinstallation
check_and_handle_installation() {
    local app_name="$1"

    if check_app_installed "$app_name"; then
        print_success "${app_name} is already installed."
        check_installation_method "$app_name"

        if get_user_confirmation "Do you want to remove and reinstall ${app_name}?"; then
            remove_application "$app_name"
            return 0 # Continue with installation
        else
            return 1 # Skip installation
        fi
    fi

    if ! get_user_confirmation "Do you want to install ${app_name}?"; then
        return 1 # Skip installation
    fi

    return 0 # Continue with installation
}

# Install Google Chrome
install_google_chrome() {
    local app_name="Google Chrome"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/googlechrome.dmg "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"
    hdiutil attach /tmp/googlechrome.dmg
    cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications/
    hdiutil detach "/Volumes/Google Chrome"
    rm /tmp/googlechrome.dmg
    print_success "${app_name} has been installed successfully."
}

# Install Zoom
install_zoom() {
    local app_name="zoom.us"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/zoom.pkg "https://zoom.us/client/latest/Zoom.pkg"
    sudo installer -pkg /tmp/zoom.pkg -target /
    rm /tmp/zoom.pkg
    print_success "${app_name} has been installed successfully."
}

# Install Flameshot
install_flameshot() {
    local app_name="flameshot"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_alert "Flameshot doesn't provide an official macOS binary download. It's typically installed via Homebrew or built from source."
    print_alert "Would you like to download from GitHub releases instead?"

    if get_user_confirmation "Download Flameshot from GitHub releases?"; then
        print_info "Downloading and installing ${app_name}..."
        curl -L -o /tmp/flameshot.dmg "https://github.com/flameshot-org/flameshot/releases/latest/download/flameshot.dmg"
        hdiutil attach /tmp/flameshot.dmg
        cp -R "/Volumes/Flameshot/flameshot.app" /Applications/
        hdiutil detach "/Volumes/Flameshot"
        rm /tmp/flameshot.dmg
        print_success "${app_name} has been installed successfully."
    fi
}

# Install Rambox
install_rambox() {
    local app_name="Rambox"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/rambox.dmg "https://rambox.app/api/download?platform=mac"
    hdiutil attach /tmp/rambox.dmg
    cp -R "/Volumes/Rambox/Rambox.app" /Applications/
    hdiutil detach "/Volumes/Rambox"
    rm /tmp/rambox.dmg
    print_success "${app_name} has been installed successfully."
}

# Install Spotify
install_spotify() {
    local app_name="Spotify"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/spotify.dmg "https://download.scdn.co/SpotifyInstaller.zip"
    unzip -q /tmp/spotify.dmg -d /tmp/
    open /tmp/Install\ Spotify.app
    print_alert "Please follow the on-screen instructions to complete installation."
    print_success "Once installation is complete, ${app_name} will be available in your Applications folder."
    # Remove the downloaded file after a delay to allow installation to proceed
    (sleep 30 && rm -rf /tmp/spotify.dmg /tmp/Install\ Spotify.app) &
}

# Install OBS Studio
install_obs() {
    local app_name="OBS"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/obs.dmg "https://cdn-fastly.obsproject.com/downloads/obs-mac-latest.dmg"
    hdiutil attach /tmp/obs.dmg
    cp -R "/Volumes/OBS/OBS.app" /Applications/
    hdiutil detach "/Volumes/OBS"
    rm /tmp/obs.dmg
    print_success "${app_name} has been installed successfully."
}

# Install Google Drive
install_google_drive() {
    local app_name="Google Drive"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/googledrive.dmg "https://dl.google.com/drive-file-stream/GoogleDrive.dmg"
    hdiutil attach /tmp/googledrive.dmg
    sudo installer -pkg "/Volumes/Install Google Drive/GoogleDrive.pkg" -target /
    hdiutil detach "/Volumes/Install Google Drive"
    rm /tmp/googledrive.dmg
    print_success "${app_name} has been installed successfully."
}

# Install Alt-Tab
install_alt_tab() {
    local app_name="AltTab"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/alttab.zip "https://github.com/lwouis/alt-tab-macos/releases/latest/download/AltTab.zip"
    unzip -q /tmp/alttab.zip -d /tmp/
    cp -R "/tmp/AltTab.app" /Applications/
    rm /tmp/alttab.zip
    rm -rf "/tmp/AltTab.app"
    print_success "${app_name} has been installed successfully."
}

# Install Visual Studio Code
install_visual_studio_code() {
    local app_name="Visual Studio Code"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/vscode.zip "https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal"
    unzip -q /tmp/vscode.zip -d /tmp/
    cp -R "/tmp/Visual Studio Code.app" /Applications/
    rm /tmp/vscode.zip
    rm -rf "/tmp/Visual Studio Code.app"
    print_success "${app_name} has been installed successfully."
}

# Install Postman
install_postman() {
    local app_name="Postman"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/postman.zip "https://dl.pstmn.io/download/latest/osx_64"
    unzip -q /tmp/postman.zip -d /tmp/
    cp -R "/tmp/Postman.app" /Applications/
    rm /tmp/postman.zip
    rm -rf "/tmp/Postman.app"
    print_success "${app_name} has been installed successfully."
}

# Install DBeaver Community
install_dbeaver_community() {
    local app_name="DBeaver"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/dbeaver.dmg "https://dbeaver.io/files/dbeaver-ce-latest-macos.dmg"
    hdiutil attach /tmp/dbeaver.dmg
    cp -R "/Volumes/DBeaver Community/DBeaver.app" /Applications/
    hdiutil detach "/Volumes/DBeaver Community"
    rm /tmp/dbeaver.dmg
    print_success "${app_name} has been installed successfully."
}

# Install IntelliJ IDEA Community Edition
install_intellij_idea_ce() {
    local app_name="IntelliJ IDEA CE"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/intellij.dmg "https://download.jetbrains.com/idea/ideaIC-latest-aarch64.dmg"
    hdiutil attach /tmp/intellij.dmg
    cp -R "/Volumes/IntelliJ IDEA CE/IntelliJ IDEA CE.app" /Applications/
    hdiutil detach "/Volumes/IntelliJ IDEA CE"
    rm /tmp/intellij.dmg
    print_success "${app_name} has been installed successfully."
}

# Install PyCharm CE
install_pycharm_ce() {
    local app_name="PyCharm CE"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/pycharm.dmg "https://download.jetbrains.com/python/pycharm-community-latest-aarch64.dmg"
    hdiutil attach /tmp/pycharm.dmg
    cp -R "/Volumes/PyCharm CE/PyCharm CE.app" /Applications/
    hdiutil detach "/Volumes/PyCharm CE"
    rm /tmp/pycharm.dmg
    print_success "${app_name} has been installed successfully."
}

# Install Wireshark
install_wireshark() {
    local app_name="Wireshark"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/wireshark.dmg "https://www.wireshark.org/download/osx/Wireshark-latest-Arm-64.dmg"
    hdiutil attach /tmp/wireshark.dmg
    cp -R "/Volumes/Wireshark/Wireshark.app" /Applications/
    hdiutil detach "/Volumes/Wireshark"
    rm /tmp/wireshark.dmg
    print_success "${app_name} has been installed successfully."
}

# Install Android Studio
install_android_studio() {
    local app_name="Android Studio"

    if ! check_and_handle_installation "$app_name"; then
        return 0
    fi

    print_info "Downloading and installing ${app_name}..."
    curl -L -o /tmp/androidstudio.dmg "https://redirector.gvt1.com/edgedl/android/studio/install/latest/android-studio-latest-mac_arm.dmg"
    hdiutil attach /tmp/androidstudio.dmg
    cp -R "/Volumes/Android Studio/Android Studio.app" /Applications/
    hdiutil detach "/Volumes/Android Studio"
    rm /tmp/androidstudio.dmg
    print_success "${app_name} has been installed successfully."
}

# Main function to install all apps
main() {
    print_header "Official macOS Application Installer"
    print_alert "This script will install applications from official sources without package managers."
    echo ""

    # Parse the application lists from .env.global
    IFS=',' read -r -a BASIC_APPS <<< "${INSTALL_APPS_BASIC_MAC//\\}"
    IFS=',' read -r -a DEV_APPS <<< "${INSTALL_APPS_DEV_MAC//\\}"
    IFS=',' read -r -a OTHER_APPS <<< "${OTHER_APPS_TO_INSTALL_MAC//\\}"

    print_yellow "Choose installation mode:"
    echo "1. Install all applications"
    echo "2. Choose applications to install"
    echo "3. Exit"
    read -p "Enter your choice (1-3): " install_mode

    case $install_mode in
        1)
            print_success "Installing all applications..."

            # Basic Apps
            for app in "${BASIC_APPS[@]}"; do
                app=$(echo "$app" | tr -d ' ')
                case "$app" in
                    "google-chrome") install_google_chrome ;;
                    "zoom") install_zoom ;;
                    "flameshot") install_flameshot ;;
                    "rambox") install_rambox ;;
                    "spotify") install_spotify ;;
                    "obs") install_obs ;;
                    "google-drive") install_google_drive ;;
                    "alt-tab") install_alt_tab ;;
                    *) print_alert "No official installer function for $app" ;;
                esac
            done

            # Dev Apps
            for app in "${DEV_APPS[@]}"; do
                app=$(echo "$app" | tr -d ' ')
                case "$app" in
                    "visual-studio-code") install_visual_studio_code ;;
                    "postman") install_postman ;;
                    "dbeaver-community") install_dbeaver_community ;;
                    "intellij-idea-ce") install_intellij_idea_ce ;;
                    "pycharm-ce") install_pycharm_ce ;;
                    "wireshark") install_wireshark ;;
                    *) print_alert "No official installer function for $app" ;;
                esac
            done

            # Other Apps
            for app in "${OTHER_APPS[@]}"; do
                app=$(echo "$app" | tr -d ' ')
                case "$app" in
                    "android-studio") install_android_studio ;;
                    *) print_alert "No official installer function for $app" ;;
                esac
            done
            ;;

        2)
            print_yellow "Available applications:"
            print_info "Basic Apps:"
            echo "1. Google Chrome"
            echo "2. Zoom"
            echo "3. Flameshot"
            echo "4. Rambox"
            echo "5. Spotify"
            echo "6. OBS Studio"
            echo "7. Google Drive"
            echo "8. AltTab"

            print_info "Development Apps:"
            echo "9. Visual Studio Code"
            echo "10. Postman"
            echo "11. DBeaver Community"
            echo "12. IntelliJ IDEA CE"
            echo "13. PyCharm CE"
            echo "14. Wireshark"

            print_info "Other Apps:"
            echo "15. Android Studio"

            echo "0. Back to main menu"

            while true; do
                read -p "Enter the number of the application to install (0 to exit): " app_choice

                case $app_choice in
                    0) break ;;
                    1) install_google_chrome ;;
                    2) install_zoom ;;
                    3) install_flameshot ;;
                    4) install_rambox ;;
                    5) install_spotify ;;
                    6) install_obs ;;
                    7) install_google_drive ;;
                    8) install_alt_tab ;;
                    9) install_visual_studio_code ;;
                    10) install_postman ;;
                    11) install_dbeaver_community ;;
                    12) install_intellij_idea_ce ;;
                    13) install_pycharm_ce ;;
                    14) install_wireshark ;;
                    15) install_android_studio ;;
                    *) print_error "Invalid choice. Please try again." ;;
                esac
            done
            ;;

        3)
            print_alert "Exiting the installer."
            exit 0
            ;;

        *)
            print_error "Invalid choice. Exiting."
            exit 1
            ;;
    esac

    print_success "Installation process completed!"
}

# Run the main function
main