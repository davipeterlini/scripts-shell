#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Function to load environment variables from .env and .env.local files
load_env() {
  if [ -f "$SCRIPT_DIR/../.env" ]; then
    set -a
    source "$SCRIPT_DIR/../.env"
    set +a
  else
    echo ".env file not found. Exiting..."
    exit 1
  fi

  if [ -f "$SCRIPT_DIR/../.env.local" ]; then
    set -a
    source "$SCRIPT_DIR/../.env.local"
    set +a
  else
    echo ".env.local file not found. Make sure to create it for sensitive information."
  fi
}

# Function to load a specific environment variable from .env and .env.local files
load_env_var() {
  local var_name="$1"
  if [ -f "$SCRIPT_DIR/../.env" ]; then
    local var_value=$(grep -v '^#' "$SCRIPT_DIR/../.env" | grep -E "^${var_name}=" | cut -d '=' -f2-)
    export "${var_name}=${var_value}"
  else
    echo ".env file not found. Exiting..."
    exit 1
  fi

  if [ -f "$SCRIPT_DIR/../.env.local" ]; then
    local var_value=$(grep -v '^#' "$SCRIPT_DIR/../.env.local" | grep -E "^${var_name}=" | cut -d '=' -f2-)
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