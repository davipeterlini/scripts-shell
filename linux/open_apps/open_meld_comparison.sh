#!/bin/bash

# Function to open Meld with file comparison
open_meld_comparison() {
    local file1="$1"
    local file2="$2"

    # Create a temporary file if one of the files is not provided
    if [ -z "$file1" ]; then
        file1=$(mktemp)
    fi

    if [ -z "$file2" ]; then
        file2=$(mktemp)
    fi

    # Open Meld with the provided files
    echo "Opening Meld with files: $file1 and $file2"
    meld "$file1" "$file2"
}

# Main function to handle input parameters
main() {
    local file1="$1"
    local file2="$2"

    open_meld_comparison "$file1" "$file2"
}

# Execute the main function with the provided arguments
main "$1" "$2"