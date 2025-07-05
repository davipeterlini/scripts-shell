#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Load colors for output
source "$(dirname "$0")/../utils/colors_message.sh"

# Function to ask for user confirmation
confirm_action() {
    local message=$1
    read -p "$(echo -e ${YELLOW_BOLD}"$message (y/n): "${NC})" choice
    case "$choice" in
        y|Y ) return 0;;
        * ) return 1;;
    esac
}

# Function to display menu and get user choice
display_menu() {
    local options=("$@")
    echo -e "${BLUE_BOLD}Select the apps to uninstall:${NC}"
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[i]}"
    done
    echo "$((${#options[@]}+1)). Uninstall all apps one by one"
    echo "$((${#options[@]}+2)). Exit"
    
    read -p "Enter your choice (comma-separated for multiple selections): " choices
    echo $choices
}

# Function to uninstall a Homebrew package
uninstall_brew_package() {
    local app_name=$1
    if brew list "$app_name" &>/dev/null; then
        if confirm_action "Do you want to uninstall $app_name using Homebrew?"; then
            print_info "Uninstalling $app_name using Homebrew..."
            brew uninstall "$app_name"
            print_success "$app_name uninstalled successfully."
        else
            print_alert "Skipping Homebrew uninstallation for $app_name."
        fi
    else
        print_alert "$app_name is not installed via Homebrew."
    fi
}

# Function to remove a .app bundle
remove_app_bundle() {
    local app_name=$1
    if [ -d "/Applications/$app_name.app" ]; then
        if confirm_action "Do you want to remove $app_name.app from /Applications?"; then
            print_info "Removing $app_name.app..."
            sudo rm -rf "/Applications/$app_name.app"
            print_success "$app_name.app removed successfully."
        else
            print_alert "Skipping removal of $app_name.app."
        fi
    else
        print_alert "$app_name.app not found in /Applications."
    fi
}

# Function to remove PKG installations
remove_pkg_installation() {
    local app_name=$1
    local pkg_receipt=$(pkgutil --pkgs | grep -i "$app_name")
    if [ -n "$pkg_receipt" ]; then
        if confirm_action "Do you want to remove the PKG installation for $app_name?"; then
            print_info "Removing PKG installation for $app_name..."
            sudo pkgutil --forget "$pkg_receipt"
            print_success "PKG installation for $app_name removed successfully."
        else
            print_alert "Skipping PKG uninstallation for $app_name."
        fi
    else
        print_alert "No PKG installation found for $app_name."
    fi
}

# Function to remove SH installations
remove_sh_installation() {
    local app_name=$1
    if [ -f "/usr/local/bin/$app_name" ]; then
        if confirm_action "Do you want to remove the SH installation for $app_name from /usr/local/bin?"; then
            print_info "Removing SH installation for $app_name..."
            sudo rm -f "/usr/local/bin/$app_name"
            print_success "SH installation for $app_name removed successfully."
        else
            print_alert "Skipping SH uninstallation for $app_name."
        fi
    else
        print_alert "No SH installation found for $app_name in /usr/local/bin."
    fi
}

# Function to remove ZIP installations
remove_zip_installation() {
    local app_name=$1
    if [ -d "/Applications/$app_name" ]; then
        if confirm_action "Do you want to remove the ZIP installation for $app_name from /Applications?"; then
            print_info "Removing ZIP installation for $app_name..."
            sudo rm -rf "/Applications/$app_name"
            print_success "ZIP installation for $app_name removed successfully."
        else
            print_alert "Skipping ZIP uninstallation for $app_name."
        fi
    else
        print_alert "No ZIP installation found for $app_name in /Applications."
    fi
}

# Function to identify installation method and call appropriate removal function
uninstall_app() {
    local app_name=$1
    print_info "Processing uninstallation for $app_name..."

    if brew list "$app_name" &>/dev/null; then
        uninstall_brew_package "$app_name"
    elif [ -d "/Applications/$app_name.app" ]; then
        remove_app_bundle "$app_name"
    elif pkgutil --pkgs | grep -q -i "$app_name"; then
        remove_pkg_installation "$app_name"
    elif [ -f "/usr/local/bin/$app_name" ]; then
        remove_sh_installation "$app_name"
    elif [ -d "/Applications/$app_name" ]; then
        remove_zip_installation "$app_name"
    else
        print_alert "Unable to determine installation method for $app_name. Skipping."
    fi

    if confirm_action "Do you want to perform a final cleanup for any remaining files of $app_name?"; then
        print_info "Cleaning up remaining files for $app_name..."
        sudo find /Applications /Library ~/Library -name "*$app_name*" -print0 | xargs -0 sudo rm -rf
        print_success "Final cleanup completed for $app_name."
    else
        print_alert "Skipping final cleanup for $app_name."
    fi
    
    print_success "Uninstallation process completed for $app_name."
}

# Main script execution
main() {
    # Check if UNINSTALL_APPS_MAC is defined in .env
    if [ -z "$UNINSTALL_APPS_MAC" ]; then
        print_error "UNINSTALL_APPS_MAC is not defined in the .env file."
        exit 1
    fi

    # Convert comma-separated string to array
    IFS=',' read -ra APPS_TO_UNINSTALL <<< "$UNINSTALL_APPS_MAC"

    if [ ${#APPS_TO_UNINSTALL[@]} -eq 0 ]; then
        print_error "No apps specified for uninstallation in UNINSTALL_APPS_MAC."
        exit 1
    fi

    # Display menu and get user choices
    choices=$(display_menu "${APPS_TO_UNINSTALL[@]}")
    
    # Process user choices
    IFS=',' read -ra selected_choices <<< "$choices"
    for choice in "${selected_choices[@]}"; do
        if [ "$choice" -eq $((${#APPS_TO_UNINSTALL[@]}+1)) ]; then
            # Uninstall all apps one by one
            for app in "${APPS_TO_UNINSTALL[@]}"; do
                if confirm_action "Do you want to process the uninstallation of $app?"; then
                    uninstall_app "$app"
                else
                    print_alert "Skipping uninstallation of $app."
                fi
            done
            break
        elif [ "$choice" -eq $((${#APPS_TO_UNINSTALL[@]}+2)) ]; then
            # Exit
            print_info "Exiting the uninstallation process."
            exit 0
        elif [ "$choice" -ge 1 ] && [ "$choice" -le ${#APPS_TO_UNINSTALL[@]} ]; then
            app="${APPS_TO_UNINSTALL[$((choice-1))]}"
            uninstall_app "$app"
        else
            print_error "Invalid choice: $choice"
        fi
    done

    print_success "All selected apps have been processed for uninstallation."
}

main