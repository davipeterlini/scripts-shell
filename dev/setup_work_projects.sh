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

PROJECT_DIRS="teste"
PROJECT_REPOS="teste"

# TODO - precisa pegar automaticamento do env de acordo com a escolha do user se personal ou se work
check_variable_exists() { 
    if [[ -z "$PROJECT_WORK_DIR" ]]; then
        print_error "PROJECT_WORK_DIR environment variable is not set. Please check your root .env file."
        exit 1
    fi

    if [[ -z "$PROJECT_WORK_REPOS" ]]; then
        print_error "PROJECT_WORK_REPOS environment variable is not set. Please check your root .env file."
        exit 1
    fi

    PROJECT_DIRS=$PROJECT_WORK_REPOS
    ROJECT_REPOS=$PROJECT_WORK_DIR  
}

# Main script execution
main() {
    list_projects
    echo $HOME

    check_variable_exists

    create_directories "${!PROJECT_DIRS[@]}"  

    # Manage repositories
    manage_repositories "${PROJECT_REPOS[@]}"

    print_success "Work projects setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi