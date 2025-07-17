#!/bin/bash

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/save_vscode_settings.sh"

install_vscode_extensions() {
    print_info "Installing VSCode extensions..."

    for extension in "${VSCODE_EXTENSIONS[@]}"; do
        print_info "Installing extension: $extension"
        code --install-extension "$extension"
    done

    print_success "VSCode extensions installed successfully."
}

# Run the function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_vscode_extensions
fi