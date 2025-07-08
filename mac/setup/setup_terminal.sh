#!/bin/zsh

source "$(dirname "$0")/mac/install_homebrew.sh"
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        print_info "Oh My Zsh already installed"
    fi
}

# Function to set zsh as default shell
set_zsh_as_default() {
    print_header_info "Setting zsh as default shell..."
    
    # Check if zsh is in the list of allowed shells
    if ! grep -q "$(which zsh)" /etc/shells; then
        print_info "Adding zsh to /etc/shells..."
        echo "$(which zsh)" | sudo tee -a /etc/shells
    fi
    
    # Change the default shell for the current user
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_info "Changing default shell to zsh..."
        #chsh -s "$(which zsh)"
        chsh -s /bin/zsh
    else
        print_success "zsh is already the default shell"
    fi
    
    # Configure iTerm2 to use zsh if it's installed
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
}

# Function to install Powerlevel10k theme
install_powerlevel10k() {
    print_header_info "Installing Powerlevel10k theme..."
    
    # Define the theme directory - explicitly use HOME
    local theme_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    
    # Check if the theme directory already exists
    if [ -d "$theme_dir" ]; then
        print_info "Powerlevel10k theme directory already exists"
        
        # Check if it's a git repository and update it
        if [ -d "$theme_dir/.git" ]; then
            print_info "Updating existing Powerlevel10k installation..."
            (cd "$theme_dir" && git pull)
        else
            print_alert "Directory exists but is not a git repository. Skipping installation."
        fi
    else
        # Clone the repository if it doesn't exist
        print_info "Cloning Powerlevel10k repository to $theme_dir"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
    fi
    
    # Update .zshrc to use the theme
    if grep -q 'ZSH_THEME=' ~/.zshrc; then
        sed -i '' 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    else
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc
    fi
    
    print_success "Powerlevel10k theme installed/updated successfully"
}

# Function to install recommended plugins
install_plugins() {
    print_header_info "Installing recommended plugins..."
    
    # Define plugin directories - explicitly use HOME
    local syntax_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    local autosuggestions_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    
    # Install zsh-syntax-highlighting if not already installed
    if [ ! -d "$syntax_dir" ]; then
        print_info "Installing zsh-syntax-highlighting to $syntax_dir"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$syntax_dir"
    else
        print_info "zsh-syntax-highlighting already installed"
        # Update if it's a git repository
        if [ -d "$syntax_dir/.git" ]; then
            print_info "Updating zsh-syntax-highlighting..."
            (cd "$syntax_dir" && git pull)
        fi
    fi
    
    # Install zsh-autosuggestions if not already installed
    if [ ! -d "$autosuggestions_dir" ]; then
        print_info "Installing zsh-autosuggestions to $autosuggestions_dir"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
    else
        print_info "zsh-autosuggestions already installed"
        # Update if it's a git repository
        if [ -d "$autosuggestions_dir/.git" ]; then
            print_info "Updating zsh-autosuggestions..."
            (cd "$autosuggestions_dir" && git pull)
        fi
    fi
    
    # Update plugins in .zshrc if not already added
    if ! grep -q "plugins=(.*zsh-syntax-highlighting.*zsh-autosuggestions.*)" ~/.zshrc; then
        sed -i '' 's/plugins=(/plugins=(zsh-syntax-highlighting zsh-autosuggestions /' ~/.zshrc
    fi
    
    print_success "Plugins installed successfully"
}

# Function to add custom prompt to .zshrc
add_custom_prompt() {
    print_header_info "Adding custom prompt to .zshrc..."
    if ! grep -q "autoload -Uz vcs_info" ~/.zshrc; then
        echo "" >> ~/.zshrc
        cat << 'EOF' >> ~/.zshrc
autoload -Uz vcs_info
precmd() { vcs_info }

# Function to get the root directory name of the Git repository
function git_prompt_dir() {
    local dir
    dir=$(git rev-parse --show-toplevel 2> /dev/null)
    if [ $? -eq 0 ]; then
        local repo_name=$(basename "$dir")
        local relative_path=${PWD#$dir/}

        # If in the root of the repository, do not display the repository name
        if [ -z "$relative_path" ]; then
            echo "→ "
        else
            # Otherwise, display the root folder and the relevant part of the path
            local current_dir=$(basename "$relative_path")
            echo "%F{blue}${repo_name}%f → %F{red}${current_dir}%f → "
        fi
    else
        # If not in a Git repository, display the full path
        echo "$PWD"
    fi
}

# Function to get only the branch name
function get_branch_name() {
    local branch_name
    branch_name=$(git symbolic-ref --short HEAD 2> /dev/null)
    echo "$branch_name"
}

# Define colors
RESET_COLOR="%f"  # Reset color
BRANCH_COLOR_GREEN="%F{green}"  # Branch color if no changes
BRANCH_COLOR_YELLOW="%F{yellow}"  # Branch color if there are changes

# Function to determine the branch color
function get_branch_color() {
    local git_status
    git_status=$(git status --porcelain 2> /dev/null)
    if [ -n "$git_status" ]; then
        echo "${BRANCH_COLOR_YELLOW}"  # If there are changes, yellow
    else
        echo "${BRANCH_COLOR_GREEN}"  # If no changes, green
    fi
}

PROMPT='$(git_prompt_dir)$(get_branch_color)$(get_branch_name)${RESET_COLOR} → '

plugins=(git)
EOF
        print_success "Custom prompt added to .zshrc"
    else
        print_info "Custom prompt already exists in .zshrc"
    fi
}

# Function to change the theme to 'agnoster'
change_theme() {
    print_header_info "Modifying the .zshrc file to use the 'agnoster' theme"
    if grep -q 'ZSH_THEME=' ~/.zshrc; then
        sed -i '' 's/ZSH_THEME=".*"/ZSH_THEME="agnoster"/' ~/.zshrc
        print_success "Theme changed to 'agnoster'"
    else
        echo 'ZSH_THEME="agnoster"' >> ~/.zshrc
        print_success "Theme 'agnoster' added to .zshrc"
    fi
}

# Main script execution
setup_terminal() {
    print_header_info "Terminal Setup"

    if ! confirm_action "Do you want Setup Iterm2 ?"; then
        print_info "Skipping configuration"
        return 0
    fi

    # Then proceed with other configurations
    install_oh_my_zsh
    set_zsh_as_default
    install_powerlevel10k
    install_plugins
    add_custom_prompt
    # Return the default theme
    change_theme
    
    print_header_info "Terminal setup completed. Please restart your terminal."
    print_info "Notes:"
    print_yellow " - After installation, you need to manually set the font in your terminal to 'Meslo LG L for Powerline'."
    print_yellow " - You may need to restart your terminal for all changes to take effect."
    print_success "Terminal setup completed successfully!"
}

# Executar o script apenas se não estiver sendo importado
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_terminal "$@"
fi