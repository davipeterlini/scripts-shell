#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors_message.sh"

# Function to clone a repository
clone_repository() {
    local repo_url="$1"
    local repo_path="$2"
    local repo_name=$(basename "$repo_url" .git)
    local full_repo_path="$repo_path"

    if [[ -d "$full_repo_path" ]]; then
        print_info "Repository directory already exists: $full_repo_path"
        print_info "Updating repository instead of cloning..."
        if (cd "$full_repo_path" && git pull origin main); then
            print_success "Repository updated successfully: $repo_name"
        else
            print_alert "Failed to update repository: $repo_name. Continuing with next repository."
        fi
    else
        print_info "Cloning repository: $repo_name"
        if git clone "$repo_url" "$repo_path"; then
            print_success "Repository cloned successfully: $repo_name"
        else
            print_alert "Failed to clone repository: $repo_name. Skipping and continuing with next repository."
        fi
    fi
}

# Function to update a repository
update_repository() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")

    print_info "Updating repository: $repo_name"
    if (cd "$repo_path" && git pull origin main); then
        print_success "Repository updated successfully: $repo_name"
    else
        print_warning "Failed to update repository: $repo_name. Continuing with next repository."
    fi
}

# Function to merge back changes from a branch
merge_back_repository() {
    local repo_path="$1"
    local branch="$2"
    local repo_name=$(basename "$repo_path")

    print_info "Merging back changes from branch $branch in repository: $repo_name"
    if (cd "$repo_path" && git merge "$branch"); then
        print_success "Branch $branch merged successfully in repository: $repo_name"
    else
        print_warning "Failed to merge branch $branch in repository: $repo_name. Continuing with next repository."
    fi
}

# Function to manage repositories - Update or Clone repo
manage_repositories() {
   # Process arguments in pairs (target_dir and repo_url)
   while [[ $# -ge 2 ]]; do
       local repo_url="$1"
       local target_dir="$2"
       shift 2

       local repo_name=$(basename "$repo_url" .git)
       local project_root="$(dirname "$target_dir")"
       local repo_path="$target_dir/$repo_name"

       if [[ -d "$repo_path" ]]; then
           update_repository "$repo_path"
       else
           clone_repository "$repo_url" "$target_dir"
       fi
   done
}

# Main function
main() {
    manage_repositories "$@"
}

# Execute main function
main "$@"