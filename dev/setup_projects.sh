#!/bin/bash

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/utils/manage_git_repo.sh"

# Function to display environment selection menu with exit option
select_environment_with_exit() {
    env_dir="$PROJECT_ROOT/assets"
    env_files=("$env_dir/.env.personal" "$env_dir/.env.work" "Exit")
    
    while true; do
        print_info "Select an environment:"
        select env_file in "${env_files[@]}"; do
            if [ -n "$env_file" ]; then
                if [ "$env_file" = "Exit" ]; then
                    print_info "Exiting project configuration"
                    return 1
                else
                    print_success "You selected $env_file"
                    return 0
                fi
            else
                print_error "Invalid selection. Try again."
            fi
        done
    done
}

# Function to manage repositories - Update or Clone repo
symbolic_link() {
   # Process arguments in pairs (target_dir and repo_url)
   while [[ $# -ge 2 ]]; do
       local repo_url="$1"
       local target_dir="$2"
       shift 2

       local repo_name=$(basename "$repo_url" .git)
       local project_root="$(dirname "$target_dir")"
       local repo_path="$target_dir/$repo_name"

       if [[ -d "$repo_path" ]]; then
           no_commit_symbolic_link "$repo_path"
       else
           print_error "no repo found $repo_path"
       fi
   done
}

# Function to update a repository
update_rno_commit_symbolic_linkepository() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")

    print_info "Create Symbolyc Link Inside of repository: $repo_name"
    if (cd "$repo_path"); then
        
        print_success "Repository updated successfully: $repo_name"
    else
        print_warning "Failed to update repository: $repo_name. Continuing with next repository."
    fi
}

# Main script execution
setup_projects() {
    print_header_info "Starting Project Configuration"

    if ! confirm_action "Do you want Project Configuration ?"; then
        print_info "Skipping configuration"
        return 0
    fi
    
    load_env .env.personal
    load_env .env.work
    
    # Loop until user chooses to exit
    while true; do
        # Select environment with exit option
        select_environment_with_exit
        
        # Check if user chose to exit
        if [ $? -eq 1 ]; then
            break
        fi
        
        selected_env=$env_file

        # Load the selected environment variables
        if [ -f "$selected_env" ]; then
            set -a
            source "$selected_env"
            set +a
        else
            print_error "Environment file not found: $selected_env"
            continue
        fi

        # Validate required variables
        if [ -z "$PROJECT_DIR" ] || [ -z "$PROJECT_REPOS" ]; then
            print_error "PROJECT_DIR or PROJECT_REPOS is not defined in the selected .env file."
            continue
        fi

        # Create directories
        create_directories "$PROJECT_DIR" "${PROJECT_DIRS[@]}"

        # Manage repositories
        manage_repositories "${PROJECT_REPOS[@]}"

        symbolic_link "${PROJECT_REPOS[@]}"

        print_success "Project setup completed successfully!"
        
        # Ask if user wants to continue with another environment
        if ! confirm_action "Do you want to configure another environment?"; then
            break
        fi
    done
    
    print_info "Continuing with the rest of the setup..."
    return 1
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_projects "$@"
fi