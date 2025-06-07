#!/bin/bash

# Script to configure the ~/.ssh/config file with configurations from the github/assets folder
# Replaces the $HOME environment variable with the actual home directory of the user

# Import color utility
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/utils/colors_message.sh"

# Assets directory
ASSETS_DIR="$SCRIPT_DIR/assets"

print_info "SSH Configuration for GitHub"

# Check if the ~/.ssh directory exists, if not, create it
if [ ! -d "$HOME/.ssh" ]; then
    print_info "Creating ~/.ssh directory..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    print_success "~/.ssh directory successfully created!"
fi

# Backup the existing configuration file, if any
if [ -f "$HOME/.ssh/config" ]; then
    print_info "Backing up the existing ~/.ssh/config file..."
    BACKUP_FILE="$HOME/.ssh/config.backup.$(date +%Y%m%d%H%M%S)"
    cp "$HOME/.ssh/config" "$BACKUP_FILE"
    print_success "Backup created: $BACKUP_FILE"
fi

# Check if the assets directory exists
if [ ! -d "$ASSETS_DIR" ]; then
    print_error "Assets directory not found at $ASSETS_DIR."
    exit 1
fi

# Debug: Display the path of the assets directory
print_info "Assets directory path: $ASSETS_DIR"

# List available files in the assets folder
print_info "Version Selection"
print_info "Available files in the assets folder:"
FILES=($(find "$ASSETS_DIR" -type f 2>/dev/null))

# Debug: Display the found files
if [ ${#FILES[@]} -eq 0 ]; then
    print_error "No files found in the assets folder."
    exit 1
else
    print_info "Found files:"
    for file in "${FILES[@]}"; do
        print_info "- $file"
    done
fi

# Display the files as numbered options
i=1
for file in "${FILES[@]}"; do
    print_info "${i}) $file"
    ((i++))
done

# Prompt the user to choose a file
read -p "$(print_info "Choose a file by number: ")" choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#FILES[@]} ]; then
    print_alert "Invalid option. Operation canceled."
    exit 1
fi

CONFIG_FILE="${FILES[$((choice-1))]}"
CONFIG_PATH="$CONFIG_FILE"

if [ ! -f "$CONFIG_PATH" ]; then
    print_error "Configuration file $CONFIG_PATH not found."
    exit 1
fi

print_success "Using configuration file: $CONFIG_FILE"

# Replace the $HOME variable with the actual value and save it to the ~/.ssh/config file
print_info "Configuring SSH"
print_info "Setting up ~/.ssh/config file..."
sed "s|\$HOME|$HOME|g" "$CONFIG_PATH" > "$HOME/.ssh/config"

# Set the correct permissions for the configuration file
chmod 600 "$HOME/.ssh/config"
print_success "File permissions set to 600 (read/write only for the owner)"

print_info "Configuration Completed"
print_success "The ~/.ssh/config file has been configured using $CONFIG_FILE"
print_info "The $HOME environment variable has been replaced with the actual value: $HOME"

# Display the content of the configured file
print_info "Configured File Content"
cat "$HOME/.ssh/config"

print_success "Operation Successfully Completed!"