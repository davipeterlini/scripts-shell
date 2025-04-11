#!/bin/bash

# Function to check which coder is being used
check_coder() {
    coder_path=$(which coder)
    if [[ $coder_path == *"/miniconda/"* ]]; then
        echo "Coder is being used from conda: $coder_path"
    elif [[ $coder_path == *"$HOME/coder_env/bin/coder"* ]]; then
        echo "Coder is being used from the PATH configured in the profile: $coder_path"
    else
        echo "Coder is being used from an unknown location: $coder_path"
    fi
}

# Function to run coder from the virtual environment
run_coder_venv() {
    $HOME/coder_env/bin/coder "$@"
}

# Main script execution
if [[ $1 == "venv" ]]; then
    shift
    run_coder_venv "$@"
else
    check_coder
fi