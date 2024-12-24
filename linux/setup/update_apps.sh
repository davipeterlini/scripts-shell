#!/bin/bash

# Load environment variables
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/../utils/load_env.sh"
load_env

# Function to update applications if a newer version is available
update_if_newer_version_available() {
  local app_name="$1"
  local package_name="$2"
  echo "Checking for updates for $app_name..."
  sudo apt-get install --only-upgrade -y "$package_name"
}

# Update applications listed in the environment variable
IFS=',' read -ra APPS <<< "$APPS_TO_UPDATE_LINUX"
for app in "${APPS[@]}"; do
  IFS=':' read -ra APP_DETAILS <<< "$app"
  update_if_newer_version_available "${APP_DETAILS[1]}" "${APP_DETAILS[2]}"
done