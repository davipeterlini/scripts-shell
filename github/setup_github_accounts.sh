#!/bin/bash

# Script to configure multiple SSH keys for GitHub accounts
# Using shared utility functions for common operations

# Get absolute directory of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source required utilities
source "${PROJECT_ROOT}/utils/colors_message.sh"
source "${PROJECT_ROOT}/utils/load_env.sh"
source "${PROJECT_ROOT}/utils/bash_tools.sh"
source "${PROJECT_ROOT}/utils/git_utils.sh"

# Function to handle GitHub CLI authentication
_handle_github_cli_auth() {
    if [ -n "$GITHUB_TOKEN" ]; then
        print_info "GITHUB_TOKEN environment variable detected."
        print_info "To have GitHub CLI store credentials, you need to clear this variable."
        if get_user_confirmation "Do you want to clear GITHUB_TOKEN and let GitHub CLI handle authentication?"; then
            unset GITHUB_TOKEN
            print_success "GITHUB_TOKEN has been cleared. GitHub CLI will now prompt for authentication."
        else
            print_info "GITHUB_TOKEN remains set. GitHub CLI will use this for authentication."
        fi
    else
        print_info "No GITHUB_TOKEN detected. GitHub CLI will handle authentication normally."
    fi
}

# Function to associate SSH key with GitHub
_associate_ssh_key_with_github() {
    local label=$1
    local ssh_key_path="$HOME/.ssh/id_rsa_github_${label}"

    # Ensure GitHub CLI is installed
    ensure_command_installed "gh" "gh"

    print_info "Associating SSH key with GitHub for $label..."
    
    # Alert the user to log in with the correct account
    print_alert "IMPORTANT: Please ensure you are logged into the correct GitHub account in your browser."
    print_info "The account should match the email and username you provided for $label."

    print_info "Please authenticate with GitHub CLI:"
    print_info "Generating GitHub token with repo and workflow permissions..."
    gh auth login -s repo,workflow

    # Add the SSH key to GitHub
    gh ssh-key add "$ssh_key_path.pub" --title "SSH key for $label"

    if [ $? -eq 0 ]; then
        print_success "SSH key successfully associated with GitHub for $label."
    else
        print_error "Failed to associate SSH key with GitHub for $label."
    fi
}

# Function to implement the GitHub-specific configuration
# This function is called by the generic setup_git_account function in git_utils.sh
configure_github_account() {
    local label="$1"
    local email="$2"
    local username="$3"

    print_info "Associating generated SSH key with GitHub account"
    _handle_github_cli_auth
    _associate_ssh_key_with_github "$label"

    print_success "GitHub configuration completed for username: $username email: $email."
}

# Main function to configure multiple GitHub accounts
setup_github_accounts() {
    # Use the shared function from git_utils.sh
    setup_git_account "github"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_github_accounts "$@"
fi