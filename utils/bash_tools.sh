#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors_message.sh"

# Function to create directories
create_directories() {
    local directories=("$@")
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            print_success "Creating directory: $dir"
            mkdir -p "$dir"
            print_success "Directory created: $dir"
        else
            print_info "Directory already exists: $dir"
        fi
    done
}