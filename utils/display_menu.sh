#!/bin/bash

# Function to display a menu using dialog
display_menu() {
    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 3 \
        1 "Basic Apps" on \
        2 "Development Apps" off \
        3 "All Apps" off)

    echo "$choices"
}

# Function to check if the menu has already been displayed
check_menu_displayed() {
    if [ -z "$MENU_DISPLAYED" ]; then
        display_menu
        export MENU_DISPLAYED=true
    else
        echo "Menu has already been displayed."
    fi
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_menu_displayed
fi