#!/bin/bash

# Environment variable loader utility
# Handles environment variables loading from .env files with proper error handling

# Get absolute directory of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required utilities
source "${SCRIPT_DIR}/colors_message.sh"
source "${SCRIPT_DIR}/bash_tools.sh"

# Constants
DEFAULT_ENV_FILE=".env"
DEFAULT_ENV_GLOBAL_FILE=".env.global"
DEFAULT_ENV_LOCAL_FILE=".env.local"

# Initialize global variables
ENV_FILE=""
ENV_LOCAL_FILE=""
PROJECT_ROOT=""

# ====================
# UTILITY FUNCTIONS
# ====================

# Initialize the project root and environment paths
_initialize_env_paths() {
  # Get project root only if not already set
  if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT=$(find_project_root)
    
    # Exit if project root cannot be found
    if [ $? -ne 0 ] || [ -z "$PROJECT_ROOT" ]; then
      print_error "Failed to find project root directory."
      return 1
    fi
  fi
  
  # Set environment file paths
  _set_env_file_paths
  
  return 0
}

# Set environment file paths based on project root
_set_env_file_paths() {
  local assets_dir="${PROJECT_ROOT}/assets"
  
  # Find the main env file
  if [ -f "${assets_dir}/${DEFAULT_ENV_FILE}" ]; then
    ENV_FILE="${assets_dir}/${DEFAULT_ENV_FILE}"
  elif [ -f "${assets_dir}/${DEFAULT_ENV_GLOBAL_FILE}" ]; then
    ENV_FILE="${assets_dir}/${DEFAULT_ENV_GLOBAL_FILE}"
    print_alert "Using ${DEFAULT_ENV_GLOBAL_FILE} as default environment file"
  else
    # Create a new .env file
    ENV_FILE="${assets_dir}/${DEFAULT_ENV_FILE}"
    mkdir -p "$assets_dir"
    touch "$ENV_FILE"
    print_alert "Created empty ${DEFAULT_ENV_FILE} file in assets directory"
  fi
  
  # Set local env file path
  ENV_LOCAL_FILE="${assets_dir}/${DEFAULT_ENV_LOCAL_FILE}"
  
  return 0
}

# Ensure HOME variable is set correctly
_ensure_home_variable() {
  if [ -z "$HOME" ]; then
    _set_home_based_on_os
    _update_env_local_file
  fi
}

# Set HOME based on OS
_set_home_based_on_os() {
  case "$(uname -s)" in
    Darwin)
      export HOME="/Users/$USER"
      ;;
    Linux)
      export HOME="/home/$USER"
      ;;
    *)
      print_error "Unsupported operating system."
      return 1
      ;;
  esac
  
  return 0
}

# Update .env.local file with HOME variable
_update_env_local_file() {
  # Create the file if it doesn't exist
  if [ ! -f "$ENV_LOCAL_FILE" ]; then
    mkdir -p "$(dirname "$ENV_LOCAL_FILE")"
    echo "HOME=$HOME" > "$ENV_LOCAL_FILE"
    print_success ".env.local file created with HOME variable."
    return 0
  fi
  
  # Update existing HOME variable or add new one
  if grep -q '^HOME=' "$ENV_LOCAL_FILE"; then
    # Use OS-specific sed syntax
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s|^HOME=.*|HOME=$HOME|" "$ENV_LOCAL_FILE"
    else
      sed -i "s|^HOME=.*|HOME=$HOME|" "$ENV_LOCAL_FILE"
    fi
    print_success "HOME variable updated in .env.local file."
  else
    echo "HOME=$HOME" >> "$ENV_LOCAL_FILE"
    print_success "HOME variable added to .env.local file."
  fi
  
  return 0
}

# Load a specific env file from assets directory
_load_specific_env_file() {
  local env_file="$1"
  local assets_env_file="${PROJECT_ROOT}/assets/${env_file}"
  
  if [ -f "$assets_env_file" ]; then
    print_info "Loading environment variables from $assets_env_file"
    set -a
    source "$assets_env_file"
    set +a
    return 0
  else
    print_error "File $assets_env_file not found."
    return 1
  fi
}

# Load default env files
_load_default_env_files() {
  # Load main .env file
  if [ -f "$ENV_FILE" ]; then
    print_info "Loading environment variables from $ENV_FILE"
    set -a
    source "$ENV_FILE"
    set +a
  else
    print_error ".env file not found at $ENV_FILE. Exiting..."
    return 1
  fi
  
  # Create .env.local if it doesn't exist
  if [ ! -f "$ENV_LOCAL_FILE" ]; then
    mkdir -p "$(dirname "$ENV_LOCAL_FILE")"
    touch "$ENV_LOCAL_FILE"
    print_alert "Empty .env.local file created at $ENV_LOCAL_FILE"
  fi
  
  # Load .env.local file
  print_info "Loading environment variables from $ENV_LOCAL_FILE"
  set -a
  source "$ENV_LOCAL_FILE"
  set +a
  
  return 0
}

# ====================
# PUBLIC FUNCTIONS
# ====================

# Main function to load environment variables
load_env() {
  # Initialize project paths
  _initialize_env_paths || return 1
  
  # If an argument is provided, try to load from assets directory
  if [ -n "$1" ]; then
    _load_specific_env_file "$1"
    return $?
  fi
  
  # Otherwise load default .env files
  _load_default_env_files
  
  # Ensure HOME variable is set
  _ensure_home_variable
  
  # Mark environment as loaded
  export ENV_LOADED=true
  
  return 0
}

# Select an environment from available options
select_environment() {
  _initialize_env_paths || return 1
  
  local env_dir="${PROJECT_ROOT}/assets"
  local env_files=("${env_dir}/.env.personal" "${env_dir}/.env.work")
  
  print_info "Select an environment:"
  select env_file in "${env_files[@]}"; do
    if [ -n "$env_file" ]; then
      print_success "You selected $env_file"
      # Load the selected environment
      _load_specific_env_file "$(basename "$env_file")"
      return $?
    else
      print_error "Invalid selection. Try again."
    fi
  done
}

# ====================
# INITIALIZATION
# ====================

# Execute main function if the script is being run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [ -z "$ENV_LOADED" ]; then
    # Pass any command line arguments to load_env
    load_env "$@"
  fi
fi