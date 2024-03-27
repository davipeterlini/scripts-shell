#!/bin/bash

# Prompt the user to choose their shell profile: .bashrc or .zshrc
echo "Which profile do you use? Type 1 for .bashrc or 2 for .zshrc:"
read choice

# Initialize PROFILE_PATH variable
PROFILE_PATH=""
if [ "$choice" == "1" ]; then
    PROFILE_PATH="$HOME/.bashrc"
elif [ "$choice" == "2" ]; then
    PROFILE_PATH="$HOME/.zshrc"
else
    echo "Invalid choice."
    exit 1
fi

# Check if the 'tokens' file exists in the current directory
# Tokens file without in this repo because is not security
if [ ! -f "../tokens" ]; then
    echo "The 'tokens' file was not found."
    exit 1
fi

# Read each line from the 'tokens' file
while IFS= read -r line; do
    # Check if the line already exists in the profile file
    if grep -Fxq "$line" "$PROFILE_PATH"; then
        echo "Token already exists in $PROFILE_PATH: $line"
    else
        # Add the token to the profile file
        echo "Adding token to $PROFILE_PATH: $line"
        echo "$line" >> "$PROFILE_PATH"
    fi
done < tokens

source "$PROFILE_PATH"

# Final message
echo "Tokens have been successfully added to $PROFILE_PATH."
