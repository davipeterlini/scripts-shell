#!/bin/bash

# Load environment variables
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/../../utils/load_env.sh"
load_env

# Function to update cask applications if a newer version is available
update_cask_if_newer_version_available() {
  local app_name="$1"
  local cask_name="$2"
  echo "Checking for updates for $app_name..."
  brew outdated --cask "$cask_name" && brew upgrade --cask "$cask_name"
}

# Function to update applications if a newer version is available
update_if_newer_version_available() {
  local app_name="$1"
  local formula_name="$2"
  echo "Checking for updates for $app_name..."
  brew outdated "$formula_name" && brew upgrade "$formula_name"
}

# Update applications listed in the environment variable
IFS=',' read -ra APPS <<< "$APPS_TO_UPDATE_MAC"
for app in "${APPS[@]}"; do
  IFS=':' read -ra APP_DETAILS <<< "$app"
  if [ "${APP_DETAILS[0]}" == "cask" ]; then
    update_cask_if_newer_version_available "${APP_DETAILS[1]}" "${APP_DETAILS[2]}"
  else
    update_if_newer_version_available "${APP_DETAILS[1]}" "${APP_DETAILS[2]}"
  fi
done