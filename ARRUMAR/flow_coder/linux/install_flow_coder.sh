#!/bin/bash

# Script to install Flow Coder in VSCode and JetBrains IDEs (Ultimate and Community Edition)
# Supports macOS and Linux

# Imports Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/generic_utils.sh"

# Constants
readonly FLOW_CODER_VSCODE_EXTENSION="ciandt-global.ciandt-flow"
readonly FLOW_CODER_PLUGIN_URL="https://downloads.marketplace.jetbrains.com/files/27434/780089/flow-coder-extension-0.2.0.zip?updateId=780089&pluginId=27434&family=INTELLIJ"


# VSCode Installation Functions
get_vscode_extensions_dir() {
    local os_type=$1
    
    if [ "$os_type" = "$OS_TYPE_MAC" ]; then
        echo "$HOME/.vscode/extensions"
    else
        echo "$HOME/.vscode/extensions"
    fi
}

install_vscode_extension() {
    local os_type=$1
    print_header_info "Installing Flow Coder in VSCode..."
    
    # Check if VSCode is installed
    if command_exists code; then
        code --install-extension $FLOW_CODER_VSCODE_EXTENSION
        print_info "Flow Coder successfully installed in VSCode."
        return 0
    else
        print_alert "VSCode not found. Trying to install manually..."
        
        # Get VSCode extensions directory
        local vscode_extensions_dir=$(get_vscode_extensions_dir "$os_type")
        
        # Create extensions directory if it doesn't exist
        mkdir -p "$vscode_extensions_dir"
        
        print_alert "Manual installation not implemented. Please install VSCode first."
        return 1
    fi
}

# JetBrains Installation Functions

get_jetbrains_dirs() {
    local os_type=$1

    
    echo 
}

install_plugin_to_ide() {
    local ide_dir=$1
    print_header_info "Installing Flow Coder in: $ide_dir"
    
    # Download the FlowCoder plugin
    local temp_dir=$(mktemp -d)
    local plugin_zip="$temp_dir/flow-coder.zip"
    
    print_info "Downloading FlowCoder plugin..."
    if download_file "$FLOW_CODER_PLUGIN_URL" "$plugin_zip"; then
        print_info "Extracting plugin to $ide_dir/plugins/flow-coder"
        mkdir -p "$ide_dir/plugins"
        unzip -q "$plugin_zip" -d "$ide_dir/plugins"
        print_info "FlowCoder plugin installed in $ide_dir/plugins"
        rm -rf "$temp_dir"
        return 0
    else
        print_error "Error downloading the FlowCoder plugin"
        rm -rf "$temp_dir"
        return 1
    fi
}

install_jetbrains_plugin() {
    local os_type=$1
    print_info "Installing Flow Coder in JetBrains IDEs..."
    
    local jetbrains_dirs
    
    local dirs=()
    
    if [ "$os_type" = "macOS" ]; then
        dirs+=("$HOME/Library/Application Support/JetBrains")
    else
        dirs+=("$HOME/.local/share/JetBrains")
        dirs+=("$HOME/.config/JetBrains")
    fi

    jetbrains_dirs="${dirs[@]}"

    local plugin_found=false
    
    for jetbrains_dir in "${jetbrains_dirs[@]}"; do

        if [ -d "$jetbrains_dir" ]; then
            print_info "JetBrains directory found: $jetbrains_dir"
            
            # Look for IDE directories (both Ultimate and Community)
            find "$jetbrains_dir" -maxdepth 1 -type d -name "*20*" | while IFS= read -r ide_dir; do
                if [ -d "$ide_dir/plugins" ]; then
                    install_plugin_to_ide "$ide_dir"
                    plugin_found=true
                fi
            done
        fi
    done
    
    if [ "$plugin_found" = false ]; then
        print_alert "No JetBrains installation found."
        print_alert "Please manually install the Flow Coder plugin through the JetBrains plugin marketplace."
        return 1
    else
        print_info "To complete the installation, restart your JetBrains IDEs and activate the Flow Coder plugin in the settings."
        return 0
    fi
}

# Install Flow Coder in all supported IDEs
install_all() {
    local os_type=$1
    
    # Install Flow Coder in VSCode
    install_vscode_extension "$os_type"
    
    # Install Flow Coder in JetBrains IDEs
    install_jetbrains_plugin "$os_type"
    
    print_success "Flow Coder installation process completed."
}

# Show installation menu
show_menu() {
    echo "===== Flow Coder Installation ====="
    echo "1. Install Flow Coder in VSCode"
    echo "2. Install Flow Coder in JetBrains IDEs"
    echo "3. Install Flow Coder in all supported IDEs"
    echo "4. Exit"
    echo "===================================================="
}

# Function to handle the interactive menu
run_interactive_menu() {
    local os_type=$1
    
    while true; do
        show_menu
        read -p "Choose an option (1-4): " choice
        
        case $choice in
            1)
                install_vscode_extension "$os_type"
                ;;
            2)
                install_jetbrains_plugin "$os_type"
                ;;
            3)
                install_all "$os_type"
                ;;
            4)
                print_info "Exiting installer..."
                exit 0
                ;;
            *)
                print_alert "Invalid option. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Main
install_flow_coder() {
    print_header "Starting Flow Coder installation..."

    local os="$1"
    if [[ -z "$os" ]]; then
        detect_os
    fi

    # Check if script is being called directly or from another script
    local is_direct_call=0
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        is_direct_call=1
    fi
    
    # If called from another script, install all tools automatically
    if [[ $is_direct_call -eq 0 ]]; then
        if ! confirm_action "Do you want Install flow-coder-extension in vscode and jetbrains ?"; then
            print_info "Skipping install"
            return 0
        fi
        install_all "$os"
        return 0
    fi
    
    # Run interactive menu for direct calls
    run_interactive_menu "$os"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_flow_coder "$@"
fi