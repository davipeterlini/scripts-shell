#!/bin/bash

set -e

# Define colors for output
RED_BOLD='\033[1;31m'
GREEN_BOLD='\033[1;32m'
YELLOW_BOLD='\033[1;33m'
BLUE_BOLD='\033[1;34m'
NC='\033[0m' # No Color

PYENV_DIR="$HOME/.pyenv"
PYTHON_VERSION_TO_CHECK="3.12.9"

# Utility function for logging
log_info() {
    echo -e "${BLUE_BOLD}$1${NC}"
}

log_success() {
    echo -e "${GREEN_BOLD}$1${NC}"
}

log_warning() {
    echo -e "${YELLOW_BOLD}$1${NC}"
}

log_error() {
    echo -e "${RED_BOLD}$1${NC}"
}

# Function to list Python versions installed with pyenv
list_pyenv_versions() {
    if [[ -d "$PYENV_DIR" ]]; then
        export PATH="$PYENV_DIR/bin:$PATH"
        if command -v pyenv &> /dev/null; then
            pyenv versions --bare
        else
            log_error "pyenv is not installed or not functioning correctly."
            return 1
        fi
    else
        log_error "pyenv directory not found."
        return 1
    fi
}

# Function to list globally installed Python versions
list_global_python_versions() {
    local versions=()
    if command -v python3 &> /dev/null; then
        versions+=("Python3: $(python3 --version 2>&1 | awk '{print $2}')")
    else
        log_warning "Python3 is not installed globally."
    fi

    if command -v python &> /dev/null; then
        versions+=("Python: $(python --version 2>&1 | awk '{print $2}')")
    else
        log_warning "Python is not installed globally."
    fi

    printf "%s\n" "${versions[@]}"
}

# Function to check coder installation for a specific Python binary
check_coder_for_python_binary() {
    local python_bin=$1
    local python_version=$2

    if [[ -x "$python_bin" ]]; then
        log_info "Checking coder for Python version: $python_version"
        if [[ "$python_version" == "$PYTHON_VERSION_TO_CHECK" ]]; then
            if /usr/local/bin/code --version &> /dev/null; then
                local coder_version=$(/usr/local/bin/coder --version | head -n 1)
                local coder_path="/usr/local/bin/coder"
                log_success "The coder installed for Python version $python_version is:"
                log_success "Coder Version: $coder_version"
                log_success "Coder Path: $coder_path"
            else
                log_warning "Coder is not installed for Python $python_version."
            fi
        else
            if "$python_bin" -m pip show coder &> /dev/null; then
                local coder_version=$("$python_bin" -c "import subprocess; print(subprocess.run(['coder', '--version'], capture_output=True, text=True).stdout.strip())")
                local coder_path=$(which coder)
                log_success "The coder installed for Python version $python_version is:"
                log_success "Coder Version: $coder_version"
                log_success "Coder Path: $coder_path"
            else
                log_warning "Coder is not installed for Python $python_version."
            fi
        fi
    else
        log_error "Python binary not found for version $python_version."
    fi
}

# Function to check coder installation for pyenv versions
check_coder_for_pyenv_versions() {
    local pyenv_versions=$(list_pyenv_versions)
    if [[ -n "$pyenv_versions" ]]; then
        for version in $pyenv_versions; do
            local python_bin="$PYENV_DIR/versions/$version/bin/python3"
            log_info "Checking coder for Python version (pyenv): $version"
            check_coder_for_python_binary "$python_bin" "$version"
        done
    else
        log_warning "No Python versions found in pyenv."
    fi
}

# Function to check coder installation for global Python versions
check_coder_for_global_versions() {
    log_info "\nChecking coder for globally installed Python versions..."
    if command -v python3 &> /dev/null; then
        check_coder_for_python_binary "$(command -v python3)" "global Python3"
    else
        log_warning "Python3 is not installed globally."
    fi

    if command -v python &> /dev/null; then
        check_coder_for_python_binary "$(command -v python)" "global Python"
    else
        log_warning "Python is not installed globally."
    fi
}

# Main function to list Python versions and check coder installations
main() {
    log_warning "Listing installed Python versions...\n"
    
    log_info "Python versions installed with pyenv:"
    local pyenv_versions=$(list_pyenv_versions)
    if [[ -n "$pyenv_versions" ]]; then
        printf "$pyenv_versions"
    else
        log_warning "No Python versions found in pyenv."
    fi

    log_info "\nGlobally installed Python versions:"
    local global_versions=$(list_global_python_versions)
    if [[ -n "$global_versions" ]]; then
        printf "$global_versions"
    else
        log_warning "No global Python versions found."
    fi

    log_warning "\n\nChecking coder installation for each Python version...\n"
    check_coder_for_pyenv_versions
    check_coder_for_global_versions
}

# Execute the main function
main