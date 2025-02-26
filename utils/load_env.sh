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

update_env_file() {
  local env_file=$(find_env_file)
  if [ -f "$env_file" ]; then
    # Remove existing HOME definition if it exists
    sed -i '' -e '/^HOME=/d' "$env_file"
    # Insert the new HOME definition at the beginning of the file (without quotes)
    sed -i '' -e '1i\
HOME='"$HOME" "$env_file"
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
    update_env_file
  fi

  # Mark environment as loaded
  export ENV_LOADED=true
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [ -z "$ENV_LOADED" ]; then
    load_env
    export ENV_LOADED=true
  fi
fi