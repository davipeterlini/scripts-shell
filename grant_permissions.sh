#!/bin/bash

# Set the root directory to the location of this execution script
DIRECTORY=$(dirname "$0")

# Echo the base directory to confirm where permissions will be applied
echo "Granting execute permissions to shell scripts from the root directory: $DIRECTORY"

# Find and grant execution permission for all shell script files (*.sh) in subdirectories
find "$DIRECTORY" -type f -name "*.sh" -exec echo "Granting execute permission to: {}" \; -exec chmod +x {} \;

# Grant execute permission to the pre-commit hook
# if [ -f "$DIRECTORY/.git/hooks/pre-commit" ]; then
#     echo "Granting execute permission to pre-commit hook"
#     chmod +x "$DIRECTORY/.git/hooks/pre-commit"
# fi

# Notify completion
echo "Permissions granted for all shell scripts under the root directory."