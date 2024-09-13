#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Load environment variables from .env file
source "$SCRIPT_DIR/../utils/load_env.sh"
source "$SCRIPT_DIR/../utils/list_projects.sh"

# Function to open iTerm2 tabs
open_iterm_tabs() {
    local project_dir="$1"

    if [ -z "$project_dir" ]; then
        # Load environment variables and list projects
        load_env
        list_identities
        echo
        read -p "Please choose a project by number: " PROJECT_NUMBER

        local index=1
        for identity in $(env | grep '^PROJECT_DIR_' | sed 's/^PROJECT_DIR_//' | sed 's/=.*//'); do
            if [ "$index" -eq "$PROJECT_NUMBER" ]; then
                project_dir=$(echo $identity | tr '[:lower:]' '[:upper:]')
                break
            fi
            index=$((index + 1))
        done

        if [ -z "$project_dir" ]; then
            echo "Invalid choice. Exiting..."
            exit 1
        fi
    fi

    # Extract iTerm tabs from the project-specific variable
    local tabs_prefix="ITERM_OPEN_TABS_${project_dir}_"
    local tabs=()
    local i=1

    while true; do
        local tab_var="${tabs_prefix}${i}"
        local tab=$(eval echo \${$tab_var})
        if [ -z "$tab" ]; then
            break
        fi
        tabs+=("$tab")
        i=$((i + 1))
    done

    if [ ${#tabs[@]} -eq 0 ]; then
        echo "No tabs found for project $project_dir. Exiting..."
        exit 1
    fi

    echo "Tabs to be opened for project $project_dir:"
    for tab in "${tabs[@]}"; do
        # Remove leading and trailing spaces
        tab=$(echo "$tab" | xargs)
        if [ -n "$tab" ]; then
            echo "$tab"
        fi
    done

    for tab in "${tabs[@]}"; do
        # Remove leading and trailing spaces
        tab=$(echo "$tab" | xargs)
        if [ -n "$tab" ]; then
            echo "Opening iTerm2 tab for directory: $tab"
            osascript <<EOD
                tell application "iTerm2"
                    create window with default profile
                    tell current session of current window
                        write text "cd $tab"
                    end tell
                end tell
EOD
        fi
    done
}

# Execute the function with the provided argument
open_iterm_tabs "$1"