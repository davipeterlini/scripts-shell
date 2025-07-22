#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors_message.sh"

# Function to find the project root directory with assets folder
find_project_root() {
  # Start from the script's directory
  local current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local root_dir="$current_dir"
  
  # Go up until we find the root directory (where assets/ is located)
  while [ "$root_dir" != "/" ]; do
    if [ -d "$root_dir/assets" ]; then
      echo "$root_dir"
      return 0
    fi
    root_dir=$(dirname "$root_dir")
  done
  
  # If we couldn't find it by going up, try the absolute path to the project root
  # This ensures it works regardless of where the script is executed from
  root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  if [ -d "$root_dir/assets" ]; then
    echo "$root_dir"
    return 0
  fi
  
  # If still not found, try a few common locations
  local alt_paths=(
    "$(pwd)"
    "$(pwd)/.."
    "$(pwd)/../.."
    "$(pwd)/../../.."
  )
  
  for alt_path in "${alt_paths[@]}"; do
    if [ -d "$alt_path/assets" ]; then
      echo "$alt_path"
      return 0
    fi
  done
  
  print_error "assets/ directory not found. Make sure you're running this from the project directory."
  return 1
}

# Function to create directories
create_directories() {
  local ROOT_DIR="$1"
  local directories=("$@")
  for dir in "${directories[@]}"; do
    if [[ "$dir" != "$ROOT_DIR" ]]; then
      full_dir="${ROOT_DIR}/${dir}"
      if [[ ! -d "$full_dir" ]]; then
        print_info "Creating directory: $full_dir"
        mkdir -p "$full_dir"
        print_success "Directory created: $full_dir"
      else
        print_info "Directory already exists: $full_dir"
      fi
    fi
  done
}

# Function to remove a directory
remove_directory() {
  local dir="$1"

  if [[ -d "$dir" ]]; then
    if rm -rf "$dir"; then
      print_success "Removed $dir"
      return 0
    else
      print_error "Failed to remove $dir"
      return 1
    fi
  else
    print_alert "$dir not found"
    return 0
  fi
}

# Function to remove multiple directories
# Modified to work with older Bash versions
remove_directories() {
  local array_name=$1
  local failed_count=0

  # Use eval to get the array elements
  eval "local directories=(\"\${$array_name[@]}\")"

  for dir in "${directories[@]}"; do
    if ! remove_directory "$dir"; then
      ((failed_count++))
    fi
  done

  if [[ $failed_count -gt 0 ]]; then
    print_alert "Failed to remove $failed_count directories"
  fi
}

get_user_confirmation() {
  local prompt_message="${1:-"Do you want to proceed? (y/n): "}"
  print_alert_question "$prompt_message (y/n) "
  read -r user_choice
  if [[ "$user_choice" =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

cleanup_temp_files() {
    local temp_dir="$1"
    rm -rf "$temp_dir"
}