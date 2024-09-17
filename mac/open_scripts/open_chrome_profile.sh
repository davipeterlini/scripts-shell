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
    local profile="$1"

    if [ -z "$profile" ]; then
        echo "No profile specified. Exiting..."
        exit 1
    fi

    open_chrome_with_profile "$profile"
}

# Execute the main function with the provided argument
main "$1"