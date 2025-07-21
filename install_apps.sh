#!/bin/bash

# Load Scripts
set -e # Exit script if any command fails

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="${SCRIPTS_DIR}/utils"

source "${UTILS_DIR}/load_env.sh"
source "${UTILS_DIR}/detect_os.sh"
source "${UTILS_DIR}/colors_message.sh"
source "${UTILS_DIR}/display_menu.sh"
source "${UTILS_DIR}//bash_tools.sh"

source "$(dirname "$0")/mac/install_homebrew.sh"
source "$(dirname "$0")/mac/install_brew_apps.sh"

source "$(dirname "$0")/linux/install_flatpak_apps.sh"
source "$(dirname "$0")/linux/install_aptget_apps.sh"
source "$(dirname "$0")/linux/update_flatpak_apps.sh"
source "$(dirname "$0")/linux/update_aptget_apps.sh"

handle_macos_installation() {
    install_homebrew
    
    display_menu
    local choices="$MENU_CHOICES"
    
    print_info "Selected choices: $choices"

    if [[ "$choices" == *"1"* ]]; then
        install_brew_apps $(echo "$INSTALL_APPS_BASIC_MAC" | tr ',' ' ')
    fi
    if [[ "$choices" == *"2"* ]]; then
        install_brew_apps $(echo "$INSTALL_APPS_BASIC_MAC" | tr ',' ' ')
    fi
    if [[ "$choices" == *"3"* ]]; then
        install_brew_apps $(echo "$INSTALL_APPS_BASIC_MAC,$INSTALL_APPS_DEV_MAC,$OTHER_APPS_TO_INSTALL_MAC" | tr ',' ' ')
    fi
}

# TODO - test on linux to verify if it's working
# TODO - see perspective for flatpak usage (discas-l via email)
handle_linux_installation() {
    echo "LINUX detected."
    update_flatpak_apps
    update_aptget_apps

    display_menu
    local choices="$MENU_CHOICES"
    
    print_info "Selected choices: $choices"

    if [[ "$choices" == *"1"* ]]; then
        install_flatpak_apps $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT" | tr ',' ' ')
        install_aptget_apps $(echo "$INSTALL_APPS_BASIC_LINUX_APT" | tr ',' ' ')
    fi
    if [[ "$choices" == *"2"* ]]; then
        install_flatpak_apps $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT" | tr ',' ' ')
        install_aptget_apps $(echo "$INSTALL_APPS_BASIC_LINUX_APT" | tr ',' ' ')
    fi
    if [[ "$choices" == *"3"* ]]; then
       install_flatpak_apps $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT,$INSTALL_APPS_BASIC_LINUX_FLAT_DEV" | tr ',' ' ')
        install_aptget_apps $(echo "$INSTALL_APPS_BASIC_LINUX_APT,$INSTALL_APPS_BASIC_LINUX_APT_DEV" | tr ',' ' ')
    fi
}

# TODO - add Windows verification to install windows scripts
# Main function named after the script for reusability
install_apps() {
    print_header "Install Apps on OS"

    if ! get_user_confirmation "Install Apps on OS?"; then
        print_info "Skipping install"
        return 0
    fi

    load_env .env.global
    local os="$1"

    if [[ -z "$os" ]]; then
        detect_os
    fi

    os="$OS_NAME"

    print_header "Install Apps"

    if [[ "$os" == "macOS" ]]; then
        handle_macos_installation
    elif [[ "$os" == "Linux" ]]; then
        handle_linux_installation
    else
        print_error "Unsupported operating system: $os"
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_apps "$@"
fi