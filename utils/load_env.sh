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

# Function to load environment variables from .env and .env.local files
load_env() {
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
}

# Function to load a specific environment variable from .env and .env.local files
load_env_var() {
  local var_name="$1"
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
}

# Function to load .env and .env.local files and then load a specific environment variable
load_env_and_var() {
  local var_name="$1"
  load_env
  load_env_var "$var_name"
}