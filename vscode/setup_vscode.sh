#!/bin/bash

# Load environment variables and utility functions if not already loaded
if [ -z "$ENV_LOADED" ]; then
source "$(dirname "$0")/../utils/load_env.sh"
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
    "terminal.integrated.persistentSessionRestore": true,
    "terminal.integrated.enablePersistentSessions": true
}
EOL

# TODO - precisa arrumar isso para pegar da forma correta
    # Write VSCode extensions recommendations
vscode_extensions_file=".vscode/extensions.json"
    cat > "$vscode_extensions_file" <<EOL
{
    "recommendations": [
        $(echo $VSCODE_EXTENSIONS | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')
    ]
}
EOL
}

# Main script execution
main() {
    echo "Setting up VSCode configurations..."
    setup_vscode_config

    echo "Installing VSCode extensions..."
    ./vscode/install_vscode_plugins.sh

    echo "VSCode setup completed successfully."
}

main