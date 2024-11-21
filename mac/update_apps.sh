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

# Function to update software if a newer version is available
update_if_newer_version_available() {
    local name="$1"
    local brew_name="${2:-$1}"

    # Check if the software is already installed
    if brew list --formula | grep -q "^${brew_name}\$"; then
        local current_version=$(brew list --versions $brew_name | awk '{print $2}')
        local latest_version=$(brew info $brew_name --json=v1 | jq -r '.[0].versions.stable')

        if [ "$current_version" != "$latest_version" ]; then
            echo "Updating $name from version $current_version to $latest_version..."
            brew upgrade $brew_name
        else
            echo "$name is already up-to-date."
        fi
    else
        echo "$name is not installed."
    fi
}

# Function to update cask software if a newer version is available
update_cask_if_newer_version_available() {
    local name="$1"
    local cask_name="${2:-$1}"

    # Check if the software is already installed
    if brew list --cask | grep -q "^${cask_name}\$"; then
        local current_version=$(brew list --cask --versions $cask_name | awk '{print $2}')
        local latest_version=$(brew info --cask $cask_name --json=v1 | jq -r '.[0].version')

        if [ "$current_version" != "$latest_version" ]; then
            echo "Updating $name from version $current_version to $latest_version..."
            brew upgrade --cask $cask_name
        else
            echo "$name is already up-to-date."
        fi
    else
        echo "$name is not installed."
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
            update_if_newer_version_available "$app"
        fi
    done

    # Update additional applications
    update_cask_if_newer_version_available "Trello" "trello"
    update_cask_if_newer_version_available "WhatsApp" "whatsapp"
    update_if_newer_version_available "Python" "python"

    # Clean up Homebrew caches, etc, after update
    brew cleanup
}

# Execute the main function with the provided argument
main "$1"