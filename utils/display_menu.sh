#!/bin/bash

# Menu display utility for script interactions
# Provides both dialog-based and text-based menu interfaces

# Get absolute directory of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required utilities (assuming they are in the same directory)
if [ -f "${SCRIPT_DIR}/colors_message.sh" ]; then
    source "${SCRIPT_DIR}/colors_message.sh"
fi

# Global variable to store menu choices
MENU_CHOICES=""

# ====================
# UTILITY FUNCTIONS
# ====================

# Function to check if dialog is installed and install if needed
_ensure_dialog_installed() {
    if ! command -v dialog &> /dev/null; then
        print_info "dialog is not installed. Installing dialog..."
        
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y dialog
            elif command -v yum &> /dev/null; then
                sudo yum install -y dialog
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y dialog
            else
                print_error "Unsupported package manager. Please install dialog manually."
                return 1
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew &> /dev/null; then
                brew install dialog
            else
                print_error "Homebrew not found. Please install dialog manually."
                return 1
            fi
        else
            print_error "Unsupported OS for automatic dialog installation."
            return 1
        fi
        
        # Verify installation
        if ! command -v dialog &> /dev/null; then
            print_error "Failed to install dialog. Falling back to text menu."
            return 1
        fi
    fi
    
    return 0
}

# Function to validate menu selections
_validate_selections() {
    local selection="$1"
    local max_option="$2"
    local choices=""
    local valid_options=true
    
    # Process and validate input
    for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$max_option" ]; then
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
    return 0
}

# ====================
# PUBLIC FUNCTIONS
# ====================

# Function to display a menu using dialog if available
display_dialog_menu() {
    if ! _ensure_dialog_installed; then
        print_alert "Falling back to text menu."
        display_text_menu
        return $?
    fi
    
    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 3 \
        1 "Basic Apps" on \
        2 "Development Apps" off \
        3 "All Apps" off)
    
    if [ -z "$choices" ]; then
        print_alert "No option was selected."
        MENU_CHOICES=""
        return 1
    else
        print_success "Selected options: $choices"
        MENU_CHOICES="$choices"
        return 0
    fi
}

# Function to display a menu without using dialog (text-based)
display_text_menu() {
    local options=(
        "Basic Apps"
        "Development Apps"
        "All Apps"
    )
    local max_options=${#options[@]}
    
    print_header_info "Menu"
    print "Select the type of applications to install:"
    echo ""
    
    # Display menu options
    local i=1
    for option in "${options[@]}"; do
        print "$i) $option"
        ((i++))
    done
    echo ""
    
    print_yellow "Enter the numbers of the desired options (separated by spaces) and press ENTER:"
    read -r selection
    
    # Check if input is not empty
    if [ -z "$selection" ]; then
        print_alert "No option was selected."
        MENU_CHOICES=""
        return 1
    fi
    
    # Validate selections
    _validate_selections "$selection" "$max_options"
    return $?
}

# Main menu display function - automatically chooses best available option
display_menu() {
    # Check if we should use dialog or text menu
    if command -v dialog &> /dev/null || _ensure_dialog_installed; then
        # Use dialog menu if it's in a terminal that supports it
        if [ -t 0 ] && [ -t 1 ] && [ -t 2 ]; then
            display_dialog_menu
        else
            # Fall back to text menu if not in an interactive terminal
            display_text_menu
        fi
    else
        # Always fall back to text menu if dialog isn't available
        display_text_menu
    fi
}

# ====================
# INITIALIZATION
# ====================

# Display information if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Test the menu functionality
    display_menu
    if [ -n "$MENU_CHOICES" ]; then
        echo "You selected: $MENU_CHOICES"
    else
        echo "No selections were made."
    fi
fi