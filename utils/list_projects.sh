#!/bin/bash

# Function to display available projects
list_projects() {
  print_header "Available Projects:"
  local index=1
  for identity in $(env | grep '^PROJECT_DIR_' | sed 's/^PROJECT_DIR_//' | sed 's/=.*//'); do
    print_info "  $index) $(echo $identity | tr '[:upper:]' '[:lower:]')"  # Convert to lowercase
    index=$((index + 1))
  done
}