#!/bin/bash

# TODO - não está detectando o profile coerretamente

# Function to detect the shell profile being used
detect_profile() {
  if [ -n "$ZSH_VERSION" ]; then
    echo "$HOME/.zshrc"
  elif [ -n "$BASH_VERSION" ]; then
    echo "$HOME/.bashrc"
  elif [ -n "$FISH_VERSION" ]; then
    echo "$HOME/.config/fish/config.fish"
  else
    echo "unknown"
  fi
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  profile=$(detect_profile)
  echo "Detected shell profile: $profile"
fi