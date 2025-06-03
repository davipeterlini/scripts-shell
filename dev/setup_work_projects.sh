#!/bin/bash
# setup_work_projects.sh
# Purpose: Set up and maintain work project repositories

# Constants
SCRIPT_DIR=$(dirname "$(realpath "$0")")
readonly ERROR_LOG="/tmp/git_error_output"

# Import utilities
source "$(dirname "$0")/../utils/colors_message.sh"
source "$(dirname "$0")/../utils/load_env.sh"
source "$(dirname "$0")/../utils/bash_tools.sh"
source "$(dirname "$0")/../utils/manage_git_repo.sh"
source "$(dirname "$0")/../utils/list_projects.sh"
source "$(dirname "$0")/utils/load_dev_env.sh"

# Load environment variables
load_env

# Main script execution
main() {
    # Get user's choice between personal and work projects
    local project_type=$(list_projects)
    echo "Selected project type: $project_type"
    echo $HOME
    
    # Load environment variables based on user's choice
    load_dev_env "$project_type"
    
    # Now PROJECT_DIRS and PROJECT_REPOS will be set by load_dev_env
    # based on whether personal or work was selected
    
    if [[ "$project_type" == "work" ]]; then
        if [[ -z "$PROJECT_WORK_DIR" || -z "$PROJECT_WORK_REPOS" ]]; then
            print_error "Work project environment variables are not set. Please check your configuration."
            exit 1
        fi
        PROJECT_DIRS=$PROJECT_WORK_DIR
        PROJECT_REPOS=$PROJECT_WORK_REPOS
    elif [[ "$project_type" == "personal" ]]; then
        if [[ -z "$PROJECT_PERSONAL_DIR" || -z "$PROJECT_PERSONAL_REPOS" ]]; then
            print_error "Personal project environment variables are not set. Please check your configuration."
            exit 1
        fi
        PROJECT_DIRS=$PROJECT_PERSONAL_DIR
        PROJECT_REPOS=$PROJECT_PERSONAL_REPOS
    else
        print_error "Invalid project type: $project_type"
        exit 1
    fi

    create_directories "${!PROJECT_DIRS[@]}"  

    # Manage repositories
    manage_repositories "${PROJECT_REPOS[@]}"

    print_success "${project_type^} projects setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi