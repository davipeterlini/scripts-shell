#!/bin/bash

source "$(dirname "$0")/../../utils/colors_message.sh"

# Function to create directories
create_directories() {
    local directories=("$@")
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            print_info "Creating directory: $dir"
            mkdir -p "$dir"
            print_success "Directory created: $dir"
        else
            print_info "Directory already exists: $dir"
        fi
    done
}