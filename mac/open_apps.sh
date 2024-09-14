#!/bin/bash

# Load the function to load environment variables
source "$(dirname "$0")/../utils/load_env.sh"
source "$(dirname "$0")/../utils/list_projects.sh"

# Function to check if an application is running
is_app_running() {
    local app_name="$1"
    if pgrep -x "$app_name" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to open an application
open_app() {
    local app_name="$1"

    if is_app_running "$app_name"; then
        echo "$app_name is already running."
    else
        echo "Opening $app_name..."
        open -a "$app_name"
    fi
}

# Function to start Colima if it's in the list of apps to open
start_colima_if_needed() {
    local apps_array=("$@")
    for app in "${apps_array[@]}"; do
        if [[ "$app" == "colima" ]]; then
            echo "Colima is in the list of apps to open. Starting Colima..."
            colima start
            break
        fi
    done
}

main() {
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

    # Extract applications from the project-specific variable
    local apps_var="APPS_TO_OPEN_${project_dir}"
    local apps=$(eval echo \${$apps_var})

    IFS="," read -r -a apps_array <<< "$apps"

    # Start Colima if it's in the list of apps to open
    start_colima_if_needed "${apps_array[@]}"

    for app in "${apps_array[@]}"; do
        # Remove leading and trailing spaces
        app=$(echo "$app" | xargs)
        if [ -n "$app" ]; then
            if [ "$app" == "Google Chrome" ]; then
                # Check for Chrome profile
                local profile_var="CHROME_PROFILE_${project_dir}"
                local profile=$(eval echo \${$profile_var})
                ./mac/open_chrome_profile.sh "$profile"
            else
                open_app "$app"
            fi
        fi
    done
}

# Execute the main function with the provided argument
main "$1"