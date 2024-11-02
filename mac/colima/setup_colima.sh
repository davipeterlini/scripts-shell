#!/bin/bash

# Function to check if Colima is installed
check_colima_installed() {
    if ! command -v colima &> /dev/null; then
        echo "Colima is not installed. Installing Colima..."
        brew install colima
    else
        echo "Colima is already installed."
    fi
}

# Function to start Colima with specified configurations
start_colima() {
    echo "Starting Colima with specified configurations..."
    colima start --memory 2 --cpu 1 --disk 10 --kubernetes false
}

# Main function to setup and start Colima
main() {
    check_colima_installed
    start_colima
}

# Execute the main function
main