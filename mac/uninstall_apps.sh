#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Load colors for output
source "$(dirname "$0")/../utils/colors_message.sh"

# Function to uninstall a Homebrew package
uninstall_brew_package() {
    local app_name=$1
    if brew list "$app_name" &>/dev/null; then
        print_info "Uninstalling $app_name using Homebrew..."
        brew uninstall "$app_name"
        print_success "$app_name uninstalled successfully."
    else
        print_alert "$app_name is not installed via Homebrew."
    fi
}

# Function to remove a .app bundle
remove_app_bundle() {
    local app_name=$1
    if [ -d "/Applications/$app_name.app" ]; then
        print_info "Removing $app_name.app..."
        sudo rm -rf "/Applications/$app_name.app"
        print_success "$app_name.app removed successfully."
    else
        print_alert "$app_name.app not found in /Applications."
    fi
}

# Function to remove PKG installations
remove_pkg_installation() {
    local app_name=$1
    local pkg_receipt=$(pkgutil --pkgs | grep -i "$app_name")
    if [ -n "$pkg_receipt" ]; then
        print_info "Removing PKG installation for $app_name..."
        sudo pkgutil --forget "$pkg_receipt"
        print_success "PKG installation for $app_name removed successfully."
    else
        print_alert "No PKG installation found for $app_name."
    fi
}

# Function to remove SH installations (this is a general approach, might need adjustments)
remove_sh_installation() {
    local app_name=$1
    if [ -f "/usr/local/bin/$app_name" ]; then
        print_info "Removing SH installation for $app_name..."
        sudo rm -f "/usr/local/bin/$app_name"
        print_success "SH installation for $app_name removed successfully."
    else
        print_alert "No SH installation found for $app_name in /usr/local/bin."
    fi
}

# Function to remove ZIP installations (assuming they're extracted to /Applications)
remove_zip_installation() {
    local app_name=$1
    if [ -d "/Applications/$app_name" ]; then
        print_info "Removing ZIP installation for $app_name..."
        sudo rm -rf "/Applications/$app_name"
        print_success "ZIP installation for $app_name removed successfully."
    else
        print_alert "No ZIP installation found for $app_name in /Applications."
    fi
}

# Main uninstall function
uninstall_app() {
    local app_name=$1
    print_info "Uninstalling $app_name..."

    # Try all removal methods
    uninstall_brew_package "$app_name"
    remove_app_bundle "$app_name"
    remove_pkg_installation "$app_name"
    remove_sh_installation "$app_name"
    remove_zip_installation "$app_name"

    # Clean up any remaining files
    print_info "Cleaning up remaining files for $app_name..."
    sudo find /Applications /Library ~/Library -name "*$app_name*" -print0 | xargs -0 sudo rm -rf
    
    print_success "Uninstallation process completed for $app_name."
}

# Main script execution
main() {
    if [ $# -eq 0 ]; then
        print_error "Please provide at least one app name to uninstall."
        exit 1
    fi

    for app in "$@"; do
        uninstall_app "$app"
    done

    print_success "All specified apps have been processed for uninstallation."
}

main "$@"