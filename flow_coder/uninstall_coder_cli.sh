#!/bin/bash

# Flow Coder CLI Uninstallation Script
# This script removes Python 3.12.9, pyenv, pipx, and Flow Coder CLI
# Compatible with Linux and macOS

set -e  # Exit immediately if a command exits with a non-zero status

###########################################
# IMPORT UTILITY SCRIPTS
###########################################

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utility scripts
source "$PROJECT_ROOT/utils/colors_message.sh"
source "$PROJECT_ROOT/utils/detect_os.sh"

###########################################
# GLOBAL VARIABLES
###########################################

# Array to track removed components
declare -a REMOVED_COMPONENTS=()

# Function to add a component to the tracking array
_add_removed_component() {
    local comp_name=$1
    local comp_path=$2
    
    if [[ -n "$comp_path" ]]; then
        REMOVED_COMPONENTS+=("$comp_name - $comp_path")
    else
        REMOVED_COMPONENTS+=("$comp_name")
    fi
}

# Function to display all removed components
_show_removed_components() {
    print_header "Removed Components"
    
    if [ ${#REMOVED_COMPONENTS[@]} -eq 0 ]; then
        print_alert "No components were removed."
        return
    fi
    
    print_info "The following components were removed:"
    echo
    
    for ((i=0; i<${#REMOVED_COMPONENTS[@]}; i++)); do
        echo -e "${RED}🗑️ ${REMOVED_COMPONENTS[$i]}${NC}"
    done
    
    echo
}

###########################################
# PRIVATE FUNCTIONS (Internal use only)
###########################################

# Function to check if a command exists
_command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect shell profile
_detect_shell_profile() {
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *zsh ]]; then
        if [[ -f "$HOME/.zshrc" ]]; then
            echo "$HOME/.zshrc"
        else
            echo "$HOME/.zshrc"  # Create it if it doesn't exist
        fi
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *bash ]]; then
        if [[ -f "$HOME/.bashrc" ]]; then
            echo "$HOME/.bashrc"
        else
            echo "$HOME/.bash_profile"
        fi
    else
        # Default to .profile if shell can't be determined
        echo "$HOME/.profile"
    fi
}

# Function to ask user for confirmation
_ask_confirmation() {
    local message=$1
    local default=${2:-Y}
    
    if [[ "$default" == "Y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    print_alert "$message $prompt"
    read -r response
    
    # Default response if user just presses Enter
    if [[ -z "$response" ]]; then
        response=$default
    fi
    
    # Convert to lowercase
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$response" == "y" || "$response" == "yes" ]]; then
        return 0  # True in bash
    else
        return 1  # False in bash
    fi
}

# Function to remove pyenv configuration from shell profile
_remove_pyenv_from_profile() {
    local profile=$1
    
    if [[ -f "$profile" ]]; then
        print_info "Removing pyenv configuration from $profile..."
        
        # Create a temporary file
        local temp_file=$(mktemp)
        
        # Remove pyenv configuration lines
        grep -v "pyenv init" "$profile" | grep -v "PYENV_ROOT" | grep -v "PATH=\"\$PYENV_ROOT/bin:\$PATH\"" > "$temp_file"
        
        # Replace the original file with the modified one
        mv "$temp_file" "$profile"
        
        print_success "pyenv configuration removed from $profile."
    fi
}

# Function to backup a file before removing it
_backup_file() {
    local file=$1
    local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
    
    if [[ -f "$file" ]]; then
        print_info "Creating backup of $file to $backup..."
        cp "$file" "$backup"
        print_success "Backup created: $backup"
    fi
}

###########################################
# PUBLIC FUNCTIONS (Main uninstallation steps)
###########################################

# Function to uninstall Flow Coder CLI
uninstall_flow_coder_cli() {
    if _command_exists flow-coder; then
        if _ask_confirmation "Do you want to uninstall Flow Coder CLI?"; then
            print_header_info "Uninstalling Flow Coder CLI..."
            
            # Get the path before uninstalling
            local flow_coder_path=$(which flow-coder 2>/dev/null || echo "$HOME/.local/bin/flow-coder")
            
            # Uninstall Flow Coder CLI using pipx
            if _command_exists pipx; then
                pipx uninstall flow-coder 2>/dev/null || true
            fi
            
            # Remove any remaining files
            if [[ -f "$flow_coder_path" ]]; then
                rm -f "$flow_coder_path"
            fi
            
            _add_removed_component "Flow Coder CLI" "$flow_coder_path"
            print_success "Flow Coder CLI uninstalled successfully."
        else
            print_alert "Skipping Flow Coder CLI uninstallation."
        fi
    else
        print_info "Flow Coder CLI is not installed."
    fi
}

# Function to uninstall pipx
uninstall_pipx() {
    if _command_exists pipx; then
        if _ask_confirmation "Do you want to uninstall pipx?"; then
            print_header_info "Uninstalling pipx..."
            
            # Get the path before uninstalling
            local pipx_path=$(which pipx 2>/dev/null || echo "$HOME/.local/bin/pipx")
            
            # Uninstall pipx
            python -m pip uninstall -y pipx 2>/dev/null || true
            
            # Remove pipx directory
            if [[ -d "$HOME/.local/pipx" ]]; then
                rm -rf "$HOME/.local/pipx"
            fi
            
            # Remove pipx binary
            if [[ -f "$pipx_path" ]]; then
                rm -f "$pipx_path"
            fi
            
            _add_removed_component "pipx" "$pipx_path"
            print_success "pipx uninstalled successfully."
        else
            print_alert "Skipping pipx uninstallation."
        fi
    else
        print_info "pipx is not installed."
    fi
}

# Function to uninstall pyenv and Python versions
uninstall_pyenv() {
    if [[ -d "$HOME/.pyenv" ]]; then
        if _ask_confirmation "Do you want to uninstall pyenv and all installed Python versions?"; then
            print_header_info "Uninstalling pyenv..."
            
            # Remove pyenv configuration from shell profile
            local profile=$(_detect_shell_profile)
            _remove_pyenv_from_profile "$profile"
            
            # Backup .pyenv directory
            _backup_file "$HOME/.pyenv"
            
            # Remove pyenv directory
            rm -rf "$HOME/.pyenv"
            
            _add_removed_component "pyenv" "$HOME/.pyenv"
            _add_removed_component "Python versions (managed by pyenv)" "$HOME/.pyenv/versions"
            
            print_success "pyenv and all installed Python versions uninstalled successfully."
        else
            print_alert "Skipping pyenv uninstallation."
        fi
    else
        print_info "pyenv is not installed."
    fi
}

# Function to uninstall Python installed from source
uninstall_python_from_source() {
    local install_dir="$HOME/.local/python3.12.9"
    
    if [[ -d "$install_dir" ]]; then
        if _ask_confirmation "Do you want to uninstall Python 3.12.9 installed from source?"; then
            print_header_info "Uninstalling Python 3.12.9 from source..."
            
            # Backup Python directory
            _backup_file "$install_dir"
            
            # Remove Python directory
            rm -rf "$install_dir"
            
            _add_removed_component "Python 3.12.9 (from source)" "$install_dir"
            print_success "Python 3.12.9 from source uninstalled successfully."
        else
            print_alert "Skipping Python 3.12.9 from source uninstallation."
        fi
    else
        print_info "Python 3.12.9 from source is not installed at $install_dir."
    fi
}

# Function to clean up any remaining files
cleanup_remaining_files() {
    if _ask_confirmation "Do you want to clean up any remaining temporary files?"; then
        print_header_info "Cleaning up remaining files..."
        
        # Remove temporary files created during installation
        if [[ -f "/tmp/command_output.log" ]]; then
            rm -f "/tmp/command_output.log"
            _add_removed_component "Temporary log file" "/tmp/command_output.log"
        fi
        
        if [[ -f "/tmp/python_configure.log" ]]; then
            rm -f "/tmp/python_configure.log"
            _add_removed_component "Python configure log" "/tmp/python_configure.log"
        fi
        
        if [[ -f "/tmp/python_build.log" ]]; then
            rm -f "/tmp/python_build.log"
            _add_removed_component "Python build log" "/tmp/python_build.log"
        fi
        
        print_success "Cleanup completed."
    else
        print_alert "Skipping cleanup of remaining files."
    fi
}

# Function to reload shell profile
reload_shell_profile() {
    local profile=$(_detect_shell_profile)
    
    if _ask_confirmation "Do you want to reload your shell profile ($profile)?"; then
        print_info "Reloading shell profile: $profile"
        # shellcheck disable=SC1090
        source "$profile"
        print_success "Shell profile reloaded."
    else
        print_alert "Skipping shell profile reload. You'll need to reload it manually with: source $profile"
    fi
}

# Main uninstallation process
run_uninstallation() {
    print_header "Starting Flow Coder CLI uninstallation process..."
    print
    
    # Detect OS using the imported detect_os function
    detect_os
    
    # Detect shell profile
    local profile=$(_detect_shell_profile)
    print_info "Using shell profile: $profile"
    
    # Uninstall Flow Coder CLI
    uninstall_flow_coder_cli
    
    # Uninstall pipx
    uninstall_pipx
    
    # Uninstall pyenv and Python versions
    uninstall_pyenv
    
    # Uninstall Python from source
    uninstall_python_from_source
    
    # Clean up remaining files
    cleanup_remaining_files
    
    # Reload shell profile
    reload_shell_profile
    
    # Show removed components
    _show_removed_components
    
    # Final instructions
    print_header "Uninstallation process completed!"
    print_info "To apply all changes, please restart your terminal or run:"
    print "source $profile"
    
    print_success "Flow Coder CLI and its dependencies have been successfully removed!"
}

# Run the uninstallation process
run_uninstallation