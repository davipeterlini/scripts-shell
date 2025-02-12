#!/bin/bash

# Ensure Python is installed and PATH is configured
source "$(dirname "$0")/install_python.sh"
install_python

# Load environment variables
source "$(dirname "$0")/../../utils/load_env.sh"
load_env

# Function to get the latest version of coder
get_latest_coder_url() {
    echo "Fetching the latest version of coder..."
    latest_info=$(curl -s https://storage.googleapis.com/flow-coder/update_info.json)
    coder_url=$(echo $latest_info | python3 -c "import sys, json; print(json.load(sys.stdin)['url'])")
    echo "Latest coder URL: $coder_url"
}

# Function to install coder using pip in a virtual environment
install_coder_venv() {
    echo "Installing coder in a virtual environment..."
    coder_env_dir="$HOME/coder_env"
    python3 -m venv $coder_env_dir
    source $coder_env_dir/bin/activate
    pip install --upgrade pip
    get_latest_coder_url
    pip install $coder_url
    deactivate
    echo "Coder installed successfully in virtual environment."
}

# Function to install coder using conda
install_coder_conda() {
    echo "Installing coder using conda..."
    conda_path=$(which conda)
    if [[ -z $conda_path ]]; then
        echo "Conda is not installed. Please install Conda first."
        exit 1
    fi
    conda install -c conda-forge coder
    echo "Coder installed successfully using conda."
}

# Function to configure PATH
configure_path() {
    echo "Configuring PATH..."
    SHELL_CONFIG_FILE="$HOME/.zshrc"
    PATH_ENTRY='export PATH=$PATH:$HOME/coder_env/bin'

    if ! grep -Fxq "$PATH_ENTRY" $SHELL_CONFIG_FILE; then
        echo '' >> $SHELL_CONFIG_FILE
        echo $PATH_ENTRY >> $SHELL_CONFIG_FILE
        source $SHELL_CONFIG_FILE
        echo "PATH configured successfully in $SHELL_CONFIG_FILE."
    else
        echo "PATH entry already exists in $SHELL_CONFIG_FILE."
    fi
}

# Main script execution
if [[ $1 == "conda" ]]; then
    install_coder_conda
else
    install_coder_venv
    configure_path
fi

echo "Coder installation completed. Please restart your terminal or run 'source ~/.zshrc' to apply PATH changes."