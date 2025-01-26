#!/bin/bash

# Function to display a menu using dialog
display_menu() {
    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 3 \
        1 "Basic Apps" on \
        2 "Development Apps" off \
        3 "All Apps" off)

    echo "$choices"
}