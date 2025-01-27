#!/bin/bash

# Load environment variables and utility functions if not already loaded
if [ -z "$ENV_LOADED" ]; then
    source "$(dirname "$0")/utils/load_env.sh"
    load_env
    export ENV_LOADED=true
fi

# Function to set up VSCode configurations
setup_vscode_config() {
    local vscode_settings_dir="$HOME/.config/Code/User"
    local vscode_settings_file="$vscode_settings_dir/settings.json"
    local vscode_extensions_file="$vscode_settings_dir/extensions.json"

    # Create VSCode settings directory if it doesn't exist
    mkdir -p "$vscode_settings_dir"

    # Write VSCode settings
    cat > "$vscode_settings_file" <<EOL
{
    "files.autoSave": "onFocusChange",
    "terminal.integrated.persistentSessionReviveProcess": "onExit",
    "terminal.integrated.tabs.enabled": true,
    "terminal.integrated.tabs.location": "left",
    "terminal.integrated.splitCwd": "inherited",
    "terminal.integrated.cwd": "\${workspaceFolder}",
    "terminal.integrated.persistentSessionScrollback": true,
    "terminal.integrated.persistentSessionRestore": true
}
EOL

    # Write VSCode extensions recommendations
    cat > "$vscode_extensions_file" <<EOL
{
    "recommendations": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "styled-components.vscode-styled-components",
        "naumovs.color-highlight",
        "unifiedjs.vscode-mdx",
        "vitest.explorer",
        "rangav.vscode-thunder-client",
        "ms-azuretools.vscode-docker",
        "mikestead.dotenv",
        "gerane.Theme-Dracula",
        "mervin.markdown-formatter",
        "MS-CEINTL.vscode-language-pack-pt-BR",
        "alphabotsec.vscode-eclipse-keybindings",
        "moshfeu.compare-folders",
        "Gruntfuggly.todo-tree",
        "Noctarya.typescript-web-development-extension-pack",
        "Orta.vscode-jest",
        "firsttris.vscode-jest-runner",
        "ms-playwright.playwright",
        "GitHub.copilot",
        "GitHub.copilot-labs",
        "prompt-flow.prompt-flow",
        "cit-flow-coder-assistant.cit-flow-coder-assistant",
        "PrismaCloud.prisma-cloud"
    ]
}
EOL
}

# Main script execution
main() {
    echo "Setting up VSCode configurations..."
    setup_vscode_config

    echo "Installing VSCode extensions..."
    ./vscode/install_plugins.sh.sh

    echo "VSCode setup completed successfully."
}

main