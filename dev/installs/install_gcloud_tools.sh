#!/bin/bash

# Script for installing Google Cloud SDK (gcloud) and gsutil
# This script provides functions to check and install Google Cloud tools

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

# Function to install Google Cloud SDK (gcloud)
install_gcloud() {
  print_header "Installing Google Cloud SDK (gcloud)..."
  
  # Check the operating system
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    print_info "Linux system detected. Installing gcloud..."
    
    # Add Cloud SDK repository and install
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install -y google-cloud-sdk
    
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    print_info "macOS system detected. Installing gcloud..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
      print_alert "Homebrew is not installed. Installing Homebrew first..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install gcloud via Homebrew
    brew install --cask google-cloud-sdk
    
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    print_info "Windows system detected. Please download and install Google Cloud SDK manually:"
    print_yellow "https://cloud.google.com/sdk/docs/install-sdk#windows"
    print_yellow "After installation, restart this script."
    return 1
  else
    print_error "Unsupported operating system: $OSTYPE"
    print_yellow "Please install Google Cloud SDK manually: https://cloud.google.com/sdk/docs/install"
    return 1
  fi
  
  print_success "Google Cloud SDK (gcloud) installed successfully!"
  return 0
}

# Function to install gsutil
# Note: gsutil is usually installed as part of Google Cloud SDK
install_gsutil() {
  print_header "Checking gsutil installation..."
  
  # Check if gcloud is installed first
  if ! command -v gcloud &> /dev/null; then
    print_alert "Google Cloud SDK (gcloud) is not installed. gsutil is part of the SDK."
    install_gcloud
  fi
  
  # Check if gsutil is available
  if ! command -v gsutil &> /dev/null; then
    print_info "Installing additional Google Cloud SDK components..."
    gcloud components install gsutil
  else
    print_info "gsutil is already installed."
  fi
  
  print_success "gsutil is ready to use!"
  return 0
}

# Function to check and install all necessary tools
install_gcloud_tools() {
  print_header_info "Checking and installing Google Cloud tools..."

  if ! get_user_confirmation "Do you want installing Google Cloud tools ?"; then
    print_info "Skipping install"
    return 0
  fi
  
  # Install gcloud if necessary
  if ! command -v gcloud &> /dev/null; then
    install_gcloud
  else
    print_success "Google Cloud SDK (gcloud) is already installed."
  fi
  
  # Install gsutil if necessary
  if ! command -v gsutil &> /dev/null; then
    install_gsutil
  else
    print_success "gsutil is already installed."
  fi
  
  print_success "All Google Cloud tools are installed and ready to use!"
  return 0
}

# If the script is run directly (not imported as source)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_gcloud_tools
fi