#!/bin/bash

# Function to uninstall software installed via Homebrew
uninstall_if_installed() {
    local name="$1"
    local brew_name="${2:-$1}"

    # Check if the software is installed
    if brew list --formula | grep -q "^${brew_name}\$"; then
        read -p "Do you want to uninstall $name? (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "Uninstalling $name..."
            brew uninstall $brew_name
        else
            echo "Skipping uninstallation of $name."
        fi
    else
        echo "$name is not installed."
    fi
}

# Function to uninstall cask software installed via Homebrew
uninstall_cask_if_installed() {
    local name="$1"
    local cask_name="${2:-$1}"

    # Check if the software is installed
    if brew list --cask | grep -q "^${cask_name}\$"; then
        read -p "Do you want to uninstall $name? (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "Uninstalling $name..."
            brew uninstall --cask $cask_name
        else
            echo "Skipping uninstallation of $name."
        fi
    else
        echo "$name is not installed."
    fi
}

main() {
    # Uninstall all formulae
    for formula in $(brew list --formula); do
        uninstall_if_installed "$formula"
    done

    # Uninstall all casks
    for cask in $(brew list --cask); do
        uninstall_cask_if_installed "$cask"
    done

    # Clean up Homebrew caches, etc, after uninstallation
    brew cleanup
}

# Execute the main function
main