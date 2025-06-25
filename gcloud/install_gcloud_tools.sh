#!/bin/bash

# Script para instalação do Google Cloud SDK (gcloud) e gsutil
# Este script fornece funções para verificar e instalar as ferramentas do Google Cloud

# Importando funções de cores para mensagens
source "$(dirname "$0")/../utils/colors_message.sh"

# Função para instalar o Google Cloud SDK (gcloud)
install_gcloud() {
  print_header "Instalando Google Cloud SDK (gcloud)..."
  
  # Verificar o sistema operacional
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    print_info "Detectado sistema Linux. Instalando gcloud..."
    
    # Adicionar o repositório do Cloud SDK e instalar
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install -y google-cloud-sdk
    
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    print_info "Detectado sistema macOS. Instalando gcloud..."
    
    # Verificar se o Homebrew está instalado
    if ! command -v brew &> /dev/null; then
      print_alert "Homebrew não está instalado. Instalando Homebrew primeiro..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Instalar gcloud via Homebrew
    brew install --cask google-cloud-sdk
    
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    print_info "Detectado sistema Windows. Por favor, baixe e instale o Google Cloud SDK manualmente:"
    print_yellow "https://cloud.google.com/sdk/docs/install-sdk#windows"
    print_yellow "Após a instalação, reinicie este script."
    return 1
  else
    print_error "Sistema operacional não suportado: $OSTYPE"
    print_yellow "Por favor, instale o Google Cloud SDK manualmente: https://cloud.google.com/sdk/docs/install"
    return 1
  fi
  
  print_success "Google Cloud SDK (gcloud) instalado com sucesso!"
  return 0
}

# Função para instalar o gsutil
# Nota: gsutil geralmente é instalado como parte do Google Cloud SDK
install_gsutil() {
  print_header "Verificando instalação do gsutil..."
  
  # Verificar se o gcloud está instalado primeiro
  if ! command -v gcloud &> /dev/null; then
    print_alert "Google Cloud SDK (gcloud) não está instalado. O gsutil é parte do SDK."
    install_gcloud
  fi
  
  # Verificar se o gsutil está disponível
  if ! command -v gsutil &> /dev/null; then
    print_info "Instalando componentes adicionais do Google Cloud SDK..."
    gcloud components install gsutil
  else
    print_info "gsutil já está instalado."
  fi
  
  print_success "gsutil está pronto para uso!"
  return 0
}

# Função para verificar e instalar todas as ferramentas necessárias
install_all_cloud_tools() {
  print_header "Verificando e instalando ferramentas do Google Cloud..."
  
  # Instalar gcloud se necessário
  if ! command -v gcloud &> /dev/null; then
    install_gcloud
  else
    print_success "Google Cloud SDK (gcloud) já está instalado."
  fi
  
  # Instalar gsutil se necessário
  if ! command -v gsutil &> /dev/null; then
    install_gsutil
  else
    print_success "gsutil já está instalado."
  fi
  
  print_success "Todas as ferramentas do Google Cloud estão instaladas e prontas para uso!"
  return 0
}

# Se o script for executado diretamente (não importado como fonte)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_all_cloud_tools
fi