#!/usr/bin/env bash

# uninstall_coder_cli.sh
# Script to uninstall Coder CLI, pipx, Python and pyenv

set -e

# Python version that was installed
PYTHON_VERSION="3.12.9"

# Color definitions
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;37m'
NC='\033[0m' # No Color

# Function to display information messages
function print_info() {
  echo -e "\n${BLUE}ℹ️  $1${NC}"
}

# Function to display success messages
function print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

# Function to display alert messages
function print_alert() {
  echo -e "\n${YELLOW}⚠️  $1${NC}"
}

# Function to display error messages
function print_error() {
  echo -e "${RED}❌ Error: $1${NC}"
}

# Function to display formatted messages
function print_header() {
  echo -e "\n${YELLOW}===========================================================================${NC}"
  echo -e "${GREEN}$1${NC}"
  echo -e "${YELLOW}===========================================================================${NC}"
}

function print_header_info() {
  echo -e "\n${BLUE}=======================================================${NC}"
  echo -e "${YELLOW}$1${NC}"
  echo -e "${BLUE}=======================================================${NC}"
}

# Function to display alert messages
function print_yellow() {
  echo -e "${YELLOW}$1${NC}"
}

# Function to detect the operating system and version
function detect_os() {
    local os_name=""
    local os_version=""
    local os_codename=""
    
    # Detect OS type
    case "$(uname -s)" in
        Darwin)
            os_name="macOS"
            os_version=$(sw_vers -productVersion)
            
            # Get macOS codename based on version
            case "${os_version%%.*}" in
                10)
                    case "${os_version#*.}" in
                        15*) os_codename="Catalina" ;;
                        14*) os_codename="Mojave" ;;
                        13*) os_codename="High Sierra" ;;
                        12*) os_codename="Sierra" ;;
                        11*) os_codename="El Capitan" ;;
                        10*) os_codename="Yosemite" ;;
                        9*) os_codename="Mavericks" ;;
                        *) os_codename="Unknown" ;;
                    esac
                    ;;
                11) os_codename="Big Sur" ;;
                12) os_codename="Monterey" ;;
                13) os_codename="Ventura" ;;
                14) os_codename="Sonoma" ;;
                15) os_codename="Sequoia" ;;
                *) os_codename="Unknown" ;;
            esac
            ;;
            
        Linux)
            os_name="Linux"
            
            # Check for common Linux distribution information files
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                os_version="$VERSION_ID"
                os_codename="$PRETTY_NAME"
                os_name="$ID"
                
                # Capitalize first letter of distribution name
                os_name="$(tr '[:lower:]' '[:upper:]' <<< ${os_name:0:1})${os_name:1}"
            elif [ -f /etc/lsb-release ]; then
                . /etc/lsb-release
                os_version="$DISTRIB_RELEASE"
                os_codename="$DISTRIB_CODENAME"
                os_name="$DISTRIB_ID"
            elif [ -f /etc/debian_version ]; then
                os_name="Debian"
                os_version=$(cat /etc/debian_version)
            elif [ -f /etc/redhat-release ]; then
                os_name=$(cat /etc/redhat-release | cut -d ' ' -f 1)
                os_version=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+')
            fi
            ;;
            
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            os_name="Windows"
            if [ -n "$(command -v cmd.exe)" ]; then
                # Get Windows version using systeminfo
                os_version=$(cmd.exe /c ver 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
                
                # Try to get Windows edition
                if [ -n "$(command -v wmic)" ]; then
                    os_codename=$(wmic os get Caption /value 2>/dev/null | grep -o "Windows.*" | sed 's/Windows //')
                fi
            fi
            ;;
            
        *)
            print_error "Sistema operacional não suportado"
            return 1
            ;;
    esac
    
    # Export variables
    export OS_NAME="$os_name"
    export OS_VERSION="$os_version"
    export OS_CODENAME="$os_codename"
    
    # Print OS information
    print_success "Sistema Operacional Detectado: $os_name $os_version $os_codename"
}

# Ask user for confirmation
function confirm_action() {
  local prompt="$1"
  local choice
  
  read -p "$prompt (y/n): " choice
  case "$choice" in
    [Yy]* ) return 0 ;;
    * ) return 1 ;;
  esac
}

uninstall_coder() {
    print_header_info "Uninstalling Coder CLI"
    
    if ! confirm_action "Do you want to uninstall Coder CLI?"; then
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
    
    if ! confirm_action "Do you want to uninstall pipx?"; then
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
    
    if ! confirm_action "Do you want to uninstall Python $PYTHON_VERSION?"; then
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
    
    if ! confirm_action "Do you want to uninstall pyenv?"; then
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
    
    if ! confirm_action "Do you want to clean up the ~/.local/bin directory?"; then
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
    if confirm_action "Do you want to remove all files in ~/.local/bin?"; then
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

uninstall_flow_coder_cli() {
    print_header "Coder CLI Uninstallation Script"
    
    if ! confirm_action "This script will uninstall Coder CLI, pipx, Python $PYTHON_VERSION, and pyenv. Continue?"; then
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

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    uninstall_flow_coder_cli "$@"
fi