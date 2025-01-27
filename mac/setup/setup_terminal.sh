#!/bin/zsh

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "Oh My Zsh aready install"
fi
}

# Function to install Powerlevel10k theme
install_powerlevel10k() {
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sed -i '' 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
}

# Function to install recommended plugins
install_plugins() {
    echo "Installing recommended plugins..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i '' 's/plugins=(/plugins=(zsh-syntax-highlighting zsh-autosuggestions /' ~/.zshrc
}

# Function to add custom prompt to .zshrc
add_custom_prompt() {
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
    fi
}

# Function to change the theme to 'agnoster'
change_theme() {
    echo "Modifying the .zshrc file to use the 'agnoster' theme"
    if grep -q 'ZSH_THEME=' ~/.zshrc; then
        sed -i '' 's/ZSH_THEME=".*"/ZSH_THEME="agnoster"/' ~/.zshrc
    else
        echo 'ZSH_THEME="agnoster"' >> ~/.zshrc
    fi
}

# Main script execution
main() {
    install_oh_my_zsh
    install_powerlevel10k
    install_plugins
    add_custom_prompt
    change_theme
    echo "Terminal setup completed. Please restart your terminal."
    echo "Notes:"
    echo " - After installation, you need to manually set the font in your terminal to 'Meslo LG L for Powerline'."
    echo " - You may need to restart your terminal for all changes to take effect."
}

main