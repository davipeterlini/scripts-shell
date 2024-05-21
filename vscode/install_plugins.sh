#!/bin/bash

# List of Visual Studio Code extensions to install
declare -a extensions=(
    "GitHub.copilot"
    "ms-azuretools.vscode-docker"
    "Dart-Code.flutter"
    "golang.Go"
    "ms-vscode.makefile-tools"
    "redhat.java"
    "rangav.vscode-thunder-client"
    "cschleiden.vscode-github-actions"
    "mikestead.dotenv"
    "vscjava.vscode-java-pack"  # Assume this is for Java support including the Eclipse Keymap
)

# Function to install a VSCode extension if it's not already installed
install_extension() {
    local extension="$1"
    # Check if the VSCode extension is already installed
    if code --list-extensions | grep -q "^${extension}\$"; then
        echo "Extension $extension is already installed."
    else
        echo "Installing extension $extension..."
        code --install-extension $extension
    fi
}

echo "Starting VSCode extensions installation..."

# Loop through the extensions and install them
for extension in "${extensions[@]}"; do
    install_extension $extension
done

echo "VSCode extensions installation completed."


#- [x]  ext install esbenp.prettier-vscode
#- [x]  npm install -g eslint
#- [x]  .eslintrc
#- [x]  `[npx eslint --init](http://eslint.org/docs/user-guide/command-line-interface)`.