#!/bin/bash

source "$(dirname "$0")/mac/install_homebrew.sh"
source "$(dirname "$0")/utils/colors_message.sh"

# Function to install apps using Homebrew
_install_brew_apps() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        brew install "$app"
    done
}

# Main script execution
install_brew_apps() {
    install_homebrew

    # Display the list of apps to be installed
    print_info "As seguintes aplicações serão instaladas:"
    for app in "$@"; do
        print "- $app"
    done
    
    # Ask for confirmation before proceeding
    read -p "Deseja continuar com a instalação? (s/n): " confirm
    if [[ "$confirm" =~ ^[Ss]$ ]]; then
        print_info "Iniciando instalação..."
        _install_brew_apps "$@"
    else
        print_alert "Instalação cancelada."
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_brew_apps "$@"
fi