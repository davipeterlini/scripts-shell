#!/bin/bash

# Function to display a menu using dialog
display_menu() {
    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 2 \
        1 "Basic Apps" on \
        2 "Development Apps" off)

    echo "$choices"
}

# Function to install basic apps
install_basic_apps() {
    echo "Installing basic apps..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        ./linux/install_apps.sh
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        ./mac/install_apps.sh
    else
        echo "Unsupported OS."
        exit 1
    fi
}

# Function to install development apps
install_dev_apps() {
    echo "Installing development apps..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        ./linux/install_apps.sh dev
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        ./mac/install_apps.sh dev
    else
        echo "Unsupported OS."
        exit 1
    fi
}

main() {
    # Check if dialog is installed
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y dialog
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install dialog
        else
            echo "Unsupported OS."
            exit 1
        fi
    fi

    choices=$(display_menu)

    if [[ "$choices" == *"1"* ]]; then
        install_basic_apps
    fi

    if [[ "$choices" == *"2"* ]]; then
        install_dev_apps
    fi
}

main