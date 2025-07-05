#!/bin/bash

# Script to create a bucket in Google Cloud Storage with specific subfolders
# This script creates a bucket called "flow-coder" and the following subfolders:
# - flow-coder-ide/vscode
# - flow-coder-ide/jetbrains
# - flow-coder-cli
# - flow-coder-mcp

# Importing color functions for messages
source "$(dirname "$0")/../utils/colors_message.sh"

# Importing gcloud and gsutil installation functions
source "$(dirname "$0")/install_gcloud_tools.sh"

# Defining variables
BUCKET_NAME="flow_coder"
FOLDERS=(
  "flow_coder_ide/vscode/"
  "flow_coder_ide/jetbrains/"
  "flow_coder_cli/"
  "flow_coder_mcp/"
)

# Function to check if the necessary tools are installed
check_required_tools() {
  print_header "Checking required tools..."

  local tools_missing=false

  # Check if gcloud is installed
  if ! command -v gcloud &> /dev/null; then
    print_alert "Google Cloud SDK (gcloud) is not installed."
    tools_missing=true
  fi

  # Check if gsutil is installed
  if ! command -v gsutil &> /dev/null; then
    print_alert "gsutil is not installed."
    tools_missing=true
  fi

  # If any tool is missing, install it
  if [ "$tools_missing" = true ]; then
    print_yellow "Some required tools are not installed."
    read -p "Do you want to install the missing tools now? (y/n): " choice

    if [[ "$choice" =~ ^[Yy]$ ]]; then
      install_all_cloud_tools
    else
      print_error "Required tools are not installed. Aborting."
      exit 1
    fi
  else
    print_success "All required tools are installed!"
  fi
}

# Function to authenticate with Google Cloud
authenticate_gcloud() {
  print_header "Checking Google Cloud authentication..."

  # Check if the user is authenticated in gcloud
  if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    print_alert "You need to be authenticated in Google Cloud to continue."
    print_yellow "Running authentication..."
    gcloud auth login

    # Check if authentication was successful
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
      print_error "Authentication failed. Aborting."
      exit 1
    fi
  else
    local account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
    print_success "Authenticated as: $account"
  fi
}

# Function to create the bucket
create_bucket() {
  print_header "Creating bucket '$BUCKET_NAME'..."

  if gcloud storage buckets create gs://$BUCKET_NAME --location=us-central1; then
    print_success "Bucket '$BUCKET_NAME' created successfully!"
  else
    print_error "Error creating bucket '$BUCKET_NAME'. Check if the name is already in use or if you have sufficient permissions."
    exit 1
  fi
}

# Function to create subfolders in the bucket
create_folders() {
  print_header "Creating folder structure..."

  # In Google Cloud Storage, "folders" are simulated by creating empty objects with names ending in "/"
  for folder in "${FOLDERS[@]}"; do
    print_info "Creating folder '$folder'..."

    # Creating an empty temporary file
    TEMP_FILE=$(mktemp)

    # Using gcloud storage instead of gsutil
    if gcloud storage cp $TEMP_FILE gs://$BUCKET_NAME/$folder; then
      print_success "Folder '$folder' created successfully!"
    else
      print_error "Error creating folder '$folder'."
    fi

    # Removing the temporary file
    rm $TEMP_FILE
  done
}

# Function to display operation summary
show_summary() {
  print_header "Process completed! Bucket '$BUCKET_NAME' created with all necessary subfolders."
  print_yellow "Created structure:"
  print "gs://$BUCKET_NAME/"
  for folder in "${FOLDERS[@]}"; do
    print "└── gs://$BUCKET_NAME/$folder"
  done
}

# Main function
main() {
  # Check required tools
  check_required_tools

  # Authenticate with Google Cloud
  authenticate_gcloud

  # Create the bucket
  create_bucket

  # Create subfolders
  create_folders

  # Show summary
  show_summary
}

# Run the main function
main