#!/bin/bash

# Load environment variables
source "$(dirname "$0")/utils/load_env.sh"
load_env

# Function to get the remote URL of the current git repository
get_remote_url() {
    git config --get remote.origin.url
}

# Function to extract the username from the remote URL
get_username_from_url() {
    local url=$1
    echo "$url" | sed -E 's/.*[:/]([^/]+)\/.*/\1/'
}

# Function to determine if the repo is personal or work
determine_repo_type() {
    local username=$1
    if [[ "$username" == "$PERSONAL_GITHUB_USERNAME" ]]; then
        echo "personal"
    elif [[ "$username" == "$WORK_GITHUB_USERNAME" ]]; then
        echo "work"
    else
        echo "unknown"
    fi
}

# Function to connect the correct SSH key
connect_ssh_key() {
    local repo_type=$1
    if [[ "$repo_type" == "personal" ]]; then
        ./github/connect_git_ssh_account.sh "$SSH_KEY_PERSONAL"
    elif [[ "$repo_type" == "work" ]]; then
        ./github/connect_git_ssh_account.sh "$SSH_KEY_WORK"
    else
        echo "Unknown repo type. Using default SSH key."
    fi
}

# Main execution
echo "Intercepting git push command..."

# Get the remote URL
remote_url=$(get_remote_url)
echo "Remote URL: $remote_url"

# Get the username from the URL
username=$(get_username_from_url "$remote_url")
echo "Username: $username"

# Determine if it's a personal or work repo
repo_type=$(determine_repo_type "$username")
echo "Repo type: $repo_type"

# Connect the correct SSH key
connect_ssh_key "$repo_type"

# Execute the original git push command
echo "Executing git push..."
git push "$@"