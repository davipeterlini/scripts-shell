#!/bin/bash

# Global variable to store menu choices
MENU_CHOICES=""

display__dialog_menu() {
    install_dialog

    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 3 \
        1 "Basic Apps" on \
        2 "Development Apps" off \
        3 "All Apps" off)

    if [ -z "$choices" ]; then
        print_alert "No option was selected."
    else
        print_success "Selected options: $choices"
    fi
}

install_dialog() {
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y dialog
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install dialog
        else
            echo "Unsupported OS."
            return 1
        fi
    fi
}

# Function to display a menu without using dialog
display_menu() {
    echo ""
    print_header_info "Menu"
    echo ""
    print "Select the type of applications to install:"
    echo ""
    print "1) Basic Apps"
    print "2) Development Apps"
    print "3) All Apps"
    echo ""
    
    print_yellow "Enter the numbers of the desired options (separated by spaces) and press ENTER:"
    read -r selection
    
    # Check if input is not empty
    if [ -z "$selection" ]; then
        print_alert "No option was selected."
        MENU_CHOICES=""
        return 1
    fi
    
    # Process and validate input
    local choices=""
    local valid_options=true
    
    for num in $selection; do
        if [[ "$num" =~ ^[1-3]$ ]]; then
            choices+="$num "
        else
            print_error "Invalid option: $num. Ignoring."
            valid_options=false
        fi
    done
    
    # Trim trailing space
    choices=$(echo "$choices" | xargs)
    
    if [ -z "$choices" ]; then
        print_alert "No valid option was selected."
        MENU_CHOICES=""
        return 1
    fi
    
    if [ "$valid_options" = false ]; then
        print_alert "Some invalid options were ignored."
    fi
    
    print_success "Selected options: $choices"
    
    # Set the global variable
    MENU_CHOICES="$choices"
}