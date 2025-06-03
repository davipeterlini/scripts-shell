#!/bin/bash

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
    print_alert "Não foi possível detectar o profile do shell."
  else
    print_success "Profile do shell detectado: $profile"
  fi
fi