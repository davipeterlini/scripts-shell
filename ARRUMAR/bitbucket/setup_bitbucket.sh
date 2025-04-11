#!/bin/bash

# Script to set up Bitbucket environment following the recommended sequence.

# Colors for terminal messages
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Base directory of the script
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to display formatted messages
function print_message() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${YELLOW}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
}

# Function to display success messages
function print_success() {
  echo -e "${GREEN}$1${NC}"
}

# Function to display error messages
function print_error() {
  echo -e "${RED}Error: $1${NC}"
}

# Step 1: Configure SSH keys for multiple Bitbucket accounts
print_message "Step 1: Configuring SSH keys for multiple Bitbucket accounts..."
if "${BASE_DIR}/configure_multi_ssh_bitbucket_keys.sh"; then
  print_success "Step 1 completed successfully!"
else
  print_error "Error executing configure_multi_ssh_bitbucket_keys.sh. Aborting."
  exit 1
fi

# Step 2: Generate Bitbucket App Password
print_message "Step 2: Generating Bitbucket App Password..."
if "${BASE_DIR}/generate-app-password.sh"; then
  print_success "Step 2 completed successfully!"
else
  print_error "Error executing generate-app-password.sh. Aborting."
  exit 1
fi

# Step 3: Connect Bitbucket account using SSH
print_message "Step 3: Connecting Bitbucket account using SSH..."
if "${BASE_DIR}/connect_git_ssh_account.sh"; then
  print_success "Step 3 completed successfully!"
else
  print_error "Error executing connect_git_ssh_account.sh. Aborting."
  exit 1
fi

print_message "Bitbucket environment configuration completed successfully!"