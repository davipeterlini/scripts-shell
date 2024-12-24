#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Function to find the .env file in the project root directory
find_env_file() {
  local dir="$SCRIPT_DIR"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.env" ]; then
      echo "$dir/.env"
      return
    fi
    dir=$(dirname "$dir")
  done
  echo ""
}

# Function to determine the operating system and set the HOME variable accordingly
set_home_based_on_os() {
  local user="$1"
  case "$(uname -s)" in
    Darwin)
      export HOME="/Users/$user"
      ;;
    Linux)
      export HOME="/home/$user"
      ;;
    *)
      echo "Unsupported operating system."
      exit 1
      ;;
  esac
}

# Function to update the .env file with the new HOME variable for macOS
update_env_file_mac() {
  local env_file=$(find_env_file)
  if [ -f "$env_file" ]; then
    # Remove existing HOME definition if it exists
    sed -i '' '/^HOME=/d' "$env_file"
    # Insert the new HOME definition at the beginning of the file
    sed -i '' "1i\\
HOME=\"$HOME\"
" "$env_file"
  else
    echo ".env file not found. Exiting..."
    exit 1
  fi
}

# Function to update the .env file with the new HOME variable for Linux
update_env_file_linux() {
  local env_file=$(find_env_file)
  if [ -f "$env_file" ]; then
    # Remove existing HOME definition if it exists
    sed -i '/^HOME=/d' "$env_file"
    # Insert the new HOME definition at the beginning of the file
    sed -i "1i\\
HOME=\"$HOME\"
" "$env_file"
  else
    echo ".env file not found. Exiting..."
    exit 1
  fi
}

# Function to check if HOME is already set in the .env file
check_existing_home() {
  local env_file=$(find_env_file)
  if [ -f "$env_file" ]; then
    existing_home=$(grep '^HOME=' "$env_file" | cut -d '=' -f2-)
    if [ -n "$existing_home" ]; then
      echo "Existing HOME found in .env: $existing_home"
      read -p "Do you want to use the existing HOME? (y/n): " choice
      if [ "$choice" == "y" ]; then
        export HOME="$existing_home"
        return 0
      fi
    fi
  fi
  return 1
}

# Function to load environment variables from .env and .env.local files
load_env() {
  local user
  local env_file=$(find_env_file)
  if [ -f "$env_file" ]; then
    set -a
    source "$env_file"
    set +a
  else
    echo ".env file not found. Exiting..."
    exit 1
  fi

  if [ -f "$env_file.local" ]; then
    set -a
    source "$env_file.local"
    set +a
  else
    echo ".env.local file not found. Make sure to create it for sensitive information."
  fi

  # Check if HOME is already set and ask the user if they want to use it
  if ! check_existing_home; then
    # Prompt for user and set the HOME variable based on the operating system
    read -p "Enter the USER for the environment: " user
    set_home_based_on_os "$user"
    # Update the .env file with the new HOME variable
    if [[ "$(uname -s)" == "Darwin" ]]; then
      update_env_file_mac
    else
      update_env_file_linux
    fi
  fi
}

# Function to load a specific environment variable from .env and .env.local files
load_env_var() {
  local var_name="$1"
  local user="$2"
  local env_file=$(find_env_file)
  if [ -f "$env_file" ]; then
    local var_value=$(grep -v '^#' "$env_file" | grep -E "^${var_name}=" | cut -d '=' -f2-)
    export "${var_name}=${var_value}"
  else
    echo ".env file not found. Exiting..."
    exit 1
  fi

  if [ -f "$env_file.local" ]; then
    local var_value=$(grep -v '^#' "$env_file.local" | grep -E "^${var_name}=" | cut -d '=' -f2-)
    export "${var_name}=${var_value}"
  else
    echo ".env.local file not found. Make sure to create it for sensitive information."
  fi

  # Check if HOME is already set and ask the user if they want to use it
  if ! check_existing_home; then
    # Set the HOME variable based on the operating system
    set_home_based_on_os "$user"
    # Update the .env file with the new HOME variable
    if [[ "$(uname -s)" == "Darwin" ]]; then
      update_env_file_mac
    else
      update_env_file_linux
    fi
  fi
}

# Function to load .env and .env.local files and then load a specific environment variable
load_env_and_var() {
  local var_name="$1"
  local user="$2"
  load_env "$user"
  load_env_var "$var_name" "$user"
}