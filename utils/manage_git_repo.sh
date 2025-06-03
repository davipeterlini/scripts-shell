#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors_message.sh"

# Function to clone a repository
clone_repository() {
    local repo_url="$1"
    local repo_path="$2"

    print_info "Cloning repository: $(basename "$repo_url" .git)"
    git clone "$repo_url" "$repo_path"
}

# Function to update a repository
update_repository() {
    local repo_path="$1"

    print_info "Updating repository: $(basename "$repo_path")"
    (cd "$repo_path" && git pull origin main)
}

# Function to merge back changes from a branch
merge_back_repository() {
    local repo_path="$1"
    local branch="$2"

    print_info "Merging back changes from branch $branch in repository: $(basename "$repo_path")"
    (cd "$repo_path" && git merge "$branch")
}

# Function to manage repositories - Update or Clone repo
# Modified to work with Bash 3.2 (no associative arrays)
manage_repositories() {
    # Process arguments in pairs (target_dir and repo_url)
    while [[ $# -ge 2 ]]; do
        local target_dir="$1"
        local repo_url="$2"
        shift 2
        
        local repo_name=$(basename "$repo_url" .git)
        local repo_path="$target_dir/$repo_name"

        if [[ -d "$repo_path" ]]; then
            update_repository "$repo_path"
        else
            clone_repository "$repo_url" "$repo_path"
        fi
    done
}