#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors_message.sh"

# Function to detect the shell profile being used
detect_profile() {
  if [ -n "$ZSH_VERSION" ]; then
    print "$HOME/.zshrc"
  elif [ -n "$BASH_VERSION" ]; then
    print "$HOME/.bashrc"
  elif [ -n "$FISH_VERSION" ]; then
    print "$HOME/.config/fish/config.fish"
  else
    print "unknown"
  fi
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  profile=$(detect_profile)
  if [ "$profile" == "unknown" ]; then
    print_alert "Unable to detect shell profile."
  else
    print_success "Shell profile detected: $profile"
  fi
fi