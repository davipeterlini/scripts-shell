#!/usr/bin/env bash

# uninstall_flow_coder_ide.sh
# Script to uninstall FlowCoder IDE plugins for VS Code and JetBrains IDEs

set -e

# Import utility scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/utils/colors_message.sh"
source "$ROOT_DIR/utils/detect_os.sh"
source "$ROOT_DIR/utils/bash_tools.sh"

# Constants
PLUGIN_NAME_VSCODE="ciandt-global.ciandt-flow"
FLOWCODER_PLUGIN_ID="27434"

# Uninstall VS Code plugin
uninstall_vscode_plugin() {
    print_header_info "Uninstalling FlowCoder plugin for VS Code"
    
    if ! get_user_confirmation "Do you want to uninstall FlowCoder plugin for VS Code?"; then
        print_alert "VS Code plugin uninstallation skipped by user"
        return 0
    fi
    
    # Check if VS Code is installed
    if ! command -v code &>/dev/null; then
        print_info "VS Code command line tool not found, nothing to uninstall"
        return 0
    fi
    
    # Check if the plugin is installed
    if code --list-extensions | grep -q "$PLUGIN_NAME_VSCODE"; then
        print_info "Uninstalling FlowCoder plugin from VS Code..."
        if code --uninstall-extension "$PLUGIN_NAME_VSCODE"; then
            print_success "FlowCoder plugin uninstalled successfully from VS Code"
        else
            print_error "Failed to uninstall FlowCoder plugin from VS Code"
            return 1
        fi
    else
        print_info "FlowCoder plugin is not installed for VS Code"
    fi
    
    return 0
}

# Uninstall JetBrains Toolbox CLI
uninstall_jetbrains_toolbox_cli() {
    print_header_info "Uninstalling JetBrains Toolbox CLI"
    
    if ! get_user_confirmation "Do you want to uninstall JetBrains Toolbox CLI?"; then
        print_alert "JetBrains Toolbox CLI uninstallation skipped by user"
        return 0
    fi
    
    local toolbox_cli_path="$HOME/.local/bin/jetbrains-toolbox-cli"
    
    # Check if JetBrains Toolbox CLI is installed
    if [[ -f "$toolbox_cli_path" ]]; then
        print_info "Removing JetBrains Toolbox CLI..."
        rm -f "$toolbox_cli_path"
        print_success "JetBrains Toolbox CLI removed successfully"
    else
        print_info "JetBrains Toolbox CLI is not installed at $toolbox_cli_path"
    fi
    
    return 0
}

# Uninstall JetBrains plugin
uninstall_jetbrains_plugin() {
    print_header_info "Uninstalling FlowCoder plugin for JetBrains IDEs"
    
    if ! get_user_confirmation "Do you want to uninstall FlowCoder plugin for JetBrains IDEs?"; then
        print_alert "JetBrains plugin uninstallation skipped by user"
        return 0
    fi
    
    local toolbox_cli_path="$HOME/.local/bin/jetbrains-toolbox-cli"
    
    # Check if JetBrains Toolbox CLI is installed
    if [[ ! -f "$toolbox_cli_path" ]] || [[ ! -x "$toolbox_cli_path" ]]; then
        print_info "JetBrains Toolbox CLI not found, cannot uninstall plugin automatically"
        print_alert "Please uninstall the FlowCoder plugin manually from your JetBrains IDE"
        return 0
    fi
    
    # Get IDE type from user
    print_alert "Select JetBrains IDE type for plugin uninstallation:"
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
            print_error "Invalid choice. Exiting plugin uninstallation."
            return 1
            ;;
    esac
    
    # Uninstall the plugin using the toolbox CLI
    print_info "Uninstalling FlowCoder plugin (ID: $FLOWCODER_PLUGIN_ID) from $ide_code..."
    
    if "$toolbox_cli_path" plugin uninstall --ide-code "$ide_code" --plugin-id "$FLOWCODER_PLUGIN_ID"; then
        print_success "FlowCoder plugin uninstalled successfully from $ide_code"
    else
        print_error "Failed to uninstall FlowCoder plugin via JetBrains Toolbox CLI"
        print_alert "You may need to uninstall the plugin manually through your JetBrains IDE"
        print_alert "Go to Settings > Plugins, find FlowCoder and click Uninstall"
        return 1
    fi
    
    return 0
}

# Clean up any remaining files
clean_up_remaining_files() {
    print_header_info "Cleaning up remaining files"
    
    if ! get_user_confirmation "Do you want to clean up any remaining FlowCoder IDE files?"; then
        print_alert "Cleanup skipped by user"
        return 0
    fi
    
    # Clean up VS Code extension data
    local vscode_ext_dir="$HOME/.vscode/extensions"
    if [[ -d "$vscode_ext_dir" ]]; then
        print_info "Checking for FlowCoder extension data in VS Code..."
        local flow_coder_dirs=$(find "$vscode_ext_dir" -type d -name "ciandt-global.ciandt-flow*" 2>/dev/null || true)
        
        if [[ -n "$flow_coder_dirs" ]]; then
            print_info "Found FlowCoder extension directories:"
            echo "$flow_coder_dirs"
            
            if get_user_confirmation "Do you want to remove these directories?"; then
                echo "$flow_coder_dirs" | xargs rm -rf
                print_success "FlowCoder extension directories removed"
            fi
        else
            print_info "No FlowCoder extension directories found in VS Code"
        fi
    fi
    
    # Clean up JetBrains plugin data
    local jetbrains_config_dir="$HOME/.config/JetBrains"
    if [[ -d "$jetbrains_config_dir" ]]; then
        print_info "Checking for FlowCoder plugin data in JetBrains IDEs..."
        print_alert "Note: Manual cleanup may be required for JetBrains plugin data"
        print_alert "Check directories under $jetbrains_config_dir for any FlowCoder related files"
    fi
    
    return 0
}

# Verify uninstallation
verify_uninstallation() {
    print_header_info "Verifying Uninstallation"
    
    local all_removed=true
    
    # Check if VS Code plugin is still installed
    if command -v code &>/dev/null && code --list-extensions | grep -q "$PLUGIN_NAME_VSCODE"; then
        print_alert "FlowCoder plugin is still installed for VS Code"
        all_removed=false
    else
        print_success "FlowCoder plugin has been removed from VS Code"
    fi
    
    # Check if JetBrains Toolbox CLI is still installed
    local toolbox_cli_path="$HOME/.local/bin/jetbrains-toolbox-cli"
    if [[ -f "$toolbox_cli_path" ]]; then
        print_alert "JetBrains Toolbox CLI is still installed"
        print_info "This is not necessarily a problem if you use it for other purposes"
    else
        print_success "JetBrains Toolbox CLI has been removed"
    fi
    
    # Note about JetBrains plugin
    print_alert "Note: Full verification of JetBrains plugin removal requires manual checking in each IDE"
    print_alert "Please open your JetBrains IDE and check if the FlowCoder plugin is still listed in Settings > Plugins"
    
    if $all_removed; then
        print_success "All components have been successfully uninstalled"
    else
        print_alert "Some components may still be installed"
        print_info "You may need to manually remove remaining components or restart your IDE"
    fi
}

# Main function to uninstall FlowCoder IDE plugins
uninstall_flow_coder_ide() {
    print_header "FlowCoder IDE Plugins Uninstallation Script"
    
    if ! get_user_confirmation "This script will uninstall FlowCoder plugins for VS Code and/or JetBrains IDEs. Continue?"; then
        print_alert "Uninstallation cancelled by user"
        exit 0
    fi
    
    # Detect OS
    detect_os
    print_info "Operating System: $OS_NAME $OS_VERSION"
    
    # Uninstall components
    uninstall_vscode_plugin
    uninstall_jetbrains_plugin
    uninstall_jetbrains_toolbox_cli
    
    # Clean up remaining files
    clean_up_remaining_files
    
    # Final verification
    verify_uninstallation
    
    print_header_info "Uninstallation Complete"
    print_alert "IMPORTANT: You may need to restart your IDE for all changes to take effect"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    uninstall_flow_coder_ide "$@"
fi