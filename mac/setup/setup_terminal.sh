#!/bin/zsh

# Config Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
    echo "Oh My Zsh aready install"
fi

# Create a New Profile and set default
# TODO - the line below is not work beacause this command not suported in iTerm2
#osascript iterm/create_profile.scpt
#echo "Note: Create profile and set as default of this iTerm2 must be done manually."

# Download Themas
#curl -o ~/Downloads/material-design-colors.itermcolors https://raw.githubusercontent.com/MartinSeeler/iterm2-material-design/master/material-design-colors.itermcolors
#curl -o ~/Downloads/solarized.itermcolors https://raw.githubusercontent.com/altercation/solarized/master/iterm2-colors-solarized/Solarized%20Dark.itermcolors
#echo "Note: The import of this iTerm2 theme must be done manually."

# Clona e instala as fontes Powerline
#git clone https://github.com/powerline/fonts.git && cd fonts && ./install.sh
#echo "Note: After installation, you need to manually set the font in iTerm2 to 'Meslo LG L for Powerline'."

# Modify the .zshrc file to use the 'agnoster' theme
sed -i '' 's/ZSH_THEME="robbyrussell"/# ZSH_THEME="robbyrussell"\nZSH_THEME="agnoster"/' ~/.zshrc

# Add the code snippet below the line 'ZSH_THEME="agnoster"' in the .zshrc file
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