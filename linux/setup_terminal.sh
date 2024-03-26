#!/bin/bash

# Instala o Oh My Zsh se não estiver instalado
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is not installed. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    # TODO - nao est[a instalando
else
    echo "Oh My Zsh is already installed."
fi

# Instala as fontes Powerline
echo "Installing Powerline Fonts..."
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
echo "Powerline Fonts installed.

# Altera o tema do Oh My Zsh para Agnoster
echo "Changing Oh My Zsh theme to Agnoster..."
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="agnoster"/' ~/.zshrc

# Instala dconf-cli e uuid-runtime para temas do gnome-terminal
echo "Installing dconf-cli and uuid-runtime for gnome-terminal themes..."
sudo apt-get install -y dconf-cli uuid-runtime

# Baixa e aplica um esquema de cores do Gogh para o gnome-terminal
echo "Applying Material Design color scheme using Gogh..."
bash -c  "$(wget -qO- https://git.io/vQgMr)"

echo "Setup completed. Please restart your terminal for the changes to take effect."
echo "Also, please manually set one of the Powerline fonts in your gnome-terminal profile preferences."
echo "After running Gogh script, select the number corresponding to the 'Material Design' theme to apply it."
