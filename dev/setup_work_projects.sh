#!/bin/bash
# setup_work_projects.sh
# Purpose: Set up and maintain work project repositories
# Following clean code and clean architecture principles

# Constants
# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")
readonly ERROR_LOG="/tmp/git_error_output"

# Import utilities
source "$SCRIPT_DIR/../utils/colors_message.sh"
source "$SCRIPT_DIR/../utils/load_env.sh"

# Load environment variables
load_env

# Repository configuration - can be moved to a separate config file later
declare -A REPOSITORIES=(
    # Format: [target_directory]="repository_url"
    ["$PROJECT_DIR_WORK/flow/chat"]="git@github.com:CI-T-HyperX/flow-channels-app-service.git"
    ["$PROJECT_DIR_WORK/flow/ai-core"]="git@github.com:CI-T-HyperX/flow-core-app-llm-service.git"
    ["$PROJECT_DIR_WORK/flow/coder"]="git@github.com:CI-T-HyperX/flow-coder-framework.git"
    ["$PROJECT_DIR_WORK/flow/coder"]="git@github.com:CI-T-HyperX/flow-coder-service.git"
    ["$PROJECT_DIR_WORK/flow/coder"]="git@bitbucket.org:ciandt_it/flow-coder-extension.git"
    ["$PROJECT_DIR_WORK/flow/coder/cases"]="git@github.com:davipeterlinicit/case-end-to-end-ops.git"
    ["$PROJECT_DIR_WORK/flow/coder/cases"]="git@github.com:laisbonafeciandt/case-end-to-end-metrics.git"
    ["$PROJECT_DIR_WORK/flow/coder/cases"]="git@github.com:arysanchez/case-end-to-end-chat.git"
    ["$PROJECT_DIR_WORK/flow/coder/cases"]="git@github.com:davipeterlinicit/coder-cases.git"
    ["$PROJECT_DIR_WORK/flow/coder/cases"]="git@github.com:CI-T-HyperX/flow-core-lib-commons-py.git"
    ["$PROJECT_DIR_WORK/flow/coder/pocs"]="git@github.com:continuedev/continue.git"
    ["$PROJECT_DIR_WORK/flow/coder/mcp-server"]="git@github.com:CI-T-HyperX/mcp-ciandt-flow.git"
)

# Directory structure configuration
readonly DIRECTORIES=(
    "$PROJECT_DIR_WORK"
    "$PROJECT_DIR_WORK/flow"
    "$PROJECT_DIR_WORK/flow/chat"
    "$PROJECT_DIR_WORK/flow/ai-core"
    "$PROJECT_DIR_WORK/flow/coder"
    "$PROJECT_DIR_WORK/flow/coder/cases"
    "$PROJECT_DIR_WORK/flow/coder/mcp-server"
    "$PROJECT_DIR_WORK/flow/coder/pocs"
)

create_directory() {
    local dir="$1"
    
    if [[ ! -d "$dir" ]]; then
        print_info "Creating directory: $dir"
        mkdir -p "$dir"
        print_success "Directory created: $dir"
    else
        print_info "Directory already exists: $dir"
    fi
}

update_repository() {
    local repo_path="$1"
    local current_branch
    
    cd "$repo_path" || return 1
    
    # Get current branch name
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
    
    if [[ "$current_branch" == "main" ]]; then
        print_info "Currently on main branch, pulling latest changes..."
        if git pull; then
            print_success "Updated repository: $(basename "$repo_path")"
            cd - > /dev/null
            return 0
        else
            print_error "Failed to update repository: $(basename "$repo_path")"
            cd - > /dev/null
            return 1
        fi
    else
        print_info "Currently on branch: $current_branch, pulling from origin main..."
        if git pull origin main 2> "$ERROR_LOG"; then
            print_success "Pulled changes from main branch into $current_branch: $(basename "$repo_path")"
            cd - > /dev/null
            return 0
        else
            # Check for merge conflicts
            if grep -q "CONFLICT" "$ERROR_LOG"; then
                print_alert "MERGE CONFLICT: There are conflicts when pulling main into $current_branch in repository: $(basename "$repo_path")"
                print_alert "Please resolve conflicts manually before continuing."
            else
                print_error "Failed to pull from main branch: $(basename "$repo_path")"
            fi
            cd - > /dev/null
            return 1
        fi
    fi
}

clone_repository() {
    local repo_url="$1"
    local target_dir="$2"
    local repo_name
    
    repo_name=$(basename "$repo_url" .git)
    
    print_info "Cloning repository: $repo_name"
    if git clone "$repo_url" "$target_dir/$repo_name"; then
        print_success "Repository cloned: $repo_name"
        return 0
    else
        print_error "Failed to clone repository: $repo_name"
        return 1
    fi
}

manage_repository() {
    local repo_url="$1"
    local target_dir="$2"
    local repo_name
    local repo_path
    
    repo_name=$(basename "$repo_url" .git)
    repo_path="$target_dir/$repo_name"
    
    if [[ -d "$repo_path" ]]; then
        print_info "Repository already exists: $repo_name"
        update_repository "$repo_path"
    else
        clone_repository "$repo_url" "$target_dir"
    fi
}

create_directory_structure() {
    print_info "Setting up work projects directory structure..."
    
    for dir in "${DIRECTORIES[@]}"; do
        create_directory "$dir"
    done
    
    print_success "Directory structure created successfully!"
}

setup_repositories() {
    print_info "Setting up repositories..."
    
    for target_dir in "${!REPOSITORIES[@]}"; do
        repo_url="${REPOSITORIES[$target_dir]}"
        manage_repository "$repo_url" "$target_dir"
    done
    
    print_success "Repository setup completed!"
}

main() {
    print_info "Starting work projects setup..."
    
    # Ensure environment variables are loaded
    if [[ -z "$PROJECT_DIR_WORK" ]]; then
        print_error "PROJECT_DIR_WORK environment variable is not set. Please check your .env file."
        exit 1
    fi
    
    create_directory_structure
    setup_repositories
    
    print_success "Work projects setup completed successfully!"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi