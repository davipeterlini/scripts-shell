#!/bin/bash

echo "🔍 Removendo iTerm2 manualmente..."

# Detectar arquitetura
if [[ $(uname -m) == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

# Remover o app principal
echo "📦 Removendo /Applications/iTerm.app..."
sudo rm -rf /Applications/iTerm.app

# Remover arquivos de configuração do usuário
echo "🧹 Removendo arquivos de configuração do usuário..."
rm -rf ~/Library/Preferences/com.googlecode.iterm2.plist
rm -rf ~/Library/Application\ Support/iTerm2
rm -rf ~/Library/Caches/com.googlecode.iterm2
rm -rf ~/Library/Saved\ Application\ State/com.googlecode.iterm2.savedState
rm -rf ~/Library/Logs/iTerm2

# Remover do Caskroom
CASKROOM_PATH="$BREW_PREFIX/Caskroom/iterm2"
if [ -d "$CASKROOM_PATH" ]; then
  echo "🧯 Removendo Caskroom de $CASKROOM_PATH..."
  sudo rm -rf "$CASKROOM_PATH"
fi

# Remover link simbólico, se existir
BIN_LINK="$BREW_PREFIX/bin/iterm2"
if [ -L "$BIN_LINK" ]; then
  echo "🔗 Removendo link simbólico $BIN_LINK..."
  rm "$BIN_LINK"
fi

echo "✅ iTerm2 removido com sucesso."
