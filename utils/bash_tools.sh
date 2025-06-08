#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors_message.sh"

# Function to create directories
create_directories() {
    local ROOT_DIR="$1"
    local directories=("$@")
    for dir in "${directories[@]}"; do
        full_dir="${ROOT_DIR}/${dir}"
        print_header $full_dir
        if [[ ! -d "$full_dir" ]]; then
            print_info "Creating directory: $full_dir"
            mkdir -p "$full_dir"
            print_success "Directory created: $full_dir"
        else
            print_info "Directory already exists: $full_dir"
        fi
    done
}