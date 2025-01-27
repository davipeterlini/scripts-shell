#!/bin/bash

# Function to detect the shell profile being used
detect_profile() {
  if [ -n "$ZSH_VERSION" ]; then
    echo "zsh"
  elif [ -n "$BASH_VERSION" ]; then
    echo "bash"
  else
    echo "unknown"
  fi
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  profile=$(detect_profile)
  echo "Detected shell profile: $profile"
fi