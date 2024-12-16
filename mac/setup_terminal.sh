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

# Modifica o arquivo .zshrc para usar o tema 'agnoster'
sed -i '' 's/ZSH_THEME="robbyrussell"/# ZSH_THEME="robbyrussell"\nZSH_THEME="agnoster"/' ~/.zshrc

# Adiciona o trecho de código abaixo da linha 'ZSH_THEME="agnoster"' do arquivo .zshrc
cat << 'EOF' >> ~/.zshrc
autoload -Uz vcs_info
precmd() { vcs_info }

# Função para obter o nome da pasta raiz do repositório Git
function git_prompt_dir() {
    local dir
    dir=$(git rev-parse --show-toplevel 2> /dev/null)
    if [ $? -eq 0 ]; then
        local repo_name=$(basename "$dir")
        local relative_path=${PWD#$dir/}

        # Se estiver na raiz do repositório, não exibe o nome do repositório
        if [ -z "$relative_path" ]; then
            echo "→ "
        else
            # Caso contrário, exibe a pasta da raiz e a parte relevante do caminho
            local current_dir=$(basename "$relative_path")
            echo "%F{blue}${repo_name}%f → %F{red}${current_dir}%f → "
        fi
    else
        # Se não estiver em um repositório Git, exibe o caminho completo
        echo "$PWD"
    fi
}

# Função para obter apenas o nome da branch
function get_branch_name() {
    local branch_name
    branch_name=$(git symbolic-ref --short HEAD 2> /dev/null)
    echo "$branch_name"
}

# Definindo cores
RESET_COLOR="%f"  # Reseta a cor
BRANCH_COLOR_GREEN="%F{green}"  # Cor da branch se não houver alterações
BRANCH_COLOR_YELLOW="%F{yellow}"  # Cor da branch se houver alterações

# Função para determinar a cor da branch
function get_branch_color() {
    local git_status
    git_status=$(git status --porcelain 2> /dev/null)
    if [ -n "$git_status" ]; then
        echo "${BRANCH_COLOR_YELLOW}"  # Se houver alterações, amarelo
    else
        echo "${BRANCH_COLOR_GREEN}"  # Se não houver alterações, verde
    fi
}

PROMPT='$(git_prompt_dir)$(get_branch_color)$(get_branch_name)${RESET_COLOR} → '

plugins=(git)
EOF