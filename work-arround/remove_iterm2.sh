#!/bin/bash

echo "🔍 Removing iTerm2 manually..."

# Detect architecture
if [[ $(uname -m) == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

# Remove main app
echo "📦 Removing /Applications/iTerm.app..."
sudo rm -rf /Applications/iTerm.app

# Remove user configuration files
echo "🧹 Removing user configuration files..."
rm -rf ~/Library/Preferences/com.googlecode.iterm2.plist
rm -rf ~/Library/Application\ Support/iTerm2
rm -rf ~/Library/Caches/com.googlecode.iterm2
rm -rf ~/Library/Saved\ Application\ State/com.googlecode.iterm2.savedState
rm -rf ~/Library/Logs/iTerm2

# Remove from Caskroom
CASKROOM_PATH="$BREW_PREFIX/Caskroom/iterm2"
if [ -d "$CASKROOM_PATH" ]; then
  echo "🧯 Removing Caskroom from $CASKROOM_PATH..."
  sudo rm -rf "$CASKROOM_PATH"
fi

# Remove symbolic link, if it exists
BIN_LINK="$BREW_PREFIX/bin/iterm2"
if [ -L "$BIN_LINK" ]; then
  echo "🔗 Removing symbolic link $BIN_LINK..."
  rm "$BIN_LINK"
fi

echo "✅ iTerm2 removed successfully."
