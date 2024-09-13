#!/bin/bash
# TODO: verificar se serve para MAC e para Linux e colocar nas pastas adequadas e na sequência chamar no script de instalação

# Atualizar Homebrew
echo "Atualizando Homebrew..."
brew update

# Instalar GitHub CLI
echo "Instalando GitHub CLI..."
brew install gh

# Verificar se a variável GITHUB_TOKEN está definida
if [ -n "$GITHUB_TOKEN" ]; then
  echo "A variável GITHUB_TOKEN está definida. Removendo..."

  # Desfazer a definição da variável GITHUB_TOKEN na sessão atual
  unset GITHUB_TOKEN
  echo "Variável GITHUB_TOKEN removida da sessão atual."

  # Perguntar ao usuário qual shell está usando
  echo "Qual shell você está usando? (Digite o número correspondente)"
  echo "1) bash"
  echo "2) zsh"
  read -p "Escolha uma opção (1 ou 2): " shell_choice

  # Remover a definição da variável GITHUB_TOKEN do perfil local
  case $shell_choice in
    1)
      profile_file="$HOME/.bashrc"
      ;;
    2)
      profile_file="$HOME/.zshrc"
      ;;
    *)
      echo "Opção inválida. Saindo..."
      exit 1
      ;;
  esac

  if [ -f "$profile_file" ]; then
    sed -i.bak '/export GITHUB_TOKEN/d' "$profile_file"
    echo "Variável GITHUB_TOKEN removida de $profile_file."
  else
    echo "Arquivo de perfil $profile_file não encontrado."
  fi
fi

# Autenticar no GitHub CLI
echo "Autenticando no GitHub CLI..."
gh auth login

echo "Instalação e configuração do GitHub CLI concluídas!"