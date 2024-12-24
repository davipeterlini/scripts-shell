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

# Function to update the .env file with the new HOME variable
update_env_file() {
  local env_file=$(find_env_file)
  if [ -f "$env_file" ]; then
    # Remove existing HOME definition if it exists
    sed -i.bak '/^HOME=/d' "$env_file"
    # Insert the new HOME definition at the beginning of the file
    sed -i.bak "1i\HOME=\"$HOME\"\n" "$env_file"
  else
    echo ".env file not found. Exiting..."
    exit 1
  fi
}

# Function to load environment variables from .env and .env.local files
load_env() {
  local user="$1"
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

  # Set the HOME variable based on the operating system
  set_home_based_on_os "$user"
  # Update the .env file with the new HOME variable
  update_env_file
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

  # Set the HOME variable based on the operating system
  set_home_based_on_os "$user"
  # Update the .env file with the new HOME variable
  update_env_file
}

# Function to load .env and .env.local files and then load a specific environment variable
load_env_and_var() {
  local var_name="$1"
  local user="$2"
  load_env "$user"
  load_env_var "$var_name" "$user"
}