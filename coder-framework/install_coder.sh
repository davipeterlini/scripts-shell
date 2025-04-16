#!/bin/bash

set -e

# Define colors for output
RED_BOLD='\033[1;31m'
GREEN_BOLD='\033[1;32m'
YELLOW_BOLD='\033[1;33m'
BLUE_BOLD='\033[0;34m'
NC='\033[0m' # No Color

PYTHON_VERSION="3.12.9"
PYTHON_PKG_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-macos11.pkg"
PYTHON_LINUX_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
PYENV_INSTALLER_URL="https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer"
PYENV_DIR="$HOME/.pyenv"
PYENV_VIRTUALENV_DIR="$PYENV_DIR/plugins/pyenv-virtualenv"
TEMP_DIR="./temp"
CODER_PACKAGE_URL="https://storage.googleapis.com/flow-coder/coder-0.88-py3-none-any.whl"
OFFICIAL_CODER_PATH="/usr/local/bin/coder"

# Function to check if Python is installed globally
check_global_python() {
    echo -e "${YELLOW_BOLD}Checking for global Python installation...${NC}"
    if command -v python3 &> /dev/null; then
        global_version=$(python3 --version 2>&1 | awk '{print $2}')
        if [[ "$global_version" == "$PYTHON_VERSION" ]]; then
            echo -e "${GREEN_BOLD}Python $PYTHON_VERSION is already installed globally.${NC}"
            exit 0
        else
            echo -e "${BLUE}Global Python version is $global_version, not $PYTHON_VERSION.${NC}"
        fi
    else
        echo -e "${BLUE}No global Python installation detected.${NC}"
    fi
}

# Function to check if Python is installed with pyenv
check_pyenv_python_and_coder() {
    echo -e "${YELLOW_BOLD}Checking if Python $PYTHON_VERSION is installed with pyenv and if coder is installed...${NC}"
    if [[ -d "$PYENV_DIR" ]]; then
        export PATH="$PYENV_DIR/bin:$PATH"
        if command -v pyenv &> /dev/null; then
            if pyenv versions --bare | grep -q "^$PYTHON_VERSION$"; then
                echo -e "${GREEN_BOLD}Python $PYTHON_VERSION is already installed with pyenv.${NC}"
                PYENV_PYTHON_BIN="$PYENV_DIR/versions/$PYTHON_VERSION/bin/python3"
                if [[ -x "$PYENV_PYTHON_BIN" ]]; then
                    if "$PYENV_PYTHON_BIN" -m pip show coder &> /dev/null; then
                        coder_version=$("$PYENV_PYTHON_BIN" -c "import subprocess; print(subprocess.run(['coder', '--version'], capture_output=True, text=True).stdout.strip())")
                        echo -e "${GREEN_BOLD}Coder is already installed for Python $PYTHON_VERSION. Coder Version: $coder_version${NC}"
                        exit 0
                    else
                        echo -e "${BLUE}Coder is not installed for Python $PYTHON_VERSION.${NC}"
                    fi
                else
                    echo -e "${RED_BOLD}Python $PYTHON_VERSION binary not found in pyenv directory.${NC}"
                fi
            else
                echo -e "${BLUE}Python $PYTHON_VERSION is not installed with pyenv.${NC}"
            fi
        else
            echo -e "${RED_BOLD}pyenv is installed but not functioning correctly.${NC}"
        fi
    else
        echo -e "${BLUE}pyenv is not installed.${NC}"
    fi
}

# Function to check if pyenv is installed correctly
check_pyenv_integrity() {
    echo -e "${YELLOW_BOLD}Checking pyenv installation integrity...${NC}"
    if [[ -d "$PYENV_DIR" ]]; then
        export PATH="$PYENV_DIR/bin:$PATH"
        if command -v pyenv &> /dev/null; then
            pyenv_version=$(pyenv --version 2>&1)
            if [[ $? -eq 0 ]]; then
                echo -e "${GREEN_BOLD}pyenv is installed and working correctly. Version: $pyenv_version${NC}"
                eval "$(pyenv init --path)"
                eval "$(pyenv init -)"
                check_pyenv_virtualenv
            else
                echo -e "${RED_BOLD}pyenv installation is incomplete or corrupted. Removing and reinstalling pyenv...${NC}"
                rm -rf "$PYENV_DIR"
                install_pyenv
            fi
        else
            echo -e "${RED_BOLD}pyenv installation is incomplete or corrupted. Removing and reinstalling pyenv...${NC}"
            rm -rf "$PYENV_DIR"
            install_pyenv
        fi
    else
        echo -e "${YELLOW_BOLD}pyenv is not installed. Proceeding with installation...${NC}"
        install_pyenv
    fi
}

