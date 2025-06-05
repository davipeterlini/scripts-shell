#!/bin/bash

# Import color utility
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/utils/colors_message.sh"

# Constants
ASSETS_DIR="$SCRIPT_DIR/assets/ssh-git"
SSH_CONFIG_DIR="$HOME/.ssh"
SSH_CONFIG_FILE="$SSH_CONFIG_DIR/config"

# Functions
create_ssh_directory() {
    if [ ! -d "$SSH_CONFIG_DIR" ]; then
        print_info "Creating SSH directory at $SSH_CONFIG_DIR..."
        mkdir -p "$SSH_CONFIG_DIR"
        chmod 700 "$SSH_CONFIG_DIR"
        print_success "SSH directory created successfully!"
    fi
}

backup_existing_config() {
    if [ -f "$SSH_CONFIG_FILE" ]; then
        local backup_file="$SSH_CONFIG_FILE.backup.$(date +%Y%m%d%H%M%S)"
        print_info "Backing up existing SSH config to $backup_file..."
        cp "$SSH_CONFIG_FILE" "$backup_file"
        print_success "Backup created: $backup_file"
    fi
}

list_assets_files() {
    if [ ! -d "$ASSETS_DIR" ]; then
        print_error "Assets directory not found at $ASSETS_DIR."
        exit 1
    fi

    local files=($(find "$ASSETS_DIR" -type f -name "config-ssh-*" 2>/dev/null | sort))

    if [ ${#files[@]} -eq 0 ]; then
        print_error "No configuration files found in the assets directory."
        exit 1
    fi

    echo "${files[@]}"
}

display_files_with_index() {
    local files=("$@")
    print_info "Available configuration files:"
    for i in "${!files[@]}"; do
        local filename=$(basename "${files[$i]}")
        print "$((i + 1))) $filename"
    done
}

get_user_choice() {
    local files=("$@")
    read -p "$(print_info "Choose a configuration file by number: ")" choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#files[@]} ]; then
        print_alert "Invalid option. Operation canceled."
        exit 1
    fi

    echo "${files[$((choice - 1))]}"
}

configure_ssh() {
    local config_file=$1

    if [ ! -f "$config_file" ]; then
        print_error "Configuration file $config_file not found."
        exit 1
    fi

    print_info "Configuring SSH with $config_file..."
    
    # Replace $HOME with actual home directory path
    sed "s|\$HOME|$HOME|g" "$config_file" > "$SSH_CONFIG_FILE"
    
    # Ensure proper permissions
    chmod 600 "$SSH_CONFIG_FILE"
    print_success "SSH configuration updated successfully!"
}

display_config_content() {
    print_info "Configured SSH File Content:"
    cat "$SSH_CONFIG_FILE"
}

main() {
    print_header "Starting SSH Configuration for GitHub"

    create_ssh_directory
    backup_existing_config

    files=($(list_assets_files))
    display_files_with_index "${files[@]}"

    selected_file=$(get_user_choice "${files[@]}")
    configure_ssh "$selected_file"
    display_config_content
    
    print
    print
    print_success "SSH Configuration Completed Successfully!"
}

# Execute main function
main