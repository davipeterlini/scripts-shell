#!/bin/bash

# Load the function to load environment variables
source "$(dirname "$0")/../../utils/load_env.sh"
source "$(dirname "$0")/../../utils/list_projects.sh"

# Function to check if an application is running
is_app_running() {
    local app_name="$1"
    if pgrep -x "$app_name" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to open Google Chrome with a specific profile
open_chrome_with_profile() {
    local profile="$1"

    if is_app_running "Google Chrome"; then
        echo "Google Chrome is already running."
    else
        echo "Opening Google Chrome with profile $profile..."
        open -a "Google Chrome" --args --profile-directory="$profile"
    fi
}

# Main function to open Google Chrome with the specified profile
main() {
    local project_dir="$1"

    if [ -z "$project_dir" ]; then
        # Load environment variables and list projects
        load_env
        list_projects
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

    # Extract the Chrome profile from the project-specific variable
    local profile_var="CHROME_PROFILE_${project_dir}"
    local profile=$(eval echo \${$profile_var})

    if [ -z "$profile" ]; then
        echo "No profile found for project $project_dir. Exiting..."
        exit 1
    fi

    open_chrome_with_profile "$profile"
}

# Execute the main function with the provided argument
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$1"
fi