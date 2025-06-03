#!/bin/bash
# setup_work_projects.sh
# Purpose: Set up and maintain work project repositories

# Constants
readonly SCRIPT_DIR=$(dirname "$(realpath "$0")")
readonly ERROR_LOG="/tmp/git_error_output"

# Import utilities
source "$SCRIPT_DIR/../utils/colors_message.sh"
source "$SCRIPT_DIR/../utils/load_env.sh"
source "$SCRIPT_DIR/../utils/bash_tools.sh"
source "$SCRIPT_DIR/../utils/manage_git_repo.sh"
source "$SCRIPT_DIR/../utils/list_projects.sh"
source "$SCRIPT_DIR/utils/load_dev_env.sh"

# Load environment variables
load_env

# Function to display project selection and exit
display_project_selection() {
    print_info "Please select a project type:"
    list_projects
    print_info "Script execution paused. Please provide your selection."
    exit 0
}

# Function to validate environment variables
validate_env_variables() {
    local project_type="$1"

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
}

# Main script execution
main() {
    # Display project selection and exit
    display_project_selection

    # Get user's choice between personal and work projects
    local project_type="$1"
    print_info "Selected project type: $project_type"

    # Load environment variables based on user's choice
    load_dev_env "$project_type"

    # Validate environment variables
    validate_env_variables "$project_type"

    # Create directories and manage repositories
    create_directories "${!PROJECT_DIRS[@]}"
    manage_repositories "${PROJECT_REPOS[@]}"

    print_success "${project_type^} projects setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi