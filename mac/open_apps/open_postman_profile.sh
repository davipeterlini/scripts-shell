#!/bin/bash

# Load the function to load environment variables
source "$(dirname "$0")/../../utils/load_env.sh"

# Function to check if an application is running
is_app_running() {
    local app_name="$1"
    if pgrep -x "$app_name" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to open Postman with a specific profile
open_postman_with_profile() {
    local profile="$1"

    if is_app_running "Postman"; then
        echo "Postman is already running."
    else
        echo "Opening Postman with profile $profile..."
        open -a "Postman" --args --profile="$profile"
    fi
}

# Main function to open Postman with the specified profile
main() {
    local project_dir="$1"

    if [ -z "$project_dir" ]; then
        echo "No project directory specified. Exiting..."
        exit 1
    fi

    # Load environment variables
    load_env

    # Extract the Postman profile from the project-specific variable
    local profile_var="POSTMAN_PROFILE_${project_dir}"
    local profile=$(eval echo \${$profile_var})

    if [ -z "$profile" ]; then
        echo "No profile found for project $project_dir. Exiting..."
        exit 1
    fi

    open_postman_with_profile "$profile"
}

# Execute the main function with the provided argument
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$1"
fi