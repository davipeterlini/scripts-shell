Configure o gnome-terminal para facilitar o desenvolvimento 

Instale o Oh My Zsh ou faça o check para ver se o mesmo já existe 

Considere o uso da cor abaixo: 
curl -o ~/Downloads/material-design-colors.itermcolors https://raw.githubusercontent.com/MartinSeeler/iterm2-material-design/master/material-design-colors.itermcolors

Considere o uso da font abaixo: 
git clone https://github.com/powerline/fonts.git && cd fonts && ./install.sh

Considere trocar o tema do Oh My Zsh para o abaixo 
sed -i '' 's/ZSH_THEME="robbyrussell"/# ZSH_THEME="robbyrussell"\nZSH_THEME="agnoster"/' ~/.zshrc
