#!/usr/bin/env bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/utils/profile_writer.sh"

# Python version to use
PYTHON_VERSION="3.12.0"

# Common development tools to install
COMMON_TOOLS=(
  "black"       # Code formatter
  "flake8"      # Linter
  "mypy"        # Type checker
  "pytest"      # Testing framework
  "isort"       # Import sorter
  "pre-commit"  # Git hooks manager
  "poetry"      # Dependency management
)

_check_pyenv() {
    print_info "Checking pyenv installation"
    
    # Check if pyenv command exists
    if ! command -v pyenv &>/dev/null; then
        print_alert "pyenv is not installed"
        return 1
    fi
    
    # Check pyenv version
    local pyenv_version=$(pyenv --version 2>&1)
    print_success "pyenv version: $pyenv_version"
    
    # Check if pyenv is in PATH
    if ! echo "$PATH" | grep -q "pyenv"; then
        print_alert "pyenv is not in PATH"
        return 1
    fi
    
    print_success "pyenv is installed and configured correctly"
    return 0
}

_check_python() {
    print_info "Checking Python installation"
    
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
    
    print_success "Python $PYTHON_VERSION is installed with pyenv"
    
    # Check current global version
    local current_version=$(pyenv global)
    print_success "Current global Python version: $current_version"
    
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
    print_info "Activing Python version: $active_version ..."
    
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

_check_pipx() {
    print_info "Checking pipx installation"
    
    # Check if pipx command exists
    if ! command -v pipx &>/dev/null; then
        print_alert "pipx is not installed"
        return 1
    fi
    
    # Check pipx version
    local pipx_version=$(pipx --version 2>&1)
    print_success "pipx version: $pipx_version"
    
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
    
    print_success "pipx is using: $pipx_python_info"
    
    # Check if pipx is using the correct Python version
    if [[ "$pipx_python_info" != *"Python ${PYTHON_VERSION%.*}"* ]]; then
        print_alert "pipx is not using Python $PYTHON_VERSION"
        return 1
    fi
    
    print_success "pipx is installed and using Python $PYTHON_VERSION"
    return 0
}

_check_dev_tools() {
    print_info "Checking development tools"
    
    local all_installed=true
    
    for tool in "${COMMON_TOOLS[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            print_alert "$tool is not installed or not in PATH"
            all_installed=false
        else
            local version
            version=$("$tool" --version 2>&1 | head -n 1)
            print_success "$tool: $version"
        fi
    done
    
    if $all_installed; then
        print_success "All development tools are installed"
        return 0
    else
        print_alert "Some development tools are missing"
        return 1
    fi
}

_install_pyenv() {
    print_header_info "Installing pyenv"
    
    if ! get_user_confirmation "Do you want to install pyenv?"; then
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
    
    # Remover entradas anteriores do pyenv se existirem
    remove_script_entries_from_profile "setup_python" "$HOME/.zshrc"
    
    # Adicionar configuração do pyenv com quebras de linha explícitas
    write_lines_to_profile \
        "# pyenv configuration" \
        "export PYENV_ROOT=\"\$HOME/.pyenv\"" \
        "export PATH=\"\$PYENV_ROOT/bin:\$PATH\"" \
        "eval \"\$(pyenv init --path)\"" \
        "eval \"\$(pyenv init -)\""
    
    # Also add to current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    
    print_success "pyenv installed successfully"
    print_alert "You may need to restart your terminal or source your shell profile to use pyenv"
    
    # Verify installation
    if _check_pyenv; then
        return 0
    else
        print_error "Failed to install pyenv correctly"
        exit 1
    fi
}

_install_python() {
    print_header_info "Installing Python $PYTHON_VERSION with pyenv"
    
    if ! get_user_confirmation "Do you want to install Python $PYTHON_VERSION?"; then
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
    if _check_python; then
        return 0
    else
        print_error "Failed to install Python correctly"
        exit 1
    fi
}

_clean_pipx() {
    print_info "Cleaning up existing pipx installation..."
    
    if ! get_user_confirmation "Do you want to clean up the existing pipx installation?"; then
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
    
    # Remove pipx from PATH in shell profile using profile_writer
    remove_script_entries_from_profile "pipx configuration"
    
    # Remove pipx executable
    rm -f "$HOME/.local/bin/pipx" || true
    
    print_success "Cleaned up pipx installation"
    return 0
}

_install_pipx() {
    print_header_info "Installing pipx with Python $PYTHON_VERSION"
    
    if ! get_user_confirmation "Do you want to install pipx?"; then
        print_alert "pipx installation skipped by user"
        exit 1
    fi
    
    # Clean up any existing pipx installation
    _clean_pipx
    
    # Make sure we're using the pyenv Python
    pyenv shell $PYTHON_VERSION
    pyenv rehash
    
    # Get the full path to the Python executable
    local python_path=$(pyenv which python)
    print_info "Using Python from: $python_path"
    
    # Install pipx using the pyenv Python
    "$python_path" -m pip install --user pipx
    
    # Remover entradas anteriores do pipx se existirem
    remove_script_entries_from_profile "pipx configuration" "$HOME/.zshrc"
    
    # Adicionar configuração do pipx usando write_lines_to_profile para garantir que cada linha seja adicionada corretamente
    write_lines_to_profile \
        "# pipx configuration" \
        "export PATH=\"\$HOME/.local/bin:\$PATH\"" \
        "export PIPX_DEFAULT_PYTHON=\"$python_path\""
    
    # Add pipx to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    export PIPX_DEFAULT_PYTHON="$python_path"
    
    # Force ensurepath to add pipx to PATH
    "$python_path" -m pipx ensurepath --force
    
    print_success "pipx installed successfully with Python $PYTHON_VERSION"
    
    # Verify installation
    if _check_pipx; then
        return 0
    else
        print_error "Failed to install pipx correctly"
        exit 1
    fi
}

_install_dev_tools() {
    print_info "Installing Python development tools"
    
    # TODO - ajuste para que não faça a instalação de tools se já estiver instalado
    if ! get_user_confirmation "Do you want to install common Python development tools?"; then
        print_alert "Development tools installation skipped by user"
        return 0
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
    
    # Install each tool with pipx
    for tool in "${COMMON_TOOLS[@]}"; do
        print_info "Installing $tool..."
        pipx install "$tool" --force
    done
    
    print_success "All development tools installed successfully"
    
    # Verify installation
    if _check_dev_tools; then
        return 0
    else
        print_alert "Some development tools may not have been installed correctly"
        return 1
    fi
}

_create_venv_helper() {
    print_info "Creating venv helper script"
    
    if ! get_user_confirmation "Do you want to create a venv helper script?"; then
        print_alert "venv helper script creation skipped by user"
        return 0
    fi
    
    local venv_script="$HOME/.local/bin/mkvenv"
    
    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$venv_script")"
    
    # Create the script
    cat > "$venv_script" << 'EOF'
#!/usr/bin/env bash

# mkvenv - Create and activate a Python virtual environment
# Usage: mkvenv [venv_name]

set -e

VENV_NAME="${1:-venv}"

# Check if pyenv is available
if command -v pyenv &>/dev/null; then
    # Get the current Python version from pyenv
    PYTHON_VERSION=$(pyenv version-name)
    echo "Using Python $PYTHON_VERSION from pyenv"
    
    # Create the virtual environment
    python -m venv "$VENV_NAME"
else
    # Use system Python
    echo "pyenv not found, using system Python"
    python3 -m venv "$VENV_NAME"
fi

# Activate the virtual environment
source "$VENV_NAME/bin/activate"

# Upgrade pip
pip install --upgrade pip setuptools wheel

echo "Virtual environment '$VENV_NAME' created and activated"
echo "To activate this environment in the future, run:"
echo "source $VENV_NAME/bin/activate"
EOF
    
    # Make the script executable
    chmod +x "$venv_script"
    
    print_success "venv helper script created at $venv_script"
    print_info "You can now create a virtual environment with: mkvenv [venv_name]"
    
    return 0
}

_verify_installation() {
    print_info "Verifying Installation"
    
    # Check all components
    local all_ok=true
    
    if ! _check_pyenv; then
        all_ok=false
    fi
    
    if ! _check_python; then
        all_ok=false
    fi
    
    if ! _check_pipx; then
        all_ok=false
    fi
    
    if ! _check_dev_tools; then
        all_ok=false
    fi
    
    if $all_ok; then
        print_success "All components are installed and configured correctly"
    else
        print_error "Some components are not installed or configured correctly"
    fi
}

_configure_python_environment() {
    # Get the full path to the Python executable
    local python_path=$(pyenv which python)
    
    # Remover entradas anteriores da configuração do ambiente Python se existirem
    remove_script_entries_from_profile "Python environment configuration" "$HOME/.zshrc"
    
    # Adicionar configuração do ambiente Python usando write_lines_to_profile para garantir que cada linha seja adicionada corretamente
    write_lines_to_profile \
        "# Python environment configuration" \
        "export PATH=\"\$HOME/.local/bin:\$PATH\"" \
        "export PYENV_ROOT=\"\$HOME/.pyenv\"" \
        "export PATH=\"\$PYENV_ROOT/bin:\$PATH\"" \
        "eval \"\$(pyenv init --path)\"" \
        "eval \"\$(pyenv init -)\"" \
        "export PIPX_DEFAULT_PYTHON=\"$python_path\""
    
    print_success "Python environment configured in shell profile"
    print_alert "IMPORTANTE: Você precisa reiniciar seu terminal ou executar 'source $(detect_profile)' para usar o novo ambiente."
}

setup_python() {
  print_header_info "Check Setup Python"

  if ! get_user_confirmation "Do you want Check Setup Python ?"; then
      print_info "Skipping configuration"
      return 0
  fi
    
    # Detect OS
    detect_os
    
    # Setup environment
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    
    # Check and install pyenv if needed
    if ! _check_pyenv; then
        print_alert "pyenv needs to be installed"
        _install_pyenv
    fi
    
    # Initialize pyenv
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    
    # Check and install Python if needed
    if ! _check_python; then
        print_alert "Python $PYTHON_VERSION needs to be installed or set as global"
        _install_python
    fi
    
    # Get the full path to the Python executable
    local python_path=$(pyenv which python)
    
    # Set PIPX_DEFAULT_PYTHON
    export PIPX_DEFAULT_PYTHON="$python_path"
    
    # Ensure ~/.local/bin is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Check and install pipx if needed
    if ! _check_pipx; then
        print_alert "pipx needs to be installed or reconfigured"
        _install_pipx
    fi
    
    # Install development tools
    _install_dev_tools
    
    # Create venv helper script
    _create_venv_helper
    
    # Configure Python environment in shell profile
    _configure_python_environment
    
    # Final verification
    _verify_installation
    
    print_info "You now have a complete Python $PYTHON_VERSION development environment"
    
    print_success "Installation Complete"
}

# Check if the script is being executed directly or imported
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # If executed directly, load environment and execute main function
    load_env
    setup_python "$@"
fi