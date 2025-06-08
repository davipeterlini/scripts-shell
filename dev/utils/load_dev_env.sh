#!/bin/bash

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/../utils/colors_message.sh"

# Function to display environment options and let the user choose
select_environment() {
     
    env_dir="$PROJECT_ROOT/assets"
    env_files=("$env_dir/.env.personal" "$env_dir/.env.work")
    print_info "Select an environment:"
    select env_file in "${env_files[@]}"; do
        if [ -n "$env_file" ]; then
            print_success "You selected $env_file"
            return 
        else
            print_error "Invalid selection. Try again."
        fi
    done
}