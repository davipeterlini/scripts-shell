#!/bin/bash

# Function to install a VSCode extension
install_extension() {
    local extension=$1
    code --install-extension "$extension" --force
}

# TODO - precisa pegar do .env
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
    "PrismaCloud.prisma-cloud"
    "unifiedjs.vscode-mdx"
    # CI&T
    "prompt-flow.prompt-flow"
    "cit-flow-coder-assistant.cit-flow-coder-assistant"
)

# Install each extension
install_vscode_extensions() {
    for extension in "${extensions[@]}"; do
        code --install-extension "$extension" || {
            echo "Failed to install extension: $extension"
        exit 1
        }
    done
}

# Main script execution
install_vscode_extensions