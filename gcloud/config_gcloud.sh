#!/bin/bash

# Script for Google Cloud SDK (gcloud) configuration
# This script configures authentication and project selection in gcloud

# Importing color functions for messages
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

# Function to authenticate with Google Cloud
authenticate_gcloud() {
  print_header "Starting Google Cloud authentication..."
  
  # Check if gcloud is installed
  if ! command -v gcloud &> /dev/null; then
    print_error "Google Cloud SDK (gcloud) is not installed."
    print_info "Please run the installation script first."
    return 1
  fi
  
  print_info "You will be redirected to the browser for authentication."
  print_info "Please log in with your Google Cloud account."
  
  # Start the authentication process
  gcloud auth login
  
  # Check if authentication was successful
  if [ $? -eq 0 ]; then
    print_success "Authentication completed successfully!"
  else
    print_error "Authentication failed. Please try again."
    return 1
  fi
  
  return 0
}

# Function to select Google Cloud project
select_project() {
  print_header "Selecting Google Cloud project..."
  
  # List available projects
  print_info "Projects available in your account:"
  gcloud projects list
  
  # Ask the user to choose a project
  print_info "Enter the ID of the project you want to use:"
  read -r project_id
  
  # Set the default project
  gcloud config set project "$project_id"
  
  # Check if configuration was successful
  if [ $? -eq 0 ]; then
    print_success "Project '$project_id' configured successfully!"
  else
    print_error "Failed to configure project. Check if the ID is correct."
    return 1
  fi
  
  return 0
}

# Function to configure default region
configure_region() {
  print_header "Configuring default region..."
  
  # List available regions
  print_info "Common Google Cloud regions:"
  echo "us-central1 (Iowa)"
  echo "us-east1 (South Carolina)"
  echo "us-east4 (Northern Virginia)"
  echo "us-west1 (Oregon)"
  echo "europe-west1 (Belgium)"
  echo "europe-west2 (London)"
  echo "asia-east1 (Taiwan)"
  echo "asia-northeast1 (Tokyo)"
  echo "southamerica-east1 (São Paulo)"
  
  # Ask the user to choose a region
  print_info "Enter the region you want to use as default:"
  read -r region
  
  # Set the default region
  gcloud config set compute/region "$region"
  
  # Check if configuration was successful
  if [ $? -eq 0 ]; then
    print_success "Region '$region' configured successfully!"
  else
    print_error "Failed to configure region."
    return 1
  fi
  
  return 0
}

# Main function to configure gcloud
config_gcloud() {
  print_header "Starting Google Cloud SDK configuration..."

  if ! confirm_action "Do you want configure Google Cloud tools ?"; then
    print_info "Skipping configuration"
    return 0
  fi
  
  authenticate_gcloud
  if [ $? -eq 0 ]; then
    select_project
    configure_region
    
    print_success "Google Cloud SDK configuration completed!"
    print_info "Current configuration:"
    gcloud config list
  fi
  
  return 0
}

# If the script is run directly (not imported as source)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  config_gcloud
fi