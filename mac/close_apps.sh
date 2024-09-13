#!/bin/bash
# TODO: nao está fechando o vscode nem o iterm corretamente

# Load environment variables from .env file
source "$(dirname "$0")/../utils/load_env.sh"
source "$(dirname "$0")/../utils/list_projects.sh"

# Function to close an application gracefully
close_app() {
    local app_name="$1"
    local process_name="$2"

    # Check if the application is running
    if pgrep -x "$process_name" > /dev/null; then
        echo "Closing $app_name..."
        # Send the SIGTERM signal to allow it to close gracefully
        pkill -15 -x "$process_name"
        # Wait for a few seconds to allow the application to close
        sleep 5
        # Check if the application is still running and force kill if necessary
        if pgrep -x "$process_name" > /dev/null; then
            echo "$app_name did not close gracefully, forcing it to close..."
            pkill -9 -x "$process_name"
        else
            echo "$app_name closed gracefully."
        fi
    else
        echo "$app_name is not running."
    fi
}

# Function to stop Colima if it's in the list of apps to close
stop_colima_if_needed() {
    local apps_array=("$@")
    for app in "${apps_array[@]}"; do
        if [[ "$app" == "colima" ]]; then
            echo "Colima is in the list of apps to close. Stopping Colima..."
            colima stop
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
    local apps_var="APPS_TO_CLOSE_${project_dir}"
    local apps=$(eval echo \${$apps_var})

    IFS="," read -r -a apps_array <<< "$apps"

    # Stop Colima if it's in the list of apps to close
    stop_colima_if_needed "${apps_array[@]}"

    for app in "${apps_array[@]}"; do
        # Remove leading and trailing spaces
        app=$(echo "$app" | xargs)
        if [ -n "$app" ]; then
            close_app "$app" "$app"
        fi
    done
}

# Execute the main function with the provided argument
main "$1"