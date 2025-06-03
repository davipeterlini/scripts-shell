#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors_message.sh"

# Function to display available projects
list_projects() {
  print_header "Available Projects:"
  local index=1
  for identity in $(env | grep '^PROJECT_DIR_' | sed 's/^PROJECT_DIR_//' | sed 's/=.*//'); do
    print_info "  $index) $(echo $identity | tr '[:upper:]' '[:lower:]')"  # Convert to lowercase
    index=$((index + 1))
  done
}