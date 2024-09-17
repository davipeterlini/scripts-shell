#!/bin/bash

# Load environment variables from .env file
source "$(dirname "$0")/../utils/load_env.sh"
source "$(dirname "$0")/../utils/list_projects.sh"

# Check if Homebrew is installed, install if not
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Update Homebrew
brew update --auto-update
brew update

# Function to install software if it's not already installed
install_if_not_installed() {
    local name="$1"
    local brew_name="${2:-$1}"

    # Check if the software is already installed
    if brew list --formula | grep -q "^${brew_name}\$"; then
        echo "$name is already installed."
    else
        echo "Installing $name..."
        brew install $brew_name
    fi
}

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

    # Extract applications from the project-specific variable
    local apps_var="APPS_TO_INSTALL_${project_dir}"
    local apps=$(eval echo \${$apps_var})

    IFS="," read -r -a apps_array <<< "$apps"

    for app in "${apps_array[@]}"; do
        # Remove leading and trailing spaces
        app=$(echo "$app" | xargs)
        if [ -n "$app" ]; then
            install_if_not_installed "$app"
        fi
    done

    # Clean up Homebrew caches, etc, after installation
    brew cleanup
}

# Execute the main function with the provided argument
main "$1"