#!/bin/bash

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

enable_touchid_sudo() {
    print_header_info "Enable Touch ID for sudo"

    if ! get_user_confirmation "Do you want to enable Touch ID for sudo?"; then
        print_info "Skipping Touch ID configuration"
        return 0
    fi

    PAM_FILE="/etc/pam.d/sudo"
    TOUCHID_LINE="auth       sufficient     pam_tid.so"

    # Check if line already exists - use sudo to read the protected file
    if sudo grep -Fxq "$TOUCHID_LINE" "$PAM_FILE"; then
        print_success "Touch ID is already enabled for sudo."
        return 0
    fi

    # If we got here, the line doesn't exist and we need to add it
    print_header_info "Enabling Touch ID for sudo..."
    
    # Create backup of original file with sudo
    local backup_file="$PAM_FILE.backup.$(date +%Y%m%d%H%M%S)"
    if sudo cp "$PAM_FILE" "$backup_file"; then
        print_info "Backup created: $backup_file"
    else
        print_error "Failed to create backup file. Aborting."
        return 1
    fi

    # Create a temporary file that we'll use to modify the PAM file
    local temp_file=$(mktemp)
    echo "$TOUCHID_LINE" > "$temp_file"
    sudo cat "$PAM_FILE" >> "$temp_file"
    
    # Use sudo to move the temporary file to the PAM file
    if sudo mv "$temp_file" "$PAM_FILE"; then
        print_success "Touch ID successfully enabled for sudo!"
    else
        print_error "Failed to update $PAM_FILE. Restoring from backup..."
        sudo mv "$backup_file" "$PAM_FILE"
        print_error "Operation failed."
        return 1
    fi
    
    return 0
}

# If this script is run directly, execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    enable_touchid_sudo "$@"
fi