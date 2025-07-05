#!/bin/bash

# Load color utilities
source "$(dirname "$0")/../utils/colors_message.sh"

# Function to check if Homebrew is installed
check_homebrew() {
  if ! command -v brew &> /dev/null; then
    print_error "Homebrew não está instalado. Instalando Homebrew primeiro..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [ $? -ne 0 ]; then
      print_error "Falha ao instalar o Homebrew. Por favor, instale manualmente e tente novamente."
      return 1
    fi
    
    # Adicionar Homebrew ao PATH se necessário
    if [[ $(uname -m) == "arm64" ]]; then
      # Para Apple Silicon (M1/M2)
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    print_success "Homebrew instalado com sucesso!"
  else
    print_info "Homebrew já está instalado."
  fi
  
  return 0
}

# Function to check if AltTab is already installed
check_alttab_installed() {
  if brew list --cask alttab &> /dev/null; then
    print_info "AltTab já está instalado."
    return 0
  else
    return 1
  fi
}

# Function to install AltTab
install_alttab() {
  print_info "Instalando AltTab..."
  brew install --cask alttab
  
  if [ $? -ne 0 ]; then
    print_error "Falha ao instalar o AltTab."
    return 1
  fi
  
  print_success "AltTab instalado com sucesso!"
  
  # Fornecer instruções de uso
  print_info "Para configurar o AltTab:"
  print_info "1. Abra o aplicativo AltTab"
  print_info "2. Escolha seu estilo preferido (Windows ou macOS)"
  print_info "3. Personalize os atalhos de teclado nas configurações"
  print_info "4. Por padrão, use Option+Tab para alternar entre janelas"
  
  return 0
}

# Function to update AltTab if already installed
update_alttab() {
  print_info "Atualizando AltTab para a versão mais recente..."
  brew upgrade --cask alttab
  
  if [ $? -ne 0 ]; then
    print_error "Falha ao atualizar o AltTab."
    return 1
  fi
  
  print_success "AltTab atualizado com sucesso!"
  return 0
}

# Main function
main() {
  # Verificar se estamos no macOS
  if [[ "$(uname)" != "Darwin" ]]; then
    print_error "Este script é apenas para macOS. Sistema operacional detectado: $(uname)"
    return 1
  fi
  
  print_header "Instalador do AltTab para macOS"
  
  # Verificar e instalar Homebrew se necessário
  check_homebrew
  if [ $? -ne 0 ]; then
    return 1
  fi
  
  # Atualizar Homebrew
  print_info "Atualizando Homebrew..."
  brew update
  
  # Verificar se AltTab já está instalado
  if check_alttab_installed; then
    # Perguntar se o usuário deseja atualizar
    read -p "AltTab já está instalado. Deseja atualizá-lo? (s/n): " choice
    if [[ "$choice" =~ ^[Ss]$ ]]; then
      update_alttab
    else
      print_info "Nenhuma ação realizada. AltTab permanece na versão atual."
    fi
  else
    # Instalar AltTab
    install_alttab
  fi
  
  return 0
}

# Execute main function only if the script is being run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi