#!/bin/bash
# setup_work_projects.sh
# Purpose: Set up and maintain work project repositories

# Constants
SCRIPT_DIR=$(dirname "$(realpath "$0")")
readonly ERROR_LOG="/tmp/git_error_output"

# Import utilities
source "$(dirname "$0")/../../utils/colors_message.sh"
source "$(dirname "$0")/../../utils/load_env.sh"
source "$(dirname "$0")/../../utils/bash_tools.sh"
source "$(dirname "$0")/../../utils/manage_git_repo.sh"

# Load environment variables
load_env

# Main script execution
main() {
    if [[ -z "$PROJECT_DIR_WORK" ]]; then
        print_error "PROJECT_DIR_WORK environment variable is not set. Please check your root .env file."
        exit 1
    fi

    if [[ -z "$REPOSITORIES_WORK" ]]; then
        print_error "REPOSITORIES_WORK environment variable is not set. Please check your root .env file."
        exit 1
    fi

    # Convert REPOSITORIES_WORK from a comma-separated string to an associative array
    declare -A REPOSITORIES
    IFS=',' read -ra REPO_PAIRS <<< "$REPOSITORIES_WORK"
    for pair in "${REPO_PAIRS[@]}"; do
        IFS='=' read -r dir repo <<< "$pair"
        REPOSITORIES["$dir"]="$repo"
    done

    # Create directories
    create_directories "${!REPOSITORIES[@]}"

    # Manage repositories
    manage_repositories "${REPOSITORIES[@]}"

    print_success "Work projects setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi