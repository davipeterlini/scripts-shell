#!/bin/bash

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

    if is_app_running "postman"; then
        echo "Postman is already running."
    else
        echo "Opening Postman with profile $profile..."
        postman --profile="$profile" &
    fi
}

# Main function to open Postman with the specified profile
main() {
    local profile="$1"

    if [ -z "$profile" ]; then
        echo "No profile specified. Exiting..."
        exit 1
    fi

    open_postman_with_profile "$profile"
}

# Execute the main function with the provided argument
main "$1"