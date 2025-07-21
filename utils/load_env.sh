#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors_message.sh"

# Function to find the project root directory
find_project_root() {
  local dir="$SCRIPT_DIR"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.env" ]; then
      echo "$dir"
      return
    fi
    dir=$(dirname "$dir")
  done
  print_error ".env file not found in any parent directory."
  exit 1
}

# Project root directory
PROJECT_ROOT=$(find_project_root)

# Function to find the .env and .env.local files in the project root directory
find_env_files() {
  ENV_FILE="$PROJECT_ROOT/.env"
  ENV_LOCAL_FILE="$PROJECT_ROOT/.env.local"
}

# Function to determine the operating system and set the HOME variable accordingly
set_home_based_on_os() {
  case "$(uname -s)" in
    Darwin)
      export HOME="/Users/$USER"
      ;;
    Linux)
      export HOME="/home/$USER"
      ;;
    *)
      print_error "Unsupported operating system."
      exit 1
      ;;
  esac
}

# Function to create or update the .env.local file with the HOME variable
update_env_local_file() {
  if [ ! -f "$ENV_LOCAL_FILE" ]; then
    echo "HOME=$HOME" > "$ENV_LOCAL_FILE"
    print_success ".env.local file created with HOME variable."
  else
    if grep -q '^HOME=' "$ENV_LOCAL_FILE"; then
      sed -i '' "s|^HOME=.*|HOME=$HOME|" "$ENV_LOCAL_FILE"
      print_success "HOME variable updated in .env.local file."
    else
      echo "HOME=$HOME" >> "$ENV_LOCAL_FILE"
      print_success "HOME variable added to .env.local file."
    fi
  fi
}

# Function to load environment variables from a specific .env file in assets directory
load_assets_env() {
  local env_file="$1"
  local assets_env_file="$PROJECT_ROOT/assets/$env_file"
  
  if [ -f "$assets_env_file" ]; then
    print_success "Loading environment variables from $assets_env_file"
    set -a
    source "$assets_env_file"
    set +a
    return 0
  else
    print_error "File $assets_env_file not found."
    return 1
  fi
}

# Function to load environment variables from .env and .env.local files
load_env() {
  # If an argument is provided, try to load from assets directory
  if [ -n "$1" ]; then
    load_assets_env "$1"
    return $?
  fi

  # Otherwise load default .env files
  find_env_files

  if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
  else
    print_error ".env file not found. Exiting..."
    exit 1
  fi

  if [ ! -f "$ENV_LOCAL_FILE" ]; then
    touch "$ENV_LOCAL_FILE"
    print_alert "Empty .env.local file created."
  fi

  set -a
  source "$ENV_LOCAL_FILE"
  set +a

  if [ -z "$HOME" ]; then
    set_home_based_on_os
    update_env_local_file
  fi

  # Mark environment as loaded
  export ENV_LOADED=true
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [ -z "$ENV_LOADED" ]; then
    # Pass any command line arguments to load_env
    load_env "$@"
    export ENV_LOADED=true
  fi
fi

# TODO - remove this function 
select_environment() {
   env_dir="$PROJECT_ROOT/assets"
   env_files=("$env_dir/.env.personal" "$env_dir/.env.work")
   print_info "Select an environment:"
   select env_file in "${env_files[@]}"; do
       if [ -n "$env_file" ]; then
           print_success "You selected $env_file"
           return 
       else
           print_error "Invalid selection. Try again."
       fi
   done
}