#!/bin/bash
# setup_work_projects.sh
# Purpose: Set up and maintain work project repositories

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
source "$PROJECT_ROOT/utils/colors_message.sh"


# Import utilities
source "$PROJECT_ROOT/utils/colors_message.sh"
source "$PROJECT_ROOT/utils/load_env.sh"
source "$PROJECT_ROOT/utils/bash_tools.sh"
source "$PROJECT_ROOT/utils/manage_git_repo.sh"
source "./dev/utils/load_dev_env.sh"

# Load environment variables
load_env

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
setup_projects_main() {
    # Get user's choice between personal and work projects
    local project_type="$1"
    local project_name="$2"
    local asset_file="$3"

    #print_info "Selected project type: $project_type"

    # Load environment variables based on user's choice
    load_dev_env

    # If project_name and asset_file are provided, select environment based on project
    if [[ -n "$project_name" && -n "$asset_file" ]]; then
        select_env_based_on_project "$project_name" "$asset_file"
    fi

    # Validate environment variables
    validate_env_variables "$project_type"

    # Create directories and manage repositories
    create_directories "${!PROJECT_DIRS[@]}"
    manage_repositories "${PROJECT_REPOS[@]}"

    print_success "${project_type^} projects setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_projects_main "$@"
fi