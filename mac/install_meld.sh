#!/bin/bash

# Colors for terminal messages
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

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

# Check if the script is running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  print_error "This script is intended to run on macOS only."
  exit 1
fi

# Determine the architecture (Intel or Apple Silicon)
ARCHITECTURE=$(uname -m)
if [[ "$ARCHITECTURE" == "x86_64" ]]; then
  print_message "Detected macOS Intel architecture."
elif [[ "$ARCHITECTURE" == "arm64" ]]; then
  print_message "Detected macOS Apple Silicon architecture."
else
  print_error "Unsupported architecture: $ARCHITECTURE"
  exit 1
fi

# Install dependencies
print_message "Installing dependencies..."
brew install python3 gtk+3 adwaita-icon-theme

# Download Meld tarball
print_message "Downloading Meld tarball..."
curl -O https://download.gnome.org/sources/meld/3.22/meld-3.22.2.tar.xz

# Extract tarball
print_message "Extracting Meld tarball..."
tar -xf meld-3.22.2.tar.xz

# Navigate to Meld directory
cd meld-3.22.2 || exit

# Install Meld
print_message "Installing Meld..."
python3 setup.py install

# Clean up
print_message "Cleaning up..."
cd ..
rm -rf meld-3.22.2 meld-3.22.2.tar.xz

print_success "Meld installation completed successfully!"