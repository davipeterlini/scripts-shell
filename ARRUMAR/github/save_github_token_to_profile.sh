#!/bin/bash

# Ensure PROFILE_FILE is set
if [ -z "$PROFILE_FILE" ]; then
  echo "Environment variable PROFILE_FILE is not set. Please run choose_shell_profile.sh first. Exiting..."
  exit 1
fi

# Ensure GITHUB_TOKEN_PERSONAL is set
if [ -z "$GITHUB_TOKEN_PERSONAL" ]; then
  echo "Environment variable GITHUB_TOKEN_PERSONAL is not set. Exiting..."
  exit 1
fi

# Function to save the GITHUB_TOKEN_PERSONAL to the chosen profile
save_github_token_to_profile() {
  if [ -f "$PROFILE_FILE" ]; then
    echo "Saving GITHUB_TOKEN_PERSONAL to $PROFILE_FILE..."
    echo "export GITHUB_TOKEN_PERSONAL=$GITHUB_TOKEN_PERSONAL" >> "$PROFILE_FILE"
    source "$PROFILE_FILE"
    echo "Profile $PROFILE_FILE reloaded."
  else
    echo "Profile file $PROFILE_FILE not found."
  fi
}

save_github_token_to_profile