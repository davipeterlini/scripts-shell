#!/bin/bash

# Function to remove coder installed via conda
uninstall_coder_conda() {
    echo "Uninstalling coder installed via conda..."
    conda_path=$(which coder)
    if [[ $conda_path == *"/miniconda/"* ]]; then
        conda_env=$(echo $conda_path | sed 's|/bin/coder||')
        echo "Found conda environment: $conda_env"
        echo "Removing coder from conda environment..."
        source /usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh
        conda activate base
        conda remove coder -y
        conda deactivate
        echo "Coder uninstalled successfully from conda."
    else
        echo "Coder is not installed via conda."
    fi
}

# Function to remove coder environment if installed via script
uninstall_coder_script() {
    echo "Uninstalling coder installed via script..."
    if [ -d "$HOME/coder_env" ]; then
        rm -rf "$HOME/coder_env"
        echo "Coder environment removed successfully."
    else
        echo "Coder environment not found."
    fi
}

# Main script execution
uninstall_coder_conda
uninstall_coder_script

echo "Coder uninstallation completed."