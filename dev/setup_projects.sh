#!/bin/bash
# setup_projects.sh
# Purpose: Set up and maintain project repositories

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/utils/colors_message.sh"
source "$PROJECT_ROOT/utils/load_env.sh"
source "$PROJECT_ROOT/utils/bash_tools.sh"
source "$PROJECT_ROOT/utils/manage_git_repo.sh"

# Function to display environment options and let the user choose
select_environment() {
    env_dir="$PROJECT_ROOT/dev/assets"
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

# Main script execution
setup_projects() {
    # Select environment
    select_environment
    selected_env=$env_file

    # Load the selected environment variables
    if [ -f "$selected_env" ]; then
        set -a
        source "$selected_env"
        set +a
    else
        print_error "Environment file not found: $selected_env"
        exit 1
    fi

    # Validate required variables
    if [ -z "$PROJECT_DIR" ] || [ -z "$PROJECT_REPOS" ]; then
        print_error "PROJECT_DIR or PROJECT_REPOS is not defined in the selected .env file. Exiting."
        exit 1
    fi

    # Create directories
    create_directories "${PROJECT_DIR[@]}"

    # for repo in "${PROJECT_REPOS[@]}"; do
    #     print "$repo"
    # done

    manage_repositories "${PROJECT_REPOS[@]}"

    print_success "Project setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_projects "$@"
fi