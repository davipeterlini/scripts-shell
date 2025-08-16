#!/bin/bash

# Script to set up the terminal environment for Mac
# Using shared terminal utilities

# Get absolute directory of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source required utilities
source "${PROJECT_ROOT}/utils/colors_message.sh"
source "${PROJECT_ROOT}/utils/bash_tools.sh"
source "${PROJECT_ROOT}/utils/terminal_utils.sh"

# Mac-specific terminal setup function
configure_iterm2() {
    if [ -d "/Applications/iTerm.app" ]; then
        print_info "Configuring iTerm2 to use zsh..."
        # Create or update iTerm2 preferences
        defaults write com.googlecode.iterm2 DefaultBookmark -string "zsh"
        defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "zsh"
        
        # Set the default command for new sessions
        /usr/libexec/PlistBuddy -c "Set :New\ Bookmarks:0:Command /bin/zsh" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null || true
        
        print_success "iTerm2 configured to use zsh"
    else
        print_alert "iTerm2 not found. Skipping iTerm2 configuration."
    fi
    
    return 0
}

# Function to add custom prompt to .zshrc
add_custom_prompt() {
    print_header_info "Adding custom prompt to .zshrc..."
    
    # Path to the .zshrc.example file
    local zshrc_example_path=""
    
    # Check if the .zshrc.example file exists in different locations
    if [ -f "${PROJECT_ROOT}/assets/.zshrc.example" ]; then
        zshrc_example_path="${PROJECT_ROOT}/assets/.zshrc.example"
    fi
    
    if [ -n "$zshrc_example_path" ]; then
        print_info "Found .zshrc.example at $zshrc_example_path"
        
        # Read the content of the .zshrc.example file
        local zshrc_content=$(cat "$zshrc_example_path")
        
        # Use profile_writer to add the content to .zshrc
        write_to_profile "$zshrc_content" "$HOME/.zshrc"
        
        print_success "Custom prompt configuration applied to .zshrc"
    else
        print_error "Could not find .zshrc.example file in any of the expected locations"
        return 1
    fi
    
    return 0
}

# Mac-specific setup_terminal wrapper
setup_terminal_mac() {
    # Call the shared setup_terminal function with 'mac' platform
    setup_terminal "mac" "agnoster"
    
    # Add Mac-specific configurations
    add_custom_prompt
    
    return 0
}

# Run the script only if not being imported
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_terminal_mac "$@"
fi