#!/bin/bash

# Script to test the Flow Coder extension in different IDEs
# Supports macOS and Linux

# Imports Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/generic_utils.sh"

# Constants
VSCODE_EXTENSION_ID="ciandt-global.ciandt-flow"
TEMP_DIR_PREFIX="flow_coder_test"

create_temp_test_file() {
    local file_extension="$1"
    local temp_dir=$(mktemp -d)
    local test_file="$temp_dir/${TEMP_DIR_PREFIX}.${file_extension}"
    echo "// Flow Coder test file" > "$test_file"
    echo "$temp_dir:$test_file"
}

# IDE-specific test functions
test_vscode() {
    print_header_info "Testing Flow Coder in VSCode..."
    
    if ! command_exists code; then
        print_error "VSCode not found. Please install VSCode first."
        return 1
    fi
    
    print_info "VSCode found. Checking Flow Coder extension..."
    
    local extension_list=$(code --list-extensions)
    if ! echo "$extension_list" | grep -q "$VSCODE_EXTENSION_ID"; then
        print_error "Flow Coder extension is not installed in VSCode."
        print_info "Run the install_flow_coder.sh script to install the extension."
        return 1
    fi
    
    print_success "Flow Coder extension is installed in VSCode."
    
    # Create and open test file
    local temp_info=$(create_temp_test_file "txt")
    local temp_dir=$(echo "$temp_info" | cut -d':' -f1)
    local test_file=$(echo "$temp_info" | cut -d':' -f2)
    
    print_info "Opening VSCode with test file..."
    code "$test_file"
    
    wait_for_user_confirmation "Please test the Flow Coder extension in VSCode and press Enter when finished..."
    
    cleanup_temp_files "$temp_dir"
    return 0
}

test_jetbrains_ide() {
    local ide_type="$1"
    local ide_command="$2"
    local ide_app_name="$3"
    
    print_header_info "Testing Flow Coder in $ide_type..."
    
    local ide_found=false
    local os_type=$(detect_os)
    
    if [ "$os_type" = "$OS_TYPE_MAC" ]; then
        if [ -d "/Applications/$ide_app_name.app" ]; then
            ide_found=true
        fi
    elif [ "$os_type" = "$OS_TYPE_LINUX" ]; then
        if command_exists "$ide_command"; then
            ide_found=true
        fi
    fi
    
    if [ "$ide_found" = false ]; then
        print_error "$ide_type not found."
        return 1
    fi
    
    print_info "$ide_type found."
    
    # Create and open test file
    local temp_info=$(create_temp_test_file "java")
    local temp_dir=$(echo "$temp_info" | cut -d':' -f1)
    local test_file=$(echo "$temp_info" | cut -d':' -f2)
    
    print_info "Opening $ide_type with test file..."
    
    if [ "$os_type" = "$OS_TYPE_MAC" ]; then
        open -a "$ide_app_name" "$test_file"
    elif [ "$os_type" = "$OS_TYPE_LINUX" ]; then
        "$ide_command" "$test_file"
    fi
    
    wait_for_user_confirmation "Please test the Flow Coder extension in $ide_type and press Enter when finished..."
    
    cleanup_temp_files "$temp_dir"
    return 0
}

test_jetbrains_ultimate() {
    test_jetbrains_ide "JetBrains Ultimate" "idea" "IntelliJ IDEA"
}

test_jetbrains_community() {
    test_jetbrains_ide "JetBrains Community Edition" "idea-ce" "IntelliJ IDEA CE"
}

check_extension_status() {
    print_info "Running automated tests for Flow Coder..."
    local os_type=$(detect_os)
    
    # Check VSCode
    if command_exists code; then
        local extension_list=$(code --list-extensions)
        if echo "$extension_list" | grep -q "$VSCODE_EXTENSION_ID"; then
            print_success "VSCode: Flow Coder installed"
        else
            print_error "VSCode: Flow Coder not installed"
        fi
    else
        print_alert "VSCode: Not installed"
    fi
    
    # Check JetBrains Ultimate
    if [ "$os_type" = "$OS_TYPE_MAC" ] && [ -d "/Applications/IntelliJ IDEA.app" ]; then
        print_success "JetBrains Ultimate: Installed (manually check if the plugin is active)"
    elif [ "$os_type" = "$OS_TYPE_LINUX" ] && command_exists idea; then
        print_success "JetBrains Ultimate: Installed (manually check if the plugin is active)"
    else
        print_alert "JetBrains Ultimate: Not installed"
    fi
    
    # Check JetBrains Community Edition
    if [ "$os_type" = "$OS_TYPE_MAC" ] && [ -d "/Applications/IntelliJ IDEA CE.app" ]; then
        print_success "JetBrains Community Edition: Installed (manually check if the plugin is active)"
    elif [ "$os_type" = "$OS_TYPE_LINUX" ] && command_exists idea-ce; then
        print_success "JetBrains Community Edition: Installed (manually check if the plugin is active)"
    else
        print_alert "JetBrains Community Edition: Not installed"
    fi
}

test_all_ides() {
    print_header "Testing Flow Coder in all IDEs"
    test_vscode
    test_jetbrains_ultimate
    test_jetbrains_community
    print_success "All tests completed."
}

# User interface
show_menu() {
    echo "===== Flow Coder Extension Test ====="
    echo "1. Test Flow Coder in VSCode"
    echo "2. Test Flow Coder in JetBrains Ultimate"
    echo "3. Test Flow Coder in JetBrains Community Edition"
    echo "4. Test Flow Coder in all IDEs"
    echo "5. Check Flow Coder extension status"
    echo "6. Exit"
    echo "===================================="
}

# Function to handle the interactive menu
run_interactive_menu() {
    while true; do
        show_menu
        read -p "Enter your choice (1-6): " choice
        
        case $choice in
            1) 
                test_vscode
                ;;
            2) 
                test_jetbrains_ultimate
                ;;
            3) 
                test_jetbrains_community
                ;;
            4) 
                test_all_ides
                ;;
            5) 
                check_extension_status
                ;;
            6) 
                print_info "Exiting..."
                exit 0
                ;;
            *) 
                print_error "Invalid option. Try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Main function
test_flow_coder() {
    # Check if script is being called directly or from another script
    local is_direct_call=0
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        is_direct_call=1
    fi

    print_header "Starting Flow Coder extension test..."
    
    # If called from another script, run all tests automatically
    if [[ $is_direct_call -eq 0 ]]; then
        if ! confirm_action "Do you want Flow Coder extension test ?"; then
            print_info "Skipping install"
            return 0
        fi
        check_extension_status
        return 0
    fi
    
    # If called directly, show the interactive menu
    run_interactive_menu
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_flow_coder "$@"
fi