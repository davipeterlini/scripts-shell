#!/usr/bin/env bash

# install_flow_coder_ide.sh
# Script to install and configure FlowCoder IDE plugins for VS Code and JetBrains IDEs

set -e

# Import utility scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/utils/colors_message.sh"
source "$ROOT_DIR/utils/detect_os.sh"
source "$ROOT_DIR/utils/bash_tools.sh"
source "$ROOT_DIR/utils/setup_ides.sh"

# Constants
PLUGIN_NAME_VSCODE="ciandt-global.ciandt-flow"
FLOWCODER_PLUGIN_ID="27434"

# Check if VS Code is installed and available
check_vscode() {
    print_header_info "Checking VS Code installation"
    
    if ! command -v code &>/dev/null; then
        print_alert "VS Code command line tool not found"
        return 1
    fi
    
    # Check VS Code version
    local vscode_version=$(code --version | head -n 1)
    print_info "VS Code version: $vscode_version"
    
    # Check if VS Code extension manager is working
    if ! code --list-extensions &>/dev/null; then
        print_alert "VS Code extension manager is not working correctly"
        return 1
    fi
    
    print_success "VS Code is installed and configured correctly"
    return 0
}

# Check if JetBrains Toolbox CLI is installed
check_jetbrains_toolbox_cli() {
    print_header_info "Checking JetBrains Toolbox CLI installation"
    
    local toolbox_cli_path="$HOME/.local/bin/jetbrains-toolbox-cli"
    
    if [[ ! -f "$toolbox_cli_path" ]] || [[ ! -x "$toolbox_cli_path" ]]; then
        print_alert "JetBrains Toolbox CLI not found at $toolbox_cli_path"
        return 1
    fi
    
    # Check if the CLI is working
    if ! "$toolbox_cli_path" --version &>/dev/null; then
        print_alert "JetBrains Toolbox CLI is not working correctly"
        return 1
    fi
    
    local toolbox_version=$("$toolbox_cli_path" --version 2>&1)
    print_info "JetBrains Toolbox CLI version: $toolbox_version"
    
    print_success "JetBrains Toolbox CLI is installed and working correctly"
    return 0
}

# Check if FlowCoder plugin is installed for VS Code
check_vscode_plugin() {
    print_header_info "Checking FlowCoder plugin for VS Code"
    
    if ! command -v code &>/dev/null; then
        print_alert "VS Code command line tool not found"
        return 1
    fi
    
    # Check if the plugin is installed
    if code --list-extensions | grep -q "$PLUGIN_NAME_VSCODE"; then
        local plugin_version=$(code --list-extensions --show-versions | grep "$PLUGIN_NAME_VSCODE" | cut -d '@' -f 2)
        print_info "FlowCoder plugin is installed for VS Code (version: $plugin_version)"
        print_success "FlowCoder plugin is installed for VS Code"
        return 0
    else
        print_alert "FlowCoder plugin is not installed for VS Code"
        return 1
    fi
}

# Check if FlowCoder plugin is installed for JetBrains IDEs
check_jetbrains_plugin() {
    print_header_info "Checking FlowCoder plugin for JetBrains IDEs"
    
    local toolbox_cli_path="$HOME/.local/bin/jetbrains-toolbox-cli"
    
    if [[ ! -f "$toolbox_cli_path" ]] || [[ ! -x "$toolbox_cli_path" ]]; then
        print_alert "JetBrains Toolbox CLI not found"
        return 1
    fi
    
    # List installed plugins (this is a simplified check as there's no direct way to check)
    print_info "Checking installed JetBrains plugins..."
    
    # This is a simplified check - in reality, we would need to check each IDE separately
    print_alert "Note: Full verification of JetBrains plugins requires manual checking in each IDE"
    
    return 0
}

