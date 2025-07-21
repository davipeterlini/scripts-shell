#!/bin/bash

# Script for installing and testing AI tools
# - Claude Code
# - OpenAI Codex
# - Google Gemini CLI

# Import color utilities for messages
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../" && pwd)"

# Utils
source "$ROOT_DIR/utils/colors_message.sh"
source "$ROOT_DIR/utils/profile_writer.sh"
source "$ROOT_DIR/utils/colors_message.sh"

# Constantes
CLAUDE_PACKAGE="@anthropic-ai/claude-code"
CODEX_PACKAGE="@openai/codex"
GEMINI_PACKAGE="@google/gemini-cli"

check_requirements() {
    print_info "Checking system requirements"
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js not found. Please install it first."
        print "You can install it with: sudo apt install nodejs (Ubuntu/Debian)"
        return 1
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm not found. Please install it first."
        print "You can install it with: sudo apt install npm (Ubuntu/Debian)"
        return 1
    fi
    
    print_success "All requirements satisfied"
    return 0
}

install_npm_package() {
    local package_name="$1"
    local display_name="$2"
    
    print_info "Installing $display_name"
    npm install -g "$package_name"
    
    if [ $? -eq 0 ]; then
        print_success "$display_name installed successfully!"
        return 0
    else
        print_error "Failed to install $display_name. Check the errors above."
        return 1
    fi
}

configure_api_keys() {
    print_header_info "API Key Configuration"
    print_info "Please provide your API keys:"
    
    # OpenAI API Key
    print_yellow "OpenAI API Key (leave blank to skip): "
    read openai_key
    if [ ! -z "$openai_key" ]; then
        write_exports_to_profile "OPENAI_API_KEY=\"$openai_key\""
        export OPENAI_API_KEY="$openai_key"
        print_success "OpenAI API key configured"
    else
        print_alert "OpenAI API key not configured. Configure manually with: export OPENAI_API_KEY=\"your-api-key-here\""
    fi
    
    # Gemini API Key
    print_yellow "Gemini API Key (leave blank to skip): "
    read gemini_key
    if [ ! -z "$gemini_key" ]; then
        write_exports_to_profile "GEMINI_API_KEY=\"$gemini_key\""
        export GEMINI_API_KEY="$gemini_key"
        print_success "Gemini API key configured"
    else
        print_alert "Gemini API key not configured. Configure manually with: export GEMINI_API_KEY=\"your-api-key-here\""
    fi
    
    # Reload .bashrc to apply environment variables
    source ~/.bashrc
}

test_command() {
    local command_name="$1"
    local display_name="$2"
    local usage_example="$3"
    
    print_info "Testing $display_name"
    if command -v "$command_name" &> /dev/null; then
        print_success "The '$command_name' command is available."
        print "To use $display_name, run: $usage_example"
        return 0
    else
        print_error "The '$command_name' command is not available. Check the installation."
        return 1
    fi
}

test_installed_tools() {
    print_header_info "Testing installed tools"
    
    local success=0
    
    test_command "claude" "Claude Code" "claude <command>" || ((success++))
    test_command "codex" "OpenAI Codex" "codex <command>" || ((success++))
    test_command "gemini" "Google Gemini CLI" "gemini <command>" || ((success++))
    
    return $success
}

install_ai_tools() {
    print_header_info "AI Tools Installation"
    print_info "Starting installation of AI development tools"

    if ! get_user_confirmation "Do you want Setting up global environment ?"; then
        print_info "Skipping configuration"
        return 0
    fi
    
    check_requirements || exit 1
    
    install_npm_package "$CLAUDE_PACKAGE" "Claude Code" || exit 1
    install_npm_package "$CODEX_PACKAGE" "OpenAI Codex" || exit 1
    install_npm_package "$GEMINI_PACKAGE" "Google Gemini CLI" || exit 1
    
    configure_api_keys
    
    test_installed_tools
    local test_result=$?
    
    print_header "Installation Complete"
    
    if [ $test_result -eq 0 ]; then
        print_success "All tools were installed and are available."
    else
        print_alert "Some tools may not be available. Check the messages above."
    fi
    
    print_info "Remember to configure your API keys if you haven't done so yet."
    print_alert "You may need to restart your terminal for all changes to take effect."
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_ai_tools "$@"
fi