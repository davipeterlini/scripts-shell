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
        
        # Try to pull from origin main, master, or develop
        if git pull origin main; then
            print_success "Updated repository from main branch: $repo_name"
        elif git pull origin master; then
            print_success "Updated repository from master branch: $repo_name"
        elif git pull origin develop; then
            print_success "Updated repository from develop branch: $repo_name"
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
setup_work_projects() {
    print_info "Setting up work projects directory structure..."
    
    # Create base directory if it doesn't exist
    create_directory_if_not_exists "$PROJECT_DIR_WORK"
    
    # Create flow directory structure
    create_directory_if_not_exists "$PROJECT_DIR_WORK/flow"
    create_directory_if_not_exists "$PROJECT_DIR_WORK/flow/chat"
    create_directory_if_not_exists "$PROJECT_DIR_WORK/flow/ai-core"
    create_directory_if_not_exists "$PROJECT_DIR_WORK/flow/coder"
    create_directory_if_not_exists "$PROJECT_DIR_WORK/flow/coder/cases"
    create_directory_if_not_exists "$PROJECT_DIR_WORK/flow/coder/mcp-server"
    create_directory_if_not_exists "$PROJECT_DIR_WORK/flow/coder/pocs"
    
    # Clone flow repositories
    # Note: Replace these with your actual work repositories
    clone_or_update_repo "git@github.com:CI-T-HyperX/flow-channels-app-service.git" "$PROJECT_DIR_WORK/flow/chat"
    clone_or_update_repo "git@github.com:CI-T-HyperX/flow-core-app-llm-service.git" "$PROJECT_DIR_WORK/flow/ai-core"
    # Flow Coder CLI
    clone_or_update_repo "git@github.com:CI-T-HyperX/flow-coder-framework.git" "$PROJECT_DIR_WORK/flow/coder"
    # Flow Coder Service
    clone_or_update_repo "git@github.com:CI-T-HyperX/flow-coder-service.git" "$PROJECT_DIR_WORK/flow/coder"
    # Flow Coder Extension
    clone_or_update_repo "git@bitbucket.org:ciandt_it/flow-coder-extension.git" "$PROJECT_DIR_WORK/flow/coder"
    # Flow Coder Cases
    clone_or_update_repo "git@github.com:davipeterlinicit/case-end-to-end-ops.git" "$PROJECT_DIR_WORK/flow/coder/cases"
    clone_or_update_repo "git@github.com:laisbonafeciandt/case-end-to-end-metrics.git" "$PROJECT_DIR_WORK/flow/coder/cases"
    clone_or_update_repo "git@github.com:arysanchez/case-end-to-end-chat.git" "$PROJECT_DIR_WORK/flow/coder/cases"
    clone_or_update_repo "git@github.com:davipeterlinicit/coder-cases.git" "$PROJECT_DIR_WORK/flow/coder/cases"
    clone_or_update_repo "git@github.com:CI-T-HyperX/flow-core-lib-commons-py.git" "$PROJECT_DIR_WORK/flow/coder/cases"
    # Flow Coder POCs
    clone_or_update_repo "git@github.com:continuedev/continue.git" "$PROJECT_DIR_WORK/flow/coder/pocs"
    # Flow MCP Server
    clone_or_update_repo "git@github.com:CI-T-HyperX/mcp-ciandt-flow.git" "$PROJECT_DIR_WORK/flow/coder/mcp-server"

    print_success "Work projects directory structure setup completed!"
    print_info "Note: You may need to add specific repositories to clone in this script."
}

# Execute the main function
setup_work_projects