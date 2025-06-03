#!/bin/bash

# Function to manage repositories
manage_repositories() {
    declare -A repositories=("$@")
    for target_dir in "${!repositories[@]}"; do
        local repo_url="${repositories[$target_dir]}"
        local repo_name=$(basename "$repo_url" .git)
        local repo_path="$target_dir/$repo_name"

        if [[ -d "$repo_path" ]]; then
            print_info "Updating repository: $repo_name"
            (cd "$repo_path" && git pull)
        else
            print_info "Cloning repository: $repo_name"
            git clone "$repo_url" "$repo_path"
        fi
    done
}