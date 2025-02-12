# Passo 1: Verifique versões instaladas
brew list | grep python

# Passo 2: Desinstale o Python
brew uninstall python@3.11
brew uninstall --force python

# Passo 3: Remova arquivos residuais
rm -rf /usr/local/lib/python3.*
rm -rf /usr/local/bin/python3
rm -rf /usr/local/bin/pip3
rm -rf ~/.local/lib/python3.*
rm -rf ~/Library/Python

# Passo 4: Limpe o cache do Homebrew
brew cleanup

# Passo 5: Verifique a remoção
python3 --version
which python3

# Passo 6: Reinstale o Python (opcional)
brew install python