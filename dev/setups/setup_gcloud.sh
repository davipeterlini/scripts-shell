#!/bin/bash

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/dev/installs/install_gcloud_tools.sh"

# Function to authenticate with Google Cloud
__authenticate_gcloud() {
  print_info "Starting Google Cloud authentication..."
  
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
__select_project() {
  print_info "Selecting Google Cloud project..."
  
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
__configure_region() {
  print_info "Configuring default region..."
  
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

_config_gcloud() {
  print_info "Starting Google Cloud SDK configuration..."

  if ! get_user_confirmation "Do you want configure Google Cloud tools ?"; then
    print_info "Skipping configuration"
    return 0
  fi
  
  __authenticate_gcloud
  if [ $? -eq 0 ]; then
    __select_project
    __configure_region
    
    print_success "Google Cloud SDK configuration completed!"
    print_info "Current configuration:"
    gcloud config list
  fi
  
  return 0
}

setup_gcloud() {
    print_header_info "Starting Google Cloud SDK setup"

    if ! get_user_confirmation "Do you want Google Cloud SDK Configuration ?"; then
        print_info "Skipping configuration"
        return 0
    fi
    
    # Install Google Cloud SDK
    install_gcloud_tools
    
    # Configure Google Cloud SDK
    _config_gcloud
    
    print_success "Google Cloud SDK setup completed successfully!"
    
    return 0
}

# Execute main only if the script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_gcloud "$@"
fi