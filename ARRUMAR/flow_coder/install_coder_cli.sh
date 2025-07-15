#!/usr/bin/env bash

# install_coder_cli.sh
# Script to install and configure Coder CLI with pyenv and pipx

set -e

# Import utility scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/colors_message.sh"
source "$SCRIPT_DIR/utils/detect_os.sh"
source "$SCRIPT_DIR/utils/bash_tools.sh"

# Python version to use
PYTHON_VERSION="3.12.9"

check_pyenv() {
    print_header_info "Checking pyenv installation"
    
    # Check if pyenv command exists
    if ! command -v pyenv &>/dev/null; then
        print_alert "pyenv is not installed"
        return 1
    fi
    
    # Check pyenv version
    local pyenv_version=$(pyenv --version 2>&1)
    print_info "pyenv version: $pyenv_version"
    
    # Check if pyenv is in PATH
    if ! echo "$PATH" | grep -q "pyenv"; then
        print_alert "pyenv is not in PATH"
        return 1
    fi
    
    print_success "pyenv is installed and configured correctly"
    return 0
}

check_python() {
    print_header_info "Checking Python installation"
    
    # Check if pyenv is available
    if ! command -v pyenv &>/dev/null; then
        print_alert "pyenv is not available, cannot check Python versions"
        return 1
    fi
    
    # Check if our required version is installed
    if ! pyenv versions | grep -q $PYTHON_VERSION; then
        print_alert "Python $PYTHON_VERSION is not installed"
        return 1
    fi
    
    print_info "Python $PYTHON_VERSION is installed with pyenv"
    
    # Check current global version
    local current_version=$(pyenv global)
    print_info "Current global Python version: $current_version"
    
    # Check if current version matches required version
    if [[ "$current_version" != "$PYTHON_VERSION" ]]; then
        print_alert "Python $PYTHON_VERSION is installed but not set as global version"
        print_alert "Current global version is: $current_version"
        return 1
    fi
    
    # Ensure pyenv shims are in PATH
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    
    # Verify that the active Python version is the one we expect
    # Use pyenv which python to get the correct path
    local python_path=$(pyenv which python)
    local active_version=$("$python_path" --version 2>&1 | cut -d' ' -f2)
    print_info "Active Python version: $active_version"
    
    # Extract major.minor.patch from active version
    local active_major_minor_patch=$(echo $active_version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    
    if [[ "$active_major_minor_patch" != "$PYTHON_VERSION" ]]; then
        print_alert "Active Python version ($active_version) does not match required version ($PYTHON_VERSION)"
        print_alert "This may indicate an issue with pyenv configuration"
        return 1
    fi
    
    # Check if Python is working correctly
    if ! "$python_path" -c "print('Python is working')" &>/dev/null; then
        print_alert "Python is not working correctly"
        return 1
    fi
    
    print_success "Python $PYTHON_VERSION is installed and set as global"
    return 0
}

check_pipx() {
    print_header_info "Checking pipx installation"
    
    # Check if pipx command exists
    if ! command -v pipx &>/dev/null; then
        print_alert "pipx is not installed"
        return 1
    fi
    
    # Check pipx version
    local pipx_version=$(pipx --version 2>&1)
    print_info "pipx version: $pipx_version"
    
    # Get the full path to the Python executable
    local python_path=$(pyenv which python)
    
    # Check if PIPX_DEFAULT_PYTHON is set correctly
    if [[ -z "$PIPX_DEFAULT_PYTHON" ]]; then
        print_alert "PIPX_DEFAULT_PYTHON is not set"
        return 1
    elif [[ "$PIPX_DEFAULT_PYTHON" != "$python_path" ]]; then
        print_alert "PIPX_DEFAULT_PYTHON is not set to the correct Python path"
        print_info "Current: $PIPX_DEFAULT_PYTHON"
        print_info "Expected: $python_path"
        return 1
    fi
    
    # Check which Python pipx is using
    # Create a temporary script to print Python version and path
    local temp_script=$(mktemp)
    echo "import sys; print(f'Python {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro} at {sys.executable}')" > "$temp_script"
    
    # Run the script with pipx
    local pipx_python_info=$(pipx run --spec=pydantic python "$temp_script" 2>/dev/null || echo "Failed to run pipx")
    rm -f "$temp_script"
    
    print_info "pipx is using: $pipx_python_info"
    
    # Check if pipx is using Python 3.12.9
    if [[ "$pipx_python_info" != *"Python 3.12.9"* ]]; then
        print_alert "pipx is not using Python $PYTHON_VERSION"
        return 1
    fi
    
    print_success "pipx is installed and using Python $PYTHON_VERSION"
    return 0
}

check_coder() {
    print_header_info "Checking Coder CLI installation"
    
    # Get the path to coder executable
    local coder_path="$HOME/.local/bin/coder"
    
    # Check if coder command exists
    if [[ ! -f "$coder_path" ]]; then
        print_alert "Coder CLI is not installed at expected location: $coder_path"
        return 1
    fi
    
    # Check if coder is executable
    if [[ ! -x "$coder_path" ]]; then
        print_alert "Coder CLI exists but is not executable"
        return 1
    fi
    
    # Check coder version using full path
    if ! "$coder_path" --version &>/dev/null; then
        print_alert "Coder CLI is not working correctly"
        return 1
    fi
    
    local coder_version=$("$coder_path" --version 2>&1)
    print_info "Coder CLI version: $coder_version"
    print_info "Coder CLI path: $coder_path"
    
    print_success "Coder CLI is installed and working correctly"
    return 0
}

install_pyenv() {
    print_header_info "Installing pyenv"
    
    if ! confirm_action "Do you want to install pyenv?"; then
        print_alert "pyenv installation skipped by user"
        exit 1
    fi
    
    detect_os
    
    if [[ "$OS_NAME" == "Linux" ]]; then
        print_info "Installing pyenv dependencies for Linux..."
        sudo apt-get update
        sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
        
        curl https://pyenv.run | bash
    elif [[ "$OS_NAME" == "macOS" ]]; then
        print_info "Installing pyenv for macOS..."
        brew update
        brew install pyenv
    else
        print_error "Unsupported operating system: $OS_NAME"
        exit 1
    fi
    
    # Determine shell profile file
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    # Add pyenv to shell configuration if not already there
    if ! grep -q "pyenv init" "$shell_profile"; then
        print_info "Adding pyenv to $shell_profile"
        echo '' >> "$shell_profile"
        echo '# pyenv configuration' >> "$shell_profile"
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$shell_profile"
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$shell_profile"
        echo 'eval "$(pyenv init --path)"' >> "$shell_profile"
        echo 'eval "$(pyenv init -)"' >> "$shell_profile"
    fi
    
    # Also add to current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    
    print_success "pyenv installed successfully"
    print_alert "You may need to restart your terminal or run 'source $shell_profile' to use pyenv"
    
    # Verify installation
    if check_pyenv; then
        return 0
    else
        print_error "Failed to install pyenv correctly"
        exit 1
    fi
}

install_python() {
    print_header_info "Installing Python $PYTHON_VERSION with pyenv"
    
    if ! confirm_action "Do you want to install Python $PYTHON_VERSION?"; then
        print_alert "Python installation skipped by user"
        exit 1
    fi
    
    # Check if this version is already installed
    if pyenv versions | grep -q $PYTHON_VERSION; then
        print_info "Python $PYTHON_VERSION is already installed with pyenv"
    else
        print_info "Installing Python $PYTHON_VERSION with pyenv..."
        pyenv install $PYTHON_VERSION
    fi
    
    # Set as global Python version
    print_info "Setting Python $PYTHON_VERSION as global version..."
    pyenv global $PYTHON_VERSION
    
    # Rehash to update shims
    pyenv rehash
    
    # Verify the installation
    local current_version=$(pyenv global)
    if [[ "$current_version" == "$PYTHON_VERSION" ]]; then
        print_success "Python $PYTHON_VERSION is now the global version"
    else
        print_error "Failed to set Python $PYTHON_VERSION as global version. Current version is $current_version"
        exit 1
    fi
    
    # Verify installation
    if check_python; then
        return 0
    else
        print_error "Failed to install Python correctly"
        exit 1
    fi
}

clean_pipx() {
    print_info "Cleaning up existing pipx installation..."
    
    if ! confirm_action "Do you want to clean up the existing pipx installation?"; then
        print_alert "pipx cleanup skipped by user"
        return 1
    fi
    
    # Get Python path
    local python_path=$(pyenv which python)
    
    # Uninstall pipx if it exists
    if command -v pipx &>/dev/null; then
        "$python_path" -m pip uninstall -y pipx || true
    fi
    
    # Remove pipx directories
    rm -rf "$HOME/.local/pipx" || true
    
    # Remove pipx from PATH in shell profile
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    # Remove any pipx-related lines from shell profile
    if [[ -f "$shell_profile" ]]; then
        sed -i.bak '/pipx/d' "$shell_profile" || true
        rm -f "${shell_profile}.bak" || true
    fi
    
    # Remove pipx executable
    rm -f "$HOME/.local/bin/pipx" || true
    
    print_success "Cleaned up pipx installation"
    return 0
}

install_pipx() {
    print_header_info "Installing pipx with Python $PYTHON_VERSION"
    
    if ! confirm_action "Do you want to install pipx?"; then
        print_alert "pipx installation skipped by user"
        exit 1
    fi
    
    # Clean up any existing pipx installation
    clean_pipx
    
    # Make sure we're using the pyenv Python
    pyenv shell $PYTHON_VERSION
    pyenv rehash
    
    # Get the full path to the Python executable
    local python_path=$(pyenv which python)
    print_info "Using Python from: $python_path"
    
    # Install pipx using the pyenv Python
    "$python_path" -m pip install --user pipx
    
    # Determine shell profile file
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    # Add pipx to PATH in shell profile
    print_info "Adding pipx to $shell_profile"
    echo '' >> "$shell_profile"
    echo '# pipx configuration' >> "$shell_profile"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_profile"
    echo "export PIPX_DEFAULT_PYTHON=\"$python_path\"" >> "$shell_profile"
    
    # Add pipx to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    export PIPX_DEFAULT_PYTHON="$python_path"
    
    # Force ensurepath to add pipx to PATH
    "$python_path" -m pipx ensurepath --force
    
    print_success "pipx installed successfully with Python $PYTHON_VERSION"
    
    # Verify installation
    if check_pipx; then
        return 0
    else
        print_error "Failed to install pipx correctly"
        exit 1
    fi
}

install_coder() {
    print_header_info "Installing Coder CLI"
    
    if ! confirm_action "Do you want to install Coder CLI?"; then
        print_alert "Coder CLI installation skipped by user"
        exit 1
    fi
    
    # Make sure we're using the pyenv Python
    pyenv shell $PYTHON_VERSION
    pyenv rehash
    
    # Get the full path to the Python executable
    local python_path=$(pyenv which python)
    
    # Set PIPX_DEFAULT_PYTHON
    export PIPX_DEFAULT_PYTHON="$python_path"
    
    # Ensure ~/.local/bin is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Install Coder CLI using pipx with force
    print_info "Installing Coder CLI using pipx with Python $PYTHON_VERSION..."
    "$python_path" -m pipx install https://storage.googleapis.com/flow-coder/flow_coder-1.4.0-py3-none-any.whl --force
    
    # Verify coder executable exists
    local coder_path="$HOME/.local/bin/coder"
    if [[ ! -f "$coder_path" ]]; then
        # Try to find the coder executable
        local found_coder_path=$(find "$HOME/.local" -name "coder" -type f -executable 2>/dev/null | head -n 1)
        if [[ -n "$found_coder_path" ]]; then
            print_info "Creating symlink for Coder CLI at $HOME/.local/bin/coder"
            mkdir -p "$HOME/.local/bin"
            ln -sf "$found_coder_path" "$coder_path"
        else
            print_error "Could not find Coder CLI executable"
            exit 1
        fi
    fi
    
    # Make sure coder is executable
    chmod +x "$coder_path"
    
    print_success "Coder CLI installed successfully"
    
    # Verify installation
    if check_coder; then
        return 0
    else
        print_error "Failed to install Coder CLI correctly"
        exit 1
    fi
}

# Configure Coder CLI
configure_coder() {
    print_header_info "Configuring Coder CLI"
    
    # Ask for confirmation
    if ! confirm_action "Do you want to configure Coder CLI?"; then
        print_alert "Coder CLI configuration skipped by user"
        return 0
    fi
    
    # Ensure coder is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Get the full path to coder
    local coder_path="$HOME/.local/bin/coder"
    
    # Check if coder is available
    if [[ ! -f "$coder_path" ]] || [[ ! -x "$coder_path" ]]; then
        print_error "Coder CLI not found or not executable at $coder_path"
        print_info "You can manually run: export PATH=\"\$HOME/.local/bin:\$PATH\""
        return 1
    fi
    
    # Check if already authenticated
    if "$coder_path" --version &>/dev/null; then
        print_info "Coder CLI version:"
        "$coder_path" --version
        
        # Try to initialize
        if "$coder_path" init; then
            print_success "Coder CLI initialized successfully"
            return 0
        fi
    fi
    
    # If we get here, we need to authenticate
    print_alert "Coder CLI authentication required"
    
    # Ask for confirmation before authentication
    if ! confirm_action "Do you want to authenticate Coder CLI?"; then
        print_alert "Coder CLI authentication skipped by user"
        return 0
    fi
    
    read -p "Enter Coder tenant URL: " TENANT
    read -p "Enter client ID: " CLIENT_ID
    read -p "Enter client secret: " CLIENT_SECRET
    
    "$coder_path" auth add --tenant "$TENANT" --client "$CLIENT_ID" --secret "$CLIENT_SECRET"
    
    if [ $? -eq 0 ]; then
        print_success "Coder CLI authenticated successfully"
    else
        print_error "Failed to authenticate Coder CLI"
        exit 1
    fi
}

verify_installation() {
    print_header_info "Verifying Installation"
    
    # Check all components
    local all_ok=true
    
    if ! check_pyenv; then
        all_ok=false
    fi
    
    if ! check_python; then
        all_ok=false
    fi
    
    if ! check_pipx; then
        all_ok=false
    fi
    
    if ! check_coder; then
        all_ok=false
    fi
    
    if $all_ok; then
        print_success "All components are installed and configured correctly"
    else
        print_error "Some components are not installed or configured correctly"
    fi
}

main() {
    print_header "Coder CLI Installation Script"
    
    if ! confirm_action "This script will install and configure pyenv, Python $PYTHON_VERSION, pipx, and Coder CLI. Continue?"; then
        print_alert "Installation cancelled by user"
        exit 0
    fi
    
    # Detect OS
    detect_os
    print_info "Operating System: $OS_NAME $OS_VERSION"
    
    # Setup environment
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    
    # Check and install pyenv if needed
    if ! check_pyenv; then
        print_alert "pyenv needs to be installed"
        install_pyenv
    fi
    
    # Initialize pyenv
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    
    # Check and install Python if needed
    if ! check_python; then
        print_alert "Python $PYTHON_VERSION needs to be installed or set as global"
        install_python
    fi
    
    # Get the full path to the Python executable
    local python_path=$(pyenv which python)
    
    # Set PIPX_DEFAULT_PYTHON
    export PIPX_DEFAULT_PYTHON="$python_path"
    
    # Ensure ~/.local/bin is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Check and install pipx if needed
    if ! check_pipx; then
        print_alert "pipx needs to be installed or reconfigured"
        install_pipx
    fi
    
    # Check and install Coder CLI if needed
    if ! check_coder; then
        print_alert "Coder CLI needs to be installed"
        install_coder
    fi
    
    # Configure Coder CLI
    configure_coder
    
    # Final verification
    verify_installation
    
    print_header_info "Installation Complete"
    print_info "You can now use Coder CLI with Python $PYTHON_VERSION"
    print_info "Run 'coder --help' for available commands"
    
    # Determine shell profile file
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    print_alert "IMPORTANT: You may need to restart your terminal or run the following command to use coder:"
    print_yellow "source $shell_profile"
    print_yellow "# OR"
    print_yellow "export PATH=\"\$HOME/.local/bin:\$PATH\""
    print_yellow "export PYENV_ROOT=\"\$HOME/.pyenv\""
    print_yellow "export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    print_yellow "eval \"\$(pyenv init --path)\""
    print_yellow "eval \"\$(pyenv init -)\""
    print_yellow "export PIPX_DEFAULT_PYTHON=\"$python_path\""
}

# Execute main function
main