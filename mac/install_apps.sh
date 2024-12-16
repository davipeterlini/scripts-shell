#!/bin/bash

# Load environment variables from .env file
source "$(dirname "$0")/../utils/load_env.sh"
source "$(dirname "$0")/../utils/list_projects.sh"

# Function to install Homebrew if not installed and update it
install_and_update_homebrew() {
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
}

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
        # Call the corresponding setup script if it exists
        if [ -f "$(dirname "$0")/setup_${name}.sh" ]; then
            read -p "Do you want to run the setup script for $name? (y/n): " choice
            if [[ "$choice" =~ ^[Yy]$ ]]; then
                echo "Running setup script for $name..."
                "$(dirname "$0")/setup_${name}.sh"
            fi
        fi
    fi
}

# Function to install cask software if it's not already installed
install_cask_if_not_installed() {
    local name="$1"
    local cask_name="${2:-$1}"

    # Check if the software is already installed
    if brew list --cask | grep -q "^${cask_name}\$"; then
        echo "$name is already installed."
    else
        echo "Installing $name..."
        brew install --cask $cask_name
        # Call the corresponding setup script if it exists
        if [ -f "$(dirname "$0")/setup_${name}.sh" ]; then
            read -p "Do you want to run the setup script for $name? (y/n): " choice
            if [[ "$choice" =~ ^[Yy]$ ]]; then
                echo "Running setup script for $name..."
                "$(dirname "$0")/setup_${name}.sh"
            fi
        fi
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

    # Install and update Homebrew
    install_and_update_homebrew

    # Extract applications from the project-specific variable
    local apps_var="APPS_TO_INSTALL_${project_dir}"
    local apps=$(eval echo \${$apps_var})

    IFS="," read -r -a apps_array <<< "$apps"

    for app in "${apps_array[@]}"; do
        # Remove leading and trailing spaces
        app=$(echo "$app" | xargs)
        if [ -n "$app" ]; then
            if [[ "$app" == *"cask:"* ]]; then
                app_name=$(echo "$app" | sed 's/cask://')
                install_cask_if_not_installed "$app_name"
            else
                install_if_not_installed "$app"
            fi
        fi
    done

    # Clean up Homebrew caches, etc, after installation
    brew cleanup
}

# Execute the main function with the provided argument
main "$1"