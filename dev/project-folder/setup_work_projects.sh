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
source "$(dirname "$0")/../../utils/list_projects.sh"

# Load environment variables
load_env

# TODO - precisa pegar automaticamento do env de acordo com a escolha do user se personal ou se work
check_exist_var() { 
    if [[ -z "$PROJECT_WORK_DIR" ]]; then
        print_error "PROJECT_WORK_DIR environment variable is not set. Please check your root .env file."
        exit 1
    fi

    if [[ -z "$PROJECT_WORK_REPOS" ]]; then
        print_error "PROJECT_WORK_REPOS environment variable is not set. Please check your root .env file."
        exit 1
    fi
}

# Main script execution
main() {
    list_projects
    echo $HOME

    check_exist_var

    # Convert PROJECT_WORK_REPOS from a comma-separated string to an associative array
    declare -A REPOSITORIES
    IFS=',' read -ra REPO_PAIRS <<< "$PROJECT_WORK_REPOS"
    for pair in "${REPO_PAIRS[@]}"; do
        IFS='=' read -r dir repo <<< "$pair"
        REPOSITORIES["$dir"]="$repo"
    done

    # Create directories
    create_directories "${!PROJECT_WORK_DIR[@]}"

    # Manage repositories
    manage_repositories "${REPOSITORIES[@]}"

    print_success "Work projects setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi