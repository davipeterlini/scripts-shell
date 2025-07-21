#!/bin/bash

# Import color utilities for messages
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

# Function to enable Touch ID for sudo
enable_touchid_sudo() {
    print_header_info "Enable Touch ID for sudo"

    if ! get_user_confirmation "Do you want to enable Touch ID for sudo?"; then
        print_info "Skipping Touch ID configuration"
        return 0
    fi

    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root: sudo $0"
        exit 1
    fi

    PAM_FILE="/etc/pam.d/sudo"
    TOUCHID_LINE="auth       sufficient     pam_tid.so"

    # Check if line already exists
    if grep -Fxq "$TOUCHID_LINE" "$PAM_FILE"; then
        print_success "Touch ID is already enabled for sudo."
        # Do nothing more, just return
        return 1
    fi

    # If we got here, the line doesn't exist and we need to add it
    print_header_info "Enabling Touch ID for sudo..."
    
    # Create backup of original file
    local backup_file="$PAM_FILE.backup.$(date +%Y%m%d%H%M%S)"
    cp "$PAM_FILE" "$backup_file"
    print_info "Backup created: $backup_file"

    # Insert line at top of file
    (echo "$TOUCHID_LINE"; cat "$PAM_FILE") > "$PAM_FILE.tmp" && mv "$PAM_FILE.tmp" "$PAM_FILE"

    print_success "Touch ID successfully enabled for sudo!"
    
    return 1
}

# Execute script only if not being imported
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    enable_touchid_sudo "$@"
fi