# Install VS Code plugin from local VSIX file
install_plugin_vscode() {
    print_header_info "Installing FlowCoder plugin for VS Code from local VSIX"
    
    if ! get_user_confirmation "Do you want to install FlowCoder plugin for VS Code from local VSIX?"; then
        print_alert "VS Code plugin installation skipped by user"
        return 0
    fi
    
    # Check if VS Code is installed
    if ! command -v code &>/dev/null; then
        print_error "VS Code command line tool not found"
        print_alert "Please install VS Code first"
        return 1
    fi

    detect_os
    # Get OS and architecture information
    local os_type="$OS_NAME"
    local arch_type="$ARCH"
    
    print_info "Installing VS Code extension for $os_type on $arch_type architecture"
    
    # Path to the extension build directory
    local extension_build_dir="$ROOT_DIR/extensions/vscode/build"
    
    # Check if the build directory exists
    if [ ! -d "$extension_build_dir" ]; then
        print_alert "Extension build directory not found: $extension_build_dir"
        return 1
    fi
    
    # Find the VSIX file matching the current OS and architecture
    # First try to find an exact match for OS and architecture
    local vsix_file=$(find "$extension_build_dir" -name "*${OS_ARQ}*${arch_type}*.vsix" | head -n 1)

    # If no specific match found, try to find any VSIX file
    if [ -z "$vsix_file" ]; then
        print_info "No specific build found for $OS_ARQ-$arch_type, looking for any compatible build"
        vsix_file=$(find "$extension_build_dir" -name "*.vsix" | head -n 1)
    fi
    
    if [ -z "$vsix_file" ]; then
        print_alert "No VSIX file found in $extension_build_dir"
        return 1
    fi
    
    print_info "Installing extension from: $vsix_file"
    
    # Check if the extension is already installed
    if code --list-extensions | grep -q "$PLUGIN_NAME_VSCODE"; then
        print_info "Extension $PLUGIN_NAME_VSCODE is already installed. Removing it first..."
        code --uninstall-extension "$PLUGIN_NAME_VSCODE"
    fi
    
    if code --install-extension "$vsix_file" --force; then
        print_success "VS Code extension installed successfully!"
        return 0
    else
        print_error "Failed to install VS Code extension"
        return 1
    fi
}

# Install VS Code plugin from marketplace
install_plugin_marketplace_vscode() {
    print_header_info "Installing FlowCoder plugin for VS Code from marketplace"
    
    if ! get_user_confirmation "Do you want to install FlowCoder plugin for VS Code from marketplace?"; then
        print_alert "VS Code plugin installation skipped by user"
        return 0
    fi
    
    # Check if VS Code is installed
    if ! command -v code &>/dev/null; then
        print_error "VS Code command line tool not found"
        print_alert "Please install VS Code first"
        return 1
    }

    print_info "Installing VS Code extension from marketplace: $PLUGIN_NAME_VSCODE"
    
    # Check if the extension is already installed
    if code --list-extensions | grep -q "$PLUGIN_NAME_VSCODE"; then
        print_info "Extension $PLUGIN_NAME_VSCODE is already installed. Removing it first..."
        code --uninstall-extension "$PLUGIN_NAME_VSCODE"
    fi
    
    # Install the plugin
    if code --install-extension "$PLUGIN_NAME_VSCODE"; then
        print_success "VS Code extension installed successfully!"
        return 0
    else
        print_error "Failed to install VS Code extension"
        return 1
    fi
}

