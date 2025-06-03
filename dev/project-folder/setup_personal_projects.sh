#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Source the utility scripts
source "$SCRIPT_DIR/../utils/colors_message.sh"
source "$SCRIPT_DIR/../utils/load_env.sh"

# Load environment variables
load_env

# Global variables for repository links
GITHUB_BASE_URL="git@github.com:davipeterlini"
GITHUB_ORG_BASE_URL="git@github.com"
GITHUB_OTHER_BASE_URL="org-14957082@github.com:openai"

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
        
        # Navigate to repo directory
        cd "$repo_path" || return
        
        # Check which branch is currently active
        local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
        
        if [ "$current_branch" = "main" ]; then
            # If on main branch, simply do a git pull
            print_info "Currently on main branch, pulling latest changes..."
            if git pull; then
                print_success "Updated repository: $repo_name"
            else
                print_error "Failed to update repository: $repo_name"
            fi
        else
            # If not on main branch, try to pull from origin main
            print_info "Currently on branch: $current_branch, pulling from origin main..."
            if git pull origin main 2> /tmp/git_error_output; then
                print_success "Pulled changes from main branch into $current_branch: $repo_name"
            else
                # Check if there are merge conflicts
                if grep -q "CONFLICT" /tmp/git_error_output; then
                    print_alert "MERGE CONFLICT: There are conflicts when pulling main into $current_branch in repository: $repo_name"
                    print_alert "Please resolve conflicts manually before continuing."
                else
                    print_error "Failed to pull from main branch: $repo_name"
                fi
            fi
        fi
        
        # Return to original directory
        cd - > /dev/null
    else
        # Check if the repository exists before attempting to clone
        print_info "Checking if repository exists: $repo_name"
        if git ls-remote "$repo_url" &> /dev/null; then
            print_info "Cloning repository: $repo_name"
            git clone "$repo_url" "$repo_path"
            if [ $? -eq 0 ]; then
                print_success "Repository cloned: $repo_name"
            else
                print_error "Failed to clone repository: $repo_name"
            fi
        else
            print_alert "Repository does not exist or is not accessible: $repo_name"
            print_info "Skipping repository: $repo_name"
        fi
    fi
}

# Main function to set up project structure
setup_personal_projects() {
    print_info "Setting up personal projects directory structure..."
    
    # Create base directory if it doesn't exist
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL"
    
    # Create and populate automation directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/"
    clone_or_update_repo "$GITHUB_BASE_URL/scripts-shell.git" "$PROJECT_DIR_PERSONAL/"
    clone_or_update_repo "$GITHUB_BASE_URL/project-starter.git" "$PROJECT_DIR_PERSONAL/"

    # Create platform directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/platform"

    # Create and populate subscription-club directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/subscription-club"
    clone_or_update_repo "$GITHUB_BASE_URL/subscription-club-mobile.git" "$PROJECT_DIR_PERSONAL/subscription-club"
    clone_or_update_repo "$GITHUB_BASE_URL/subscription-club-service.git" "$PROJECT_DIR_PERSONAL/subscription-club"
    clone_or_update_repo "$GITHUB_BASE_URL/subscription-club-mobile-app.git" "$PROJECT_DIR_PERSONAL/subscription-club"
    clone_or_update_repo "$GITHUB_BASE_URL/subscription-club-docs.git" "$PROJECT_DIR_PERSONAL/subscription-club"
    clone_or_update_repo "$GITHUB_BASE_URL/subscription-club-web-app.git" "$PROJECT_DIR_PERSONAL/subscription-club"
    clone_or_update_repo "$GITHUB_BASE_URL/subscription-club-desing-system.git" "$PROJECT_DIR_PERSONAL/subscription-club"
    clone_or_update_repo "$GITHUB_BASE_URL/subscription-club-iac.git" "$PROJECT_DIR_PERSONAL/subscription-club"

    # Create and populate pocs directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "$GITHUB_ORG_BASE_URL/mannaandpoem/OpenManus.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "$GITHUB_ORG_BASE_URL/ModelTC/lightllm.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "$GITHUB_ORG_BASE_URL/stackblitz/bolt.new.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "$GITHUB_ORG_BASE_URL/stackblitz-labs/bolt.diy.git" "$PROJECT_DIR_PERSONAL/pocs"
    clone_or_update_repo "$GITHUB_OTHER_BASE_URL/codex.git" "$PROJECT_DIR_PERSONAL/pocs"

    # Create and populate pocs replit directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/pocs-replit"
    clone_or_update_repo "$GITHUB_BASE_URL/poc-hub-app.git" "$PROJECT_DIR_PERSONAL/pocs-replit"
    clone_or_update_repo "$GITHUB_BASE_URL/LLMTester.git" "$PROJECT_DIR_PERSONAL/pocs-replit"
    clone_or_update_repo "$GITHUB_BASE_URL/poc-finance-track.git" "$PROJECT_DIR_PERSONAL/pocs-replit"
    clone_or_update_repo "$GITHUB_BASE_URL/poc-squad-pulse.git" "$PROJECT_DIR_PERSONAL/pocs-replit"
    clone_or_update_repo "$GITHUB_BASE_URL/poc-cli-replit.git" "$PROJECT_DIR_PERSONAL/pocs-replit"
    clone_or_update_repo "$GITHUB_BASE_URL/poc-prototyper-app.git" "$PROJECT_DIR_PERSONAL/pocs-replit"
    clone_or_update_repo "$GITHUB_BASE_URL/HealthTrackPlus.git" "$PROJECT_DIR_PERSONAL/pocs-replit"

    # Create and populate pocs-lovable directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/pocs-lovable"
    clone_or_update_repo "$GITHUB_BASE_URL/lifetrek-compass.git" "$PROJECT_DIR_PERSONAL/pocs-lovable"

    # Create and populate pocs-personal directory
    create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/pocs-personal"
    clone_or_update_repo "$GITHUB_BASE_URL/poc-model-local.git" "$PROJECT_DIR_PERSONAL/pocs-personal"
    clone_or_update_repo "$GITHUB_BASE_URL/poc-coder-cli.git" "$PROJECT_DIR_PERSONAL/pocs-personal"
    clone_or_update_repo "$GITHUB_BASE_URL/poc-google-calendar-to-notion.git" "$PROJECT_DIR_PERSONAL/pocs-personal"
    
    # Create and populate challenge directory
    #create_directory_if_not_exists "$PROJECT_DIR_PERSONAL/challenge"
    #clone_or_update_repo "$GITHUB_BASE_URL/code-challenge-nubank.git" "$PROJECT_DIR_PERSONAL/challenge"
    #clone_or_update_repo "$GITHUB_BASE_URL/desafio-mestre-ml-google.git" "$PROJECT_DIR_PERSONAL/challenge"

    print_success "Personal projects directory structure setup completed!"
}

# Execute the main function
setup_personal_projects