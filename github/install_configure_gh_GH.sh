#!/bin/bash

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
    # Dar source no perfil para aplicar as mudanças
    source "$profile_file"
    echo "Perfil $profile_file recarregado."
  else
    echo "Arquivo de perfil $profile_file não encontrado."
  fi
else
  # Perguntar ao usuário qual shell está usando se a variável GITHUB_TOKEN não estiver definida
  echo "Qual shell você está usando? (Digite o número correspondente)"
  echo "1) bash"
  echo "2) zsh"
  read -p "Escolha uma opção (1 ou 2): " shell_choice

  # Definir o arquivo de perfil com base na escolha do usuário
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
fi

# Verificar se existe um Personal Access Token (PAT) e se está expirado
echo "Verificando Personal Access Tokens (classic)..."
tokens=$(gh auth token list --json name,token,expiresAt)

if [ -z "$tokens" ]; then
  echo "Nenhum Personal Access Token (classic) encontrado. Gerando um novo token..."
  gh auth refresh -h github.com -s repo,workflow
  new_token=$(gh auth token)
  new_token_name="Generated Token"
  echo "Novo token gerado: $new_token (Nome: $new_token_name)"
else
  expired_token=$(echo "$tokens" | jq -r '.[] | select(.expiresAt != null and .expiresAt < now) | .token')
  if [ -n "$expired_token" ]; then
    echo "Token expirado encontrado. Gerando um novo token..."
    gh auth refresh -h github.com -s repo,workflow
    new_token=$(gh auth token)
    new_token_name="Generated Token"
    echo "Novo token gerado: $new_token (Nome: $new_token_name)"
  else
    valid_token=$(echo "$tokens" | jq -r '.[] | select(.expiresAt == null or .expiresAt >= now) | .token')
    valid_token_name=$(echo "$tokens" | jq -r '.[] | select(.expiresAt == null or .expiresAt >= now) | .name')
    echo "Token válido encontrado: $valid_token (Nome: $valid_token_name)"
    new_token=$valid_token
    new_token_name=$valid_token_name
  fi
fi

# Armazenar o token no perfil escolhido pelo usuário
if [ -n "$new_token" ]; then
  echo "Armazenando o token no perfil $profile_file..."
  echo "export GITHUB_TOKEN=$new_token" >> "$profile_file"
  source "$profile_file"
  echo "Perfil $profile_file recarregado."
fi

# Autenticar no GitHub CLI
echo "Autenticando no GitHub CLI..."
gh auth login

# TODO: token gerado não parece no site do GitHub - https://github.com/settings/tokens
echo "Instalação e configuração do GitHub CLI concluídas!"
echo "Token armazenado no perfil: $GITHUB_TOKEN (Nome: $new_token_name)"
echo "Você pode visualizar e gerenciar seus tokens em: https://github.com/settings/tokens"