# Install JetBrains Toolbox CLI
install_jetbrains_toolbox_cli() {
    print_header_info "Installing JetBrains Toolbox CLI"
    
    if ! get_user_confirmation "Do you want to install JetBrains Toolbox CLI?"; then
        print_alert "JetBrains Toolbox CLI installation skipped by user"
        return 0
    fi
    
    # Determine OS type for installation
    detect_os
    local os_type="$OS_NAME"
    local arch="$ARCH"
    local toolbox_cli_dir="$HOME/.local/bin"
    local toolbox_cli_path="$toolbox_cli_dir/jetbrains-toolbox-cli"
    
    # Create directory if it doesn't exist
    mkdir -p "$toolbox_cli_dir"
    
    # Download and install JetBrains Toolbox CLI based on OS
    case "$os_type" in
        "macOS")
            local download_url="https://raw.githubusercontent.com/JetBrains/toolbox-cli/master/bin/mac/jetbrains-toolbox-cli"
            curl -L "$download_url" -o "$toolbox_cli_path"
            ;;
        "Linux")
            local download_url="https://raw.githubusercontent.com/JetBrains/toolbox-cli/master/bin/linux/jetbrains-toolbox-cli"
            curl -L "$download_url" -o "$toolbox_cli_path"
            ;;
        "Windows")
            print_alert "For Windows, please download the JetBrains Toolbox CLI manually from:"
            print_alert "https://github.com/JetBrains/toolbox-cli"
            return 1
            ;;
        *)
            print_error "Unsupported operating system: $os_type"
            return 1
            ;;
    esac
    
    # Make the CLI executable
    chmod +x "$toolbox_cli_path"
    
    # Check if installation was successful
    if ! command -v "$toolbox_cli_path" &>/dev/null; then
        print_error "Failed to install JetBrains Toolbox CLI"
        print_alert "Please install it manually from: https://github.com/JetBrains/toolbox-cli"
        return 1
    fi
    
    print_success "JetBrains Toolbox CLI installed successfully!"
    return 0
}

# Install JetBrains plugin using Toolbox CLI
install_plugin_jetbrains() {
    print_header_info "Installing FlowCoder plugin for JetBrains IDE"
    
    if ! get_user_confirmation "Do you want to install FlowCoder plugin for JetBrains IDE?"; then
        print_alert "JetBrains plugin installation skipped by user"
        return 0
    fi
    
    local toolbox_cli_path="$HOME/.local/bin/jetbrains-toolbox-cli"
    
    # Check if JetBrains Toolbox CLI is installed
    if [[ ! -f "$toolbox_cli_path" ]] || [[ ! -x "$toolbox_cli_path" ]]; then
        print_alert "JetBrains Toolbox CLI not found"
        install_jetbrains_toolbox_cli
        
        # Check again after installation
        if [[ ! -f "$toolbox_cli_path" ]] || [[ ! -x "$toolbox_cli_path" ]]; then
            print_error "Failed to install JetBrains Toolbox CLI"
            return 1
        fi
    fi
    
    # Install FlowCoder plugin using the toolbox CLI
    print_info "Installing FlowCoder plugin (ID: $FLOWCODER_PLUGIN_ID) using JetBrains Toolbox CLI..."
    
    # Get IDE type from user
    print_alert "Select JetBrains IDE type for plugin installation:"
    echo "1) IntelliJ IDEA"
    echo "2) PyCharm"
    echo "3) WebStorm"
    echo "4) PhpStorm"
    echo "5) Other (specify name)"
    read -r choice

    local ide_code
    case "$choice" in
        1) ide_code="intellij" ;;
        2) ide_code="pycharm" ;;
        3) ide_code="webstorm" ;;
        4) ide_code="phpstorm" ;;
        5)
            print_alert "Enter the JetBrains IDE code (e.g., rubymine, clion): "
            read -r ide_code
            ;;
        *)
            print_error "Invalid choice. Exiting plugin installation."
            return 1
            ;;
    esac
    
    # Install the plugin using the toolbox CLI
    if "$toolbox_cli_path" plugin install --ide-code "$ide_code" --plugin-id "$FLOWCODER_PLUGIN_ID"; then
        print_success "FlowCoder plugin installed successfully via JetBrains Toolbox CLI!"
        return 0
    else
        print_error "Failed to install FlowCoder plugin via JetBrains Toolbox CLI"
        print_alert "You may need to install the plugin manually through the JetBrains Marketplace"
        return 1
    fi
}

# Verify installation of all components
verify_installation() {
    print_header_info "Verifying Installation"
    
    local all_ok=true
    
    # Check VS Code if available
    if command -v code &>/dev/null; then
        if ! check_vscode_plugin; then
            all_ok=false
        fi
    else
        print_info "VS Code not installed, skipping VS Code plugin check"
    fi
    
    # Check JetBrains Toolbox CLI if available
    local toolbox_cli_path="$HOME/.local/bin/jetbrains-toolbox-cli"
    if [[ -f "$toolbox_cli_path" ]] && [[ -x "$toolbox_cli_path" ]]; then
        if ! check_jetbrains_plugin; then
            all_ok=false
        fi
    else
        print_info "JetBrains Toolbox CLI not installed, skipping JetBrains plugin check"
    fi
    
    if $all_ok; then
        print_success "All available plugins are installed and configured correctly"
    else
        print_error "Some plugins are not installed or configured correctly"
    fi
}

# Main function to install FlowCoder IDE plugins
install_flow_coder_ide() {
    print_header "FlowCoder IDE Plugins Installation Script"
    
    if ! get_user_confirmation "This script will install FlowCoder plugins for VS Code and/or JetBrains IDEs. Continue?"; then
        print_alert "Installation cancelled by user"
        exit 0
    fi
    
    # Detect OS
    detect_os
    print_info "Operating System: $OS_NAME $OS_VERSION"
    
    # Check for installed IDEs
    check_installed_ides
    
    # Install plugins based on available IDEs
    if [ "$IDE_VSCODE_AVAILABLE" = true ]; then
        print_info "VS Code is available. Installing FlowCoder plugin..."
        
        # Ask user which installation method to use
        print_alert "Select VS Code plugin installation method:"
        echo "1) Install from local VSIX file"
        echo "2) Install from marketplace"
        read -r vscode_choice
        
        case "$vscode_choice" in
            1) install_plugin_vscode ;;
            2) install_plugin_marketplace_vscode ;;
            *) print_alert "Invalid choice. Skipping VS Code plugin installation." ;;
        esac
    else
        print_alert "VS Code is not installed. Skipping VS Code plugin installation."
        
        # Ask if user wants to install VS Code
        if get_user_confirmation "Do you want to install VS Code?"; then
            setup_vscode
            
            # Check again if VS Code is now available
            if command -v code &>/dev/null; then
                print_info "VS Code installed. Installing FlowCoder plugin..."
                
                # Ask user which installation method to use
                print_alert "Select VS Code plugin installation method:"
                echo "1) Install from local VSIX file"
                echo "2) Install from marketplace"
                read -r vscode_choice
                
                case "$vscode_choice" in
                    1) install_plugin_vscode ;;
                    2) install_plugin_marketplace_vscode ;;
                    *) print_alert "Invalid choice. Skipping VS Code plugin installation." ;;
                esac
            fi
        fi
    fi
    
    if [ "$IDE_JETBRAINS_AVAILABLE" = true ]; then
        print_info "JetBrains IDE is available. Installing FlowCoder plugin..."
        install_plugin_jetbrains
    else
        print_alert "No JetBrains IDE detected. Skipping JetBrains plugin installation."
        
        # Ask if user wants to install a JetBrains IDE
        if get_user_confirmation "Do you want to install a JetBrains IDE?"; then
            setup_jetbrains_ide
            
            # After installation, try to install the plugin
            print_info "Installing FlowCoder plugin for JetBrains IDE..."
            install_plugin_jetbrains
        fi
    fi
    
    # If no IDEs were available and none were installed
    if [ "$IDE_VSCODE_AVAILABLE" = false ] && [ "$IDE_JETBRAINS_AVAILABLE" = false ] && ! command -v code &>/dev/null; then
        print_error "No supported IDEs found or installed. Please install VS Code or a JetBrains IDE first."
        print_info "You can run the setup_ides.sh script to install an IDE."
        exit 1
    fi
    
    # Final verification
    verify_installation
    
    print_header_info "Installation Complete"
    print_info "FlowCoder IDE plugins have been installed"
    print_alert "Note: You may need to restart your IDE for the plugin to take effect"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_flow_coder_ide "$@"
fi