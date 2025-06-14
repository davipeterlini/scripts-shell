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

source "$(dirname "$0")/utils/load_dev_env.sh"

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
    create_directories "$PROJECT_DIR" "${PROJECT_DIRS[@]}"

    manage_repositories "${PROJECT_REPOS[@]}"

    print_success "Project setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_projects "$@"
fi