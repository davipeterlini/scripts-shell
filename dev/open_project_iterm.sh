#!/bin/bash

# Load utility functions and environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/colors_message.sh"
source "$SCRIPT_DIR/../utils/list_projects.sh"
source "$SCRIPT_DIR/../utils/load_env.sh"
source "$SCRIPT_DIR/../utils/display_menu.sh"

source "$(dirname "$0")/utils/load_dev_env.sh"

load_env

# Check if iTerm2 is installed
ensure_iterm_installed() {
    if ! [ -d "/Applications/iTerm.app" ]; then
        print_error "iTerm2 is not installed. Please install it first."
        exit 1
    fi
}

# Prompt user to select repository type
get_repo_type() {
    local options=("Personal Projects" "Work Projects")
    print_info "Select repository type:"
    display_menu "${options[@]}"
    
    read -p "Enter your choice (1-${#options[@]}): " choice
    case $choice in
        1) echo "personal" ;;
        2) echo "work" ;;
        *) 
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}

# Fetch repositories based on type
fetch_repositories() {
    local repo_type=$1
    case $repo_type in
        personal)
            print_info "Loading personal projects..."
            list_personal_projects
            ;;
        work)
            print_info "Loading work projects..."
            list_work_projects
            ;;
        *)
            print_error "Invalid repository type. Use 'personal' or 'work'."
            exit 1
            ;;
    esac
}

# Open repositories in iTerm2 tabs
open_repositories_in_iterm() {
    local repos=("$@")
    if [ ${#repos[@]} -eq 0 ]; then
        print_error "No repositories found."
        exit 1
    fi

    print_info "Opening ${#repos[@]} repositories in iTerm2 tabs..."
    osascript <<EOF
    tell application "iTerm"
        activate
        if (count of windows) = 0 then
            create window with default profile
        end if
        tell current window
            set initialTab to current tab
            tell initialTab
                tell current session
                    write text "cd ${repos[0]}"
                    write text "clear"
                end tell
            end tell
            repeat with repoPath in {"${repos[@]:1}"}
                create tab with default profile
                tell current tab
                    tell current session
                        write text "cd " & repoPath
                        write text "clear"
                    end tell
                end tell
            end repeat
        end tell
    end tell
EOF
    print_success "All repositories opened in iTerm2 tabs!"
}

# Main script execution
open_project_iterm_main() {
    print_header_info "Starting Open Projects"

    if ! confirm_action "Do you want Open Project?"; then
        print_info "Skipping configuration"
        return 0
    fi
    ensure_iterm_installed

    # Select environment
    select_environment
    selected_env=$env_file

    # Load the selected environment variables
    if [ -f "$selected_env" ]; then
        set -a
        source "$selected_env"
        set +a
    else
        print_error "Environment file not found: $selected_env"
        exit 1
    fi

    # Validate required variables
    if [ -z "$PROJECT_DIR" ] || [ -z "$PROJECT_REPOS" ]; then
        print_error "PROJECT_DIR or PROJECT_REPOS is not defined in the selected .env file. Exiting."
        exit 1
    fi

    local repo_type
    if [ "$#" -eq 0 ]; then
        repo_type=$(get_repo_type)
    else
        case "$1" in
            personal|work) repo_type="$1" ;;
            *)
                print_error "Invalid argument. Use 'personal' or 'work'."
                exit 1
                ;;
        esac
    fi

    local repos=($(fetch_repositories "$repo_type"))
    open_repositories_in_iterm "${repos[@]}"
}

open_project_iterm_main "$@"