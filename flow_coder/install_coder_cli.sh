#!/bin/bash

# Flow Coder CLI Installation Script
# This script installs Python 3.12.9, pyenv, pipx, and Flow Coder CLI
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

# Array to track installed dependencies
declare -a INSTALLED_DEPENDENCIES=()

# Function to add a dependency to the tracking array
_add_dependency() {
    local dep_name=$1
    local dep_version=$2
    local dep_path=$3
    
    if [[ -n "$dep_version" && -n "$dep_path" ]]; then
        INSTALLED_DEPENDENCIES+=("$dep_name ($dep_version) - $dep_path")
    elif [[ -n "$dep_version" ]]; then
        INSTALLED_DEPENDENCIES+=("$dep_name ($dep_version)")
    elif [[ -n "$dep_path" ]]; then
        INSTALLED_DEPENDENCIES+=("$dep_name - $dep_path")
    else
        INSTALLED_DEPENDENCIES+=("$dep_name")
    fi
}

# Function to display all installed dependencies
_show_installed_dependencies() {
    print_header "Installed Dependencies"
    
    if [ ${#INSTALLED_DEPENDENCIES[@]} -eq 0 ]; then
        print_alert "No dependencies were installed."
        return
    fi
    
    print_info "The following dependencies were installed:"
    echo
    
    for ((i=0; i<${#INSTALLED_DEPENDENCIES[@]}; i++)); do
        echo -e "${GREEN}✅ ${INSTALLED_DEPENDENCIES[$i]}${NC}"
    done
    
    echo
}

###########################################
# PRIVATE FUNCTIONS (Internal use only)
###########################################

# Function to display a progress bar
_show_progress() {
    local duration=$1    # Duration in seconds
    local prefix=$2      # Text to display before the progress bar
    local width=50       # Width of the progress bar
    local interval=0.1   # Update interval in seconds
    local steps=$((duration / interval))
    local progress=0
    
    # Hide cursor
    tput civis
    
    # Start time
    local start_time=$(date +%s)
    local current_time
    local elapsed
    local percent
    
    while [ $progress -lt $steps ]; do
        current_time=$(date +%s)
        elapsed=$((current_time - start_time))
        
        # Calculate percentage
        percent=$((elapsed * 100 / duration))
        if [ $percent -gt 100 ]; then
            percent=100
        fi
        
        # Calculate filled and empty parts of the bar
        local filled=$((width * percent / 100))
        local empty=$((width - filled))
        
        # Build the progress bar
        local bar=""
        for ((i=0; i<filled; i++)); do
            bar="${bar}█"
        done
        for ((i=0; i<empty; i++)); do
            bar="${bar}░"
        done
        
        # Print the progress bar
        printf "\r${BLUE}${prefix}${NC} [${GREEN}%s${NC}] %3d%%" "$bar" "$percent"
        
        # Update progress
        progress=$((elapsed * steps / duration))
        if [ $progress -ge $steps ]; then
            break
        fi
        
        sleep $interval
    done
    
    # Complete the progress bar
    local bar=""
    for ((i=0; i<width; i++)); do
        bar="${bar}█"
    done
    printf "\r${BLUE}${prefix}${NC} [${GREEN}%s${NC}] %3d%%\n" "$bar" "100"
    
    # Show cursor
    tput cnorm
}

# Function to run a command with a progress bar
_run_with_progress() {
    local command=$1
    local message=$2
    local duration=$3
    
    # Run the command in the background and redirect output
    eval "$command" > /tmp/command_output.log 2>&1 &
    local pid=$!
    
    # Show progress bar
    _show_progress "$duration" "$message"
    
    # Wait for the command to finish
    wait $pid
    local exit_code=$?
    
    # Check if the command was successful
    if [ $exit_code -ne 0 ]; then
        print_error "Command failed with exit code $exit_code"
        print_error "Check the log file at /tmp/command_output.log for details"
        return $exit_code
    fi
    
    return 0
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

# Function to install dependencies based on OS
_install_dependencies() {
    local os=$1
    print_info "Installing dependencies for $os..."
    
    if [[ "$os" == "Linux" ]]; then
        # Linux dependencies
        local linux_deps=()
        
        # Update package lists
        sudo apt-get update -y || sudo yum update -y || sudo dnf update -y
        
        # Try to install with apt-get (Debian/Ubuntu)
        if command -v apt-get &> /dev/null; then
            local apt_deps=(
                "curl" "wget" "git" "build-essential" "libssl-dev" "zlib1g-dev"
                "libbz2-dev" "libreadline-dev" "libsqlite3-dev" "llvm" 
                "libncurses5-dev" "libncursesw5-dev" "xz-utils" "tk-dev" 
                "libffi-dev" "liblzma-dev" "python-openssl"
            )
            
            for dep in "${apt_deps[@]}"; do
                if ! dpkg -l | grep -q "$dep"; then
                    sudo apt-get install -y "$dep"
                    _add_dependency "$dep" "" "apt package"
                    linux_deps+=("$dep")
                fi
            done
        # Try to install with yum (CentOS/RHEL)
        elif command -v yum &> /dev/null; then
            local yum_deps=(
                "curl" "wget" "git" "gcc" "zlib-devel" "bzip2" "bzip2-devel" 
                "readline-devel" "sqlite" "sqlite-devel" "openssl-devel" 
                "tk-devel" "libffi-devel" "xz-devel"
            )
            
            for dep in "${yum_deps[@]}"; do
                if ! rpm -q "$dep" &> /dev/null; then
                    sudo yum install -y "$dep"
                    _add_dependency "$dep" "" "yum package"
                    linux_deps+=("$dep")
                fi
            done
        # Try to install with dnf (Fedora)
        elif command -v dnf &> /dev/null; then
            local dnf_deps=(
                "curl" "wget" "git" "gcc" "zlib-devel" "bzip2" "bzip2-devel" 
                "readline-devel" "sqlite" "sqlite-devel" "openssl-devel" 
                "tk-devel" "libffi-devel" "xz-devel"
            )
            
            for dep in "${dnf_deps[@]}"; do
                if ! rpm -q "$dep" &> /dev/null; then
                    sudo dnf install -y "$dep"
                    _add_dependency "$dep" "" "dnf package"
                    linux_deps+=("$dep")
                fi
            done
        fi
        
        if [ ${#linux_deps[@]} -eq 0 ]; then
            print_info "All required Linux dependencies are already installed."
        else
            print_success "Installed Linux dependencies: ${linux_deps[*]}"
        fi
        
    elif [[ "$os" == "macOS" ]]; then
        # macOS dependencies
        local mac_deps=()
        
        if ! _command_exists xcode-select; then
            print_info "Installing command line tools..."
            xcode-select --install || true
            _add_dependency "Xcode Command Line Tools" "" "/Library/Developer/CommandLineTools"
            mac_deps+=("Xcode Command Line Tools")
        fi
        
        # Check if we need to install additional dependencies
        if ! _command_exists make || ! _command_exists gcc; then
            print_alert "Some development tools might be missing. If installation fails, please install Xcode Command Line Tools."
        else
            _add_dependency "make" "$(make --version | head -n 1 | cut -d ' ' -f 3)" "$(which make)"
            _add_dependency "gcc" "$(gcc --version | head -n 1 | awk '{print $NF}')" "$(which gcc)"
            mac_deps+=("make" "gcc")
        fi
        
        if [ ${#mac_deps[@]} -eq 0 ]; then
            print_info "All required macOS dependencies are already installed."
        else
            print_success "Installed macOS dependencies: ${mac_deps[*]}"
        fi
    fi
    
    print_success "Dependencies installation completed."
}

# Function to install Python 3.12.9 from source
_install_python_from_source() {
    local install_dir="$HOME/.local/python3.12.9"
    local python_version="3.12.9"
    
    if [[ -d "$install_dir" ]]; then
        print_alert "Python $python_version already installed at $install_dir"
        _add_dependency "Python" "$python_version" "$install_dir"
        return 0
    fi
    
    print_info "Installing Python $python_version from source..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download Python source
    print_info "Downloading Python $python_version source..."
    wget -q --show-progress "https://www.python.org/ftp/python/$python_version/Python-$python_version.tgz"
    
    # Extract source
    print_info "Extracting Python source..."
    tar -xzf "Python-$python_version.tgz"
    cd "Python-$python_version"
    
    # Configure and install Python
    print_info "Configuring Python $python_version..."
    ./configure --prefix="$install_dir" --enable-optimizations > /tmp/python_configure.log 2>&1
    
    print_info "Building Python $python_version (this may take a while)..."
    # Estimate the number of cores for parallel build
    local cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
    make -j$cores > /tmp/python_build.log 2>&1
    
    print_info "Installing Python $python_version..."
    # Run make install with a progress bar (estimated 60 seconds, adjust as needed)
    _run_with_progress "make install" "Installing Python" 60
    
    # Clean up
    cd "$HOME"
    rm -rf "$temp_dir"
    
    # Add to installed dependencies
    _add_dependency "Python (from source)" "$python_version" "$install_dir"
    
    print_success "Python $python_version installed successfully at $install_dir"
}

# Function to configure pyenv in shell profile
_configure_pyenv_profile() {
    local profile=$1
    
    # Check if pyenv is already in the profile
    if ! grep -q "pyenv init" "$profile"; then
        print_info "Adding pyenv to $profile..."
        cat >> "$profile" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
EOF
    fi
}

# Function to install Python with pyenv
_install_python_with_pyenv() {
    local python_version="3.12.9"
    
    # Check if Python 3.12.9 is already installed with pyenv
    if pyenv versions | grep -q "$python_version"; then
        print_alert "Python $python_version already installed with pyenv"
        _add_dependency "Python (via pyenv)" "$python_version" "$HOME/.pyenv/versions/$python_version"
    else
        # Use the previously installed Python as the build environment
        print_info "Installing Python $python_version with pyenv (this may take a while)..."
        # Run pyenv install with a progress bar (estimated 180 seconds, adjust as needed)
        _run_with_progress "PYTHON_CONFIGURE_OPTS='--enable-shared' pyenv install $python_version" "Building Python with pyenv" 180
        _add_dependency "Python (via pyenv)" "$python_version" "$HOME/.pyenv/versions/$python_version"
        print_success "Python $python_version installed with pyenv successfully."
    fi
    
    # Set Python 3.12.9 as the global version
    pyenv global $python_version
    print_info "Python $python_version set as the global version."
}

###########################################
# PUBLIC FUNCTIONS (Main installation steps)
###########################################

# Function to install dependencies
install_dependencies() {
    if _ask_confirmation "Do you want to install required dependencies?"; then
        # Use the OS_NAME from detect_os.sh
        _install_dependencies "$OS_NAME"
        print_success "Dependencies installation completed."
    else
        print_alert "Skipping dependencies installation. This might cause issues later."
    fi
}

# Function to install Python 3.12.9
install_python() {
    if _ask_confirmation "Do you want to install Python 3.12.9 from source?"; then
        print_header_info "Starting Python 3.12.9 installation..."
        _install_python_from_source
        print_success "Python installation completed."
    else
        print_alert "Skipping Python installation. This might cause issues with pyenv setup."
    fi
}

# Function to install pyenv
install_pyenv() {
    if _ask_confirmation "Do you want to install pyenv?"; then
        print_header_info "Starting pyenv installation..."
        
        if [[ -d "$HOME/.pyenv" ]]; then
            print_alert "pyenv already installed at $HOME/.pyenv"
            # Get pyenv version
            local pyenv_version=$(pyenv --version 2>/dev/null | cut -d ' ' -f 2 || echo "unknown")
            _add_dependency "pyenv" "$pyenv_version" "$HOME/.pyenv"
        else
            print_info "Installing pyenv..."
            curl https://pyenv.run | bash
            
            # Get pyenv version after installation
            local pyenv_version=$(PYENV_ROOT="$HOME/.pyenv" PATH="$HOME/.pyenv/bin:$PATH" pyenv --version 2>/dev/null | cut -d ' ' -f 2 || echo "unknown")
            _add_dependency "pyenv" "$pyenv_version" "$HOME/.pyenv"
            
            print_success "pyenv installed successfully."
        fi
        
        # Set up pyenv in shell profile
        local profile=$(_detect_shell_profile)
        
        if _ask_confirmation "Do you want to configure pyenv in your shell profile ($profile)?"; then
            _configure_pyenv_profile "$profile"
            _add_dependency "pyenv configuration" "" "$profile"
        else
            print_alert "Skipping pyenv configuration in shell profile. You'll need to configure it manually."
        fi
        
        # Source the profile to make pyenv available in the current session
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
        
        # Install Python 3.12.9 with pyenv
        if _ask_confirmation "Do you want to install Python 3.12.9 with pyenv?"; then
            _install_python_with_pyenv
        else
            print_alert "Skipping Python 3.12.9 installation with pyenv. This might cause issues later."
        fi
        
        print_success "pyenv setup completed."
    else
        print_alert "Skipping pyenv installation. This might cause issues with pipx setup."
    fi
}

# Function to install pipx
install_pipx() {
    if _ask_confirmation "Do you want to install pipx?"; then
        print_header_info "Starting pipx installation..."
        
        # Check if pipx is already installed
        if _command_exists pipx; then
            print_alert "pipx already installed"
            local pipx_version=$(pipx --version 2>/dev/null || echo "unknown")
            _add_dependency "pipx" "$pipx_version" "$(which pipx)"
        else
            # Install pipx using the pyenv Python
            print_info "Installing pipx..."
            _run_with_progress "python -m pip install --user pipx" "Installing pipx" 10
            
            # Get pipx version after installation
            local pipx_version=$(python -m pipx --version 2>/dev/null || echo "unknown")
            _add_dependency "pipx" "$pipx_version" "$HOME/.local/bin/pipx"
            
            print_success "pipx installed successfully."
        fi
        
        # Ensure pipx is in PATH
        if _ask_confirmation "Do you want to add pipx to your PATH?"; then
            python -m pipx ensurepath
            
            # Add pipx to PATH for the current session
            export PATH="$HOME/.local/bin:$PATH"
            print_success "pipx added to PATH."
        else
            print_alert "Skipping pipx PATH configuration. You'll need to add it manually."
        fi
        
        print_success "pipx setup completed."
    else
        print_alert "Skipping pipx installation. This will prevent Flow Coder CLI installation."
    fi
}

# Function to install Flow Coder CLI
install_flow_coder_cli() {
    if _ask_confirmation "Do you want to install Flow Coder CLI?"; then
        print_header_info "Starting Flow Coder CLI installation..."
        
        # Install Flow Coder CLI using pipx
        print_info "Installing Flow Coder CLI..."
        _run_with_progress "pipx install https://storage.googleapis.com/flow-coder/flow_coder-1.4.0-py3-none-any.whl" "Installing Flow Coder CLI" 15
        
        # Get Flow Coder CLI version after installation
        if _command_exists flow-coder; then
            local flow_coder_version=$(flow-coder --version 2>/dev/null | cut -d ' ' -f 2 || echo "1.4.0")
            _add_dependency "Flow Coder CLI" "$flow_coder_version" "$HOME/.local/bin/flow-coder"
        else
            _add_dependency "Flow Coder CLI" "1.4.0" "$HOME/.local/bin/flow-coder"
        fi
        
        print_success "Flow Coder CLI installed successfully."
    else
        print_alert "Skipping Flow Coder CLI installation."
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

# Main installation process
run_installation() {
    print_header "Starting Flow Coder CLI installation process..."
    print
    
    # Detect OS using the imported detect_os function
    detect_os
    
    # Detect shell profile
    local profile=$(_detect_shell_profile)
    print_info "Using shell profile: $profile"
    
    # Install dependencies
    install_dependencies
    
    # Install Python 3.12.9 from source
    install_python
    
    # Install pyenv
    install_pyenv
    
    # Install pipx
    install_pipx
    
    # Install Flow Coder CLI
    install_flow_coder_cli
    
    # Reload shell profile
    reload_shell_profile
    
    # Show installed dependencies
    _show_installed_dependencies
    
    # Final instructions
    print_header "Installation process completed!"
    print_info "To start using Flow Coder CLI, please restart your terminal or run:"
    print "source $profile"
    
    print_success "Flow Coder CLI is now installed and ready to use!"
}


run_installation

