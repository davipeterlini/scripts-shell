#!/usr/bin/env bash

# uninstall_coder_cli.sh
# Script to uninstall Coder CLI, pipx, Python and pyenv

set -e

# Import utility scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/colors_message.sh"
source "$SCRIPT_DIR/utils/detect_os.sh"
source "$SCRIPT_DIR/utils/bash_tools.sh"

# Python version that was installed
PYTHON_VERSION="3.12.9"

uninstall_coder() {
    print_header_info "Uninstalling Coder CLI"
    
    if ! get_user_confirmation "Do you want to uninstall Coder CLI?"; then
        print_alert "Coder CLI uninstallation skipped by user"
        return 0
    fi
    
    # Check if coder is installed
    local coder_path="$HOME/.local/bin/coder"
    if [[ ! -f "$coder_path" ]]; then
        print_info "Coder CLI is not installed at $coder_path"
        return 0
    fi
    
    # Get the full path to the Python executable
    local python_path=$(which python || echo "")
    
    # Ensure ~/.local/bin is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Uninstall Coder CLI using pipx if available
    if command -v pipx &>/dev/null; then
        print_info "Uninstalling Coder CLI using pipx..."
        pipx uninstall flow_coder || true
    fi
    
    # Remove coder executable
    if [[ -f "$coder_path" ]]; then
        print_info "Removing Coder CLI executable..."
        rm -f "$coder_path"
    fi
    
    # Remove coder configuration
    local coder_config_dir="$HOME/.config/coder"
    if [[ -d "$coder_config_dir" ]]; then
        print_info "Removing Coder CLI configuration directory..."
        rm -rf "$coder_config_dir"
    fi
    
    print_success "Coder CLI uninstalled successfully"
    return 0
}

uninstall_pipx() {
    print_header_info "Uninstalling pipx"
    
    if ! get_user_confirmation "Do you want to uninstall pipx?"; then
        print_alert "pipx uninstallation skipped by user"
        return 0
    fi
    
    # Check if pipx is installed
    if ! command -v pipx &>/dev/null; then
        print_info "pipx is not installed"
        return 0
    fi
    
    # Get Python path
    local python_path=$(which python || echo "")
    
    # Uninstall pipx
    if [[ -n "$python_path" ]]; then
        print_info "Uninstalling pipx using pip..."
        "$python_path" -m pip uninstall -y pipx || true
    fi
    
    # Remove pipx directories
    print_info "Removing pipx directories..."
    rm -rf "$HOME/.local/pipx" || true
    
    # Remove pipx executable
    rm -f "$HOME/.local/bin/pipx" || true
    
    # Remove pipx from shell profile
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    # Remove pipx-related lines from shell profile
    if [[ -f "$shell_profile" ]]; then
        print_info "Removing pipx configuration from $shell_profile..."
        sed -i.bak '/# pipx configuration/d' "$shell_profile" || true
        sed -i.bak '/PIPX_DEFAULT_PYTHON/d' "$shell_profile" || true
        rm -f "${shell_profile}.bak" || true
    fi
    
    print_success "pipx uninstalled successfully"
    return 0
}

uninstall_python() {
    print_header_info "Uninstalling Python $PYTHON_VERSION"
    
    if ! get_user_confirmation "Do you want to uninstall Python $PYTHON_VERSION?"; then
        print_alert "Python uninstallation skipped by user"
        return 0
    fi
    
    # Check if pyenv is installed
    if ! command -v pyenv &>/dev/null; then
        print_info "pyenv is not installed, cannot uninstall Python $PYTHON_VERSION"
        return 0
    fi
    
    # Check if this version is installed
    if ! pyenv versions | grep -q $PYTHON_VERSION; then
        print_info "Python $PYTHON_VERSION is not installed with pyenv"
        return 0
    fi
    
    # Check if this version is set as global
    local current_version=$(pyenv global)
    if [[ "$current_version" == "$PYTHON_VERSION" ]]; then
        print_info "Python $PYTHON_VERSION is set as global version, switching to system Python..."
        pyenv global system
    fi
    
    # Uninstall the Python version
    print_info "Uninstalling Python $PYTHON_VERSION with pyenv..."
    pyenv uninstall -f $PYTHON_VERSION
    
    # Rehash to update shims
    pyenv rehash
    
    print_success "Python $PYTHON_VERSION uninstalled successfully"
    return 0
}

uninstall_pyenv() {
    print_header_info "Uninstalling pyenv"
    
    if ! get_user_confirmation "Do you want to uninstall pyenv?"; then
        print_alert "pyenv uninstallation skipped by user"
        return 0
    fi
    
    # Check if pyenv is installed
    if ! command -v pyenv &>/dev/null; then
        print_info "pyenv is not installed"
        return 0
    fi
    
    # Remove pyenv directory
    if [[ -d "$HOME/.pyenv" ]]; then
        print_info "Removing pyenv directory..."
        rm -rf "$HOME/.pyenv"
    fi
    
    # Remove pyenv from shell profile
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    # Remove pyenv-related lines from shell profile
    if [[ -f "$shell_profile" ]]; then
        print_info "Removing pyenv configuration from $shell_profile..."
        sed -i.bak '/# pyenv configuration/d' "$shell_profile" || true
        sed -i.bak '/PYENV_ROOT/d' "$shell_profile" || true
        sed -i.bak '/pyenv init/d' "$shell_profile" || true
        rm -f "${shell_profile}.bak" || true
    fi
    
    print_success "pyenv uninstalled successfully"
    return 0
}

clean_local_bin() {
    print_header_info "Cleaning up ~/.local/bin directory"
    
    if ! get_user_confirmation "Do you want to clean up the ~/.local/bin directory?"; then
        print_alert "~/.local/bin cleanup skipped by user"
        return 0
    fi
    
    # Check if directory exists
    if [[ ! -d "$HOME/.local/bin" ]]; then
        print_info "~/.local/bin directory does not exist"
        return 0
    fi
    
    # List files in ~/.local/bin
    print_info "Files in ~/.local/bin:"
    ls -la "$HOME/.local/bin"
    
    # Ask for confirmation to remove specific files
    if get_user_confirmation "Do you want to remove all files in ~/.local/bin?"; then
        print_info "Removing all files in ~/.local/bin..."
        rm -rf "$HOME/.local/bin"/*
        print_success "All files in ~/.local/bin removed"
    else
        print_info "Skipping removal of files in ~/.local/bin"
    fi
    
    return 0
}

verify_uninstallation() {
    print_header_info "Verifying Uninstallation"
    
    local all_removed=true
    
    # Check if coder is still installed
    if command -v coder &>/dev/null; then
        print_alert "Coder CLI is still installed"
        all_removed=false
    else
        print_success "Coder CLI has been removed"
    fi
    
    # Check if pipx is still installed
    if command -v pipx &>/dev/null; then
        print_alert "pipx is still installed"
        all_removed=false
    else
        print_success "pipx has been removed"
    fi
    
    # Check if Python version is still installed with pyenv
    if command -v pyenv &>/dev/null && pyenv versions | grep -q $PYTHON_VERSION; then
        print_alert "Python $PYTHON_VERSION is still installed with pyenv"
        all_removed=false
    else
        print_success "Python $PYTHON_VERSION has been removed from pyenv"
    fi
    
    # Check if pyenv is still installed
    if command -v pyenv &>/dev/null; then
        print_alert "pyenv is still installed"
        all_removed=false
    else
        print_success "pyenv has been removed"
    fi
    
    if $all_removed; then
        print_success "All components have been successfully uninstalled"
    else
        print_alert "Some components may still be installed"
        print_info "You may need to manually remove remaining components or restart your terminal"
    fi
}

main() {
    print_header "Coder CLI Uninstallation Script"
    
    if ! get_user_confirmation "This script will uninstall Coder CLI, pipx, Python $PYTHON_VERSION, and pyenv. Continue?"; then
        print_alert "Uninstallation cancelled by user"
        exit 0
    fi
    
    # Detect OS
    detect_os
    print_info "Operating System: $OS_NAME $OS_VERSION"
    
    # Setup environment
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    
    # Initialize pyenv if available
    if command -v pyenv &>/dev/null; then
        eval "$(pyenv init --path)" || true
        eval "$(pyenv init -)" || true
    fi
    
    # Ensure ~/.local/bin is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Uninstall in reverse order of installation
    uninstall_coder
    uninstall_pipx
    uninstall_python
    uninstall_pyenv
    
    # Clean up ~/.local/bin directory
    clean_local_bin
    
    # Final verification
    verify_uninstallation
    
    print_header_info "Uninstallation Complete"
    print_alert "IMPORTANT: You may need to restart your terminal for all changes to take effect"
    
    # Determine shell profile file
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    print_yellow "You may want to run: source $shell_profile"
}

# Execute main function
main