# Function to check and install pyenv-virtualenv
check_pyenv_virtualenv() {
    echo -e "${YELLOW_BOLD}Checking pyenv-virtualenv plugin...${NC}"
    if [[ -d "$PYENV_VIRTUALENV_DIR" ]]; then
        echo -e "${GREEN_BOLD}pyenv-virtualenv is already installed.${NC}"
        eval "$(pyenv virtualenv-init -)"
    else
        echo -e "${BLUE}pyenv-virtualenv is not installed. Installing pyenv-virtualenv...${NC}"
        git clone https://github.com/pyenv/pyenv-virtualenv.git "$PYENV_VIRTUALENV_DIR"
        eval "$(pyenv virtualenv-init -)"
        echo -e "${GREEN_BOLD}pyenv-virtualenv installed successfully.${NC}"
    fi
}

# Function to install pyenv directly from the official repository
install_pyenv() {
    echo -e "${YELLOW_BOLD}Installing pyenv from the official repository...${NC}"

    # Download and run the pyenv installer script
    curl -L "$PYENV_INSTALLER_URL" | bash

    # Configure shell environment for pyenv
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    check_pyenv_virtualenv

    echo -e "${GREEN_BOLD}pyenv installed successfully.${NC}"
}

# Function to install Python on Linux using official precompiled packages
install_python_linux() {
    echo -e "${YELLOW_BOLD}Installing Python $PYTHON_VERSION on Linux...${NC}"

    # Install dependencies for building Python
    echo -e "${BLUE}Installing build dependencies...${NC}"
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libgdbm-dev \
        libdb5.3-dev \
        libbz2-dev \
        libexpat1-dev \
        liblzma-dev \
        tk-dev \
        uuid-dev \
        libffi-dev

    # Create a temporary directory
    mkdir -p "$TEMP_DIR"

    # Download the official Python source tarball
    echo -e "${BLUE}Downloading Python $PYTHON_VERSION tarball...${NC}"
    curl -o "$TEMP_DIR/Python-$PYTHON_VERSION.tgz" "$PYTHON_LINUX_URL"

    # Extract the tarball
    echo -e "${BLUE}Extracting Python $PYTHON_VERSION tarball...${NC}"
    tar -xzf "$TEMP_DIR/Python-$PYTHON_VERSION.tgz" -C "$TEMP_DIR"

    # Install Python using the official tarball
    echo -e "${BLUE}Installing Python $PYTHON_VERSION using the official tarball...${NC}"
    cd "$TEMP_DIR/Python-$PYTHON_VERSION"
    ./configure --enable-optimizations
    make -j$(nproc)
    sudo make altinstall

    # Clean up the temporary directory
    echo -e "${BLUE}Cleaning up temporary files...${NC}"
    cd -
    rm -rf "$TEMP_DIR"

    echo -e "${GREEN_BOLD}Python $PYTHON_VERSION installed successfully on Linux.${NC}"
}

# Function to install Python on macOS using precompiled packages
install_python_macos() {
    echo -e "${YELLOW_BOLD}Installing Python $PYTHON_VERSION on macOS...${NC}"

    # Create a temporary directory
    mkdir -p "$TEMP_DIR"

    # Download the official Python installer for macOS
    echo -e "${BLUE}Downloading Python $PYTHON_VERSION installer for macOS...${NC}"
    curl -o "$TEMP_DIR/python-$PYTHON_VERSION-macos11.pkg" "$PYTHON_PKG_URL"

    # Install Python using the official installer
    echo -e "${BLUE}Installing Python $PYTHON_VERSION using the official installer...${NC}"
    sudo installer -pkg "$TEMP_DIR/python-$PYTHON_VERSION-macos11.pkg" -target /

    # Clean up the temporary directory
    echo -e "${BLUE}Cleaning up temporary files...${NC}"
    rm -rf "$TEMP_DIR"

    echo -e "${GREEN_BOLD}Python $PYTHON_VERSION installed successfully on macOS.${NC}"
}

# Function to add Python to pyenv if pyenv is installed
add_python_to_pyenv() {
    if [[ -d "$PYENV_DIR" ]]; then
        echo -e "${YELLOW_BOLD}Adding Python $PYTHON_VERSION to pyenv...${NC}"
        pyenv install -s "$PYTHON_VERSION"
        pyenv global "$PYTHON_VERSION"
        echo -e "${GREEN_BOLD}Python $PYTHON_VERSION added to pyenv and set as global version.${NC}"
    else
        echo -e "${BLUE_BOLD}pyenv is not installed. Skipping pyenv integration.${NC}"
    fi
}

# Function to install the coder package
install_coder_package() {
    echo -e "${YELLOW_BOLD}Installing the coder package from $CODER_PACKAGE_URL using Python $PYTHON_VERSION...${NC}"
    PYENV_PYTHON_BIN="$PYENV_DIR/versions/$PYTHON_VERSION/bin/python3"
    if [[ -x "$PYENV_PYTHON_BIN" ]]; then
        "$PYENV_PYTHON_BIN" -m pip install "$CODER_PACKAGE_URL"
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN_BOLD}Coder package installed successfully.${NC}"
        else
            echo -e "${RED_BOLD}Failed to install the coder package.${NC}"
            exit 1
        fi
    else
        echo -e "${RED_BOLD}Python $PYTHON_VERSION binary not found in pyenv directory.${NC}"
        exit 1
    fi
}

# Function to test the coder package
test_coder_package() {
    echo -e "${YELLOW_BOLD}Testing the coder package...${NC}"

    # Create a temporary directory for testing
    mkdir -p "$TEMP_DIR"
    pushd "$TEMP_DIR" > /dev/null

    # Run the coder commands
    echo -e "${BLUE}Running 'coder --version'...${NC}"
    coder --version

    echo -e "${BLUE}Running 'coder init'...${NC}"
    coder init

    # Return to the original directory and clean up
    popd > /dev/null
    echo -e "${BLUE}Cleaning up temporary test directory...${NC}"
    rm -rf "$TEMP_DIR"

    echo -e "${GREEN_BOLD}Coder package tested successfully.${NC}"
}

# Function to verify Python installation
verify_installation() {
    echo -e "${YELLOW_BOLD}Verifying Python installation...${NC}"
    python_version=$(pyenv global)
    if [[ "$python_version" == "$PYTHON_VERSION" ]]; then
        echo -e "${GREEN_BOLD}Python $PYTHON_VERSION is correctly installed and set as global.${NC}"
    else
        echo -e "${RED_BOLD}Python installation failed. Installed version: $python_version${NC}"
        exit 1
    fi
}

configure_coder_default() {
    echo -e "${YELLOW_BOLD}Configuring coder to always use Python $PYTHON_VERSION...${NC}"
    WRAPPER_SCRIPT="/usr/local/bin/coder"
    sudo bash -c "cat > $WRAPPER_SCRIPT" <<EOL
#!/bin/bash
export PATH="$PYENV_DIR/versions/$PYTHON_VERSION/bin:\$PATH"
exec coder "\$@"
EOL
    sudo chmod +x "$WRAPPER_SCRIPT"
    echo -e "${GREEN_BOLD}Coder configured to use Python $PYTHON_VERSION by default.${NC}"

    # Identify the user's profile file
    PROFILE_FILE=""
    if [[ -f "$HOME/.bashrc" ]]; then
        PROFILE_FILE="$HOME/.bashrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        PROFILE_FILE="$HOME/.zshrc"
    elif [[ -f "$HOME/.profile" ]]; then
        PROFILE_FILE="$HOME/.profile"
    elif [[ -f "$HOME/.bash_profile" ]]; then
        PROFILE_FILE="$HOME/.bash_profile"
    fi

    if [[ -n "$PROFILE_FILE" ]]; then
        echo -e "${YELLOW_BOLD}Updating PATH in $PROFILE_FILE to prioritize coder...${NC}"
        if ! grep -q "$OFFICIAL_CODER_PATH" "$PROFILE_FILE"; then
            echo "export PATH=/usr/local/bin:\$PATH" >> "$PROFILE_FILE"
            echo -e "${GREEN_BOLD}PATH updated in $PROFILE_FILE.${NC}"
        else
            echo -e "${BLUE_BOLD}PATH already includes /usr/local/bin in $PROFILE_FILE.${NC}"
        fi
    else
        echo -e "${RED_BOLD}No profile file found to update PATH. Please update it manually.${NC}"
    fi
}

# Main script execution
check_global_python
check_pyenv_python_and_coder
check_pyenv_integrity

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_python_linux
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_python_macos
else
    echo -e "${RED_BOLD}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

add_python_to_pyenv
verify_installation
install_coder_package
configure_coder_default
test_coder_package