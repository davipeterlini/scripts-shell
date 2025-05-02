#!/bin/bash

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/colors_message.sh"
source "$SCRIPT_DIR/../utils/list_projects.sh"
source "$SCRIPT_DIR/../utils/load_env.sh"
source "$SCRIPT_DIR/../utils/display_menu.sh"

# Load environment variables
load_env

# Function to check if iTerm2 is installed
check_iterm() {
    if ! [ -d "/Applications/iTerm.app" ]; then
        print_error "iTerm2 is not installed. Please install it first."
        exit 1
    fi
}

# Function to prompt user to select repository type
select_repo_type() {
    local options=("Personal Projects" "Work Projects")
    local choice
    
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

# Function to open repositories in iTerm2 tabs
open_repos_in_iterm() {
    local repos=()
    
    # Get list of repositories
    if [ "$1" == "personal" ]; then
        print_info "Loading personal projects..."
        repos=($(list_personal_projects))
    elif [ "$1" == "work" ]; then
        print_info "Loading work projects..."
        repos=($(list_work_projects))
    else
        print_error "Invalid repository type. Use 'personal' or 'work'"
        exit 1
    fi
    
    if [ ${#repos[@]} -eq 0 ]; then
        print_error "No repositories found."
        exit 1
    fi
    
    print_info "Opening ${#repos[@]} repositories in iTerm2 tabs..."
    
    # Create AppleScript to open repositories in iTerm2 tabs
    osascript <<EOF
    tell application "iTerm"
        activate
        
        # Create a new window if none exists
        if (count of windows) = 0 then
            create window with default profile
        end if
        
        tell current window
            # Get the first tab
            set initialTab to current tab
            
            # Set the first tab to the first repository
            tell initialTab
                tell current session
                    write text "cd ${repos[0]}"
                    write text "clear"
                end tell
            end tell
            
            # Create tabs for the rest of the repositories
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

# Main execution
check_iterm

# If no argument is provided, prompt the user to select
if [ "$#" -eq 0 ]; then
    repo_type=$(select_repo_type)
else
    # Check if the provided argument is valid
    case "$1" in
        personal|work)
            repo_type="$1"
            ;;
        *)
            print_error "Invalid argument. Use 'personal' or 'work'"
            exit 1
            ;;
    esac
fi

# Open repositories in iTerm
open_repos_in_iterm "$repo_type"