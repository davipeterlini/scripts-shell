#!/bin/bash

# Load color utilities
source "$(dirname "$0")/colors_message.sh"

# Configuration: Set the target directory
# Change TARGET_DIR to "repo" for the entire repository or "scripts" for the scripts folder only
TARGET_DIR="scripts" # Options: "repo" or "scripts"

# Determine the base directory based on the configuration
if [ "$TARGET_DIR" == "repo" ]; then
  BASE_DIR=$(git rev-parse --show-toplevel 2> /dev/null || echo "$(dirname "$(dirname "$0")")")
  print_info "Granting execute permissions to shell scripts in the entire repository: $BASE_DIR"
elif [ "$TARGET_DIR" == "scripts" ]; then
  BASE_DIR=$(dirname "$(dirname "$0")")
  print_info "Granting execute permissions to shell scripts in the scripts directory: $BASE_DIR"
else
  print_error "Invalid TARGET_DIR value. Use 'repo' or 'scripts'."
  exit 1
fi

# Find and grant execution permission for all shell script files (*.sh) in the target directory
find "$BASE_DIR" -type f -name "*.sh" | while read -r script; do
  print_alert "Granting execute permission to: $script"
  chmod +x "$script"
done

# Notify completion
print_success "Permissions granted for all shell scripts under the target directory: $BASE_DIR."
