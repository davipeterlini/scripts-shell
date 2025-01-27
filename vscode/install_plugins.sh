#!/bin/bash

# Function to install a VSCode extension
install_extension() {
    local extension=$1
    code --install-extension "$extension" --force
}

# List of extensions to install
extensions=(
    "rangav.vscode-thunder-client"
    "ms-azuretools.vscode-docker"
    "mikestead.dotenv"
    "gerane.Theme-Dracula"
    "mervin.markdown-formatter"
    "MS-CEINTL.vscode-language-pack-pt-BR"
    "alphabotsec.vscode-eclipse-keybindings"
    "moshfeu.compare-folders"
    "Gruntfuggly.todo-tree"
    "naumovs.color-highlight"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "Noctarya.typescript-web-development-extension-pack"
    "vitest.explorer"
    "Orta.vscode-jest"
    "firsttris.vscode-jest-runner"
    "ms-playwright.playwright"
    "GitHub.copilot"
    "GitHub.copilot-labs"
    "prompt-flow.prompt-flow"
    "cit-flow-coder-assistant.cit-flow-coder-assistant"
    "PrismaCloud.prisma-cloud"
)

# Install each extension
for extension in "${extensions[@]}"; do
    echo "Installing $extension..."
    install_extension "$extension"
done

echo "All extensions installed successfully."