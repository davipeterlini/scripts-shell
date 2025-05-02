#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Source the utility scripts
source "$SCRIPT_DIR/utils/colors_message.sh"
source "$SCRIPT_DIR/utils/load_env.sh"

# Load environment variables
load_env

# Function to create directory if it doesn't exist
create_directory_if_not_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        print_info "Creating directory: $dir"
        mkdir -p "$dir"
        print_success "Directory created: $dir"
    else
        print_info "Directory already exists: $dir"
    fi
}

# Function to clone or update repository
clone_or_update_repo() {
    local repo_url="$1"
    local target_dir="$2"
    
    # Extract repo name from URL
    local repo_name=$(basename "$repo_url" .git)
    local repo_path="$target_dir/$repo_name"
    
    if [ -d "$repo_path" ]; then
        print_info "Repository already exists: $repo_name"
        print_info "Updating repository..."
        
        # Navigate to repo directory and pull latest changes
        cd "$repo_path" || return
        
        # Check which branch is currently active
        local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
        
        # Try to pull from origin main or master
        if git pull origin main; then
            print_success "Updated repository from main branch: $repo_name"
        elif git pull origin master; then
            print_success "Updated repository from master branch: $repo_name"
        else
            print_alert "Could not update repository: $repo_name. Staying on branch: $current_branch"
        fi
        
        # Return to original directory
        cd - > /dev/null
    else
        print_info "Cloning repository: $repo_name"
        git clone "$repo_url" "$repo_path"
        if [ $? -eq 0 ]; then
            print_success "Repository cloned: $repo_name"
        else
            print_error "Failed to clone repository: $repo_name"
        fi
    fi
}

# Main function to set up project structure
setup_personal_projects() {
    print_info "Setting up personal projects directory structure..."
    
    # Create base directory if it doesn't exist
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL"
    
    # Create and populate automation directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/automation"
    clone_or_update_repo "git@github.com:davipeterlini/scripts-shell.git" "$PROJECT_DIR_PERSONAL/automation"
    clone_or_update_repo "git@github.com:davipeterlini/project-starter.git" "$PROJECT_DIR_PERSONAL/automation"
    
    # Create and populate challenge directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/challenge"
    clone_or_update_repo "git@github.com:davipeterlini/code-challenge-nubank.git" "$PROJECT_DIR_PERSONAL/challenge"
    clone_or_update_repo "git@github.com:davipeterlini/desafio-mestre-ml-google.git" "$PROJECT_DIR_PERSONAL/challenge"
    
    # Create platform directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/platform"
    
    # Create and populate pocs directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/pocs-personal"
    clone_or_update_repo "git@github.com:davipeterlini/poc-hub-app.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "git@github.com:davipeterlini/LLMTester.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "git@github.com:davipeterlini/poc-finance-track.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "git@github.com:davipeterlini/poc-squad-pulse.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "git@github.com:davipeterlini/poc-cli-replit.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "git@github.com:davipeterlini/poc-prototyper-app.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "git@github.com:davipeterlini/poc-model-local.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "git@github.com:davipeterlini/poc-coder-cli.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "git@github.com:davipeterlini/poc-google-calendar-to-notion.git" "$PROJECT_DIR_PERSONAL/pocs"
    
    # Create and populate subscription-club directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/subscription-club"
    clone_or_update_repo "git@github.com:davipeterlini/HealthTrackPlus.git" "$PROJECT_DIR_PERSONAL/subscription-club"
    clone_or_update_repo "git@github.com:davipeterlini/lifetrek-compass.git" "$PROJECT_DIR_PERSONAL/subscription-club"
    
    print_success "Personal projects directory structure setup completed!"
}

# Execute the main function
setup_personal_projects