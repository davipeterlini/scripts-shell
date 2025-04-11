#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define colors for output
RED_BOLD='\033[1;31m'
GREEN_BOLD='\033[1;32m'
YELLOW_BOLD='\033[1;33m'
BLUE_BOLD='\033[0;34m'
NC='\033[0m' # No Color

# Check if gsutil is installed
if ! command -v gsutil &> /dev/null
then
    echo -e "${RED_BOLD}gsutil could not be found. Please install the Google Cloud SDK.${NC}"
    exit 1
fi

# Get the directory of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Define variables
BUCKET_NAME="gs://flow-coder"
HTTP_BASE_URL="https://storage.googleapis.com/flow-coder"

# Function to upload a script
upload_script() {
    local source_script=$1

    # Ensure the source script exists
    if [ ! -f "$source_script" ]; then
        echo -e "${RED_BOLD}Source script $source_script does not exist.${NC}"
        exit 1
    fi

    local target_script_name=$(basename "$source_script")

    # Check if a file with the target name already exists in the bucket
    EXISTING_FILE=$(gsutil ls "$BUCKET_NAME/$target_script_name" 2> /dev/null || true)

    if [ -n "$EXISTING_FILE" ]; then
        echo -e "${YELLOW_BOLD}A file named $target_script_name already exists in the bucket. Removing it...${NC}"
        gsutil rm "$BUCKET_NAME/$target_script_name"
        echo -e "${GREEN_BOLD}Existing file removed.${NC}"
    fi

    # Upload the source script to the bucket
    echo -e "${BLUE_BOLD}Uploading $source_script to $BUCKET_NAME/$target_script_name...${NC}"
    gsutil cp "$source_script" "$BUCKET_NAME/$target_script_name"

    # Print the permalink for the uploaded script
    echo -e "${GREEN_BOLD}Script uploaded successfully.${NC}"
    echo -e "${BLUE_BOLD}Permalink: $HTTP_BASE_URL/$target_script_name${NC}"
}

# Main menu for selecting the script to upload
echo -e "${YELLOW_BOLD}Select the script to upload:${NC}"
echo -e "${BLUE_BOLD}1. Install script (install_coder.sh)${NC}"
echo -e "${BLUE_BOLD}2. Uninstall script (uninstall_coder.sh)${NC}"
echo -e "${BLUE_BOLD}3. Check script (check_coder.sh)${NC}"
read -p "Enter your choice (1, 2, or 3): " choice

case $choice in
    1)
        upload_script "$SCRIPT_DIR/install_coder.sh"
        ;;
    2)
        upload_script "$SCRIPT_DIR/uninstall_coder.sh"
        ;;
    3)
        upload_script "$SCRIPT_DIR/check_coder.sh"
        ;;
    *)
        echo -e "${RED_BOLD}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac