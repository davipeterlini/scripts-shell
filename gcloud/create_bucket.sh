#!/bin/bash

# Script para criar um bucket no Google Cloud Storage com subpastas específicas
# Este script cria um bucket chamado "flow-coder" e as seguintes subpastas:
# - flow-coder-ide/vscode
# - flow-coder-ide/jetbrains
# - flow-coder-cli
# - flow-coder-mcp

# Importando funções de cores para mensagens
source "$(dirname "$0")/../utils/colors_message.sh"

# Importando funções de instalação do gcloud e gsutil
source "$(dirname "$0")/install_gcloud_tools.sh"

# Definindo variáveis
BUCKET_NAME="flow_coder"
FOLDERS=(
  "flow_coder_ide/vscode/"
  "flow_coder_ide/jetbrains/"
  "flow_coder_cli/"
  "flow_coder_mcp/"
)

# Função para verificar se as ferramentas necessárias estão instaladas
check_required_tools() {
  print_header "Verificando ferramentas necessárias..."

  local tools_missing=false

  # Verificar se o gcloud está instalado
  if ! command -v gcloud &> /dev/null; then
    print_alert "Google Cloud SDK (gcloud) não está instalado."
    tools_missing=true
  fi

  # Verificar se o gsutil está instalado
  if ! command -v gsutil &> /dev/null; then
    print_alert "gsutil não está instalado."
    tools_missing=true
  fi

  # Se alguma ferramenta estiver faltando, instalar
  if [ "$tools_missing" = true ]; then
    print_yellow "Algumas ferramentas necessárias não estão instaladas."
    read -p "Deseja instalar as ferramentas faltantes agora? (s/n): " choice

    if [[ "$choice" =~ ^[Ss]$ ]]; then
      install_all_cloud_tools
    else
      print_error "As ferramentas necessárias não estão instaladas. Abortando."
      exit 1
    fi
  else
    print_success "Todas as ferramentas necessárias estão instaladas!"
  fi
}

# Função para autenticar no Google Cloud
authenticate_gcloud() {
  print_header "Verificando autenticação no Google Cloud..."

  # Verificar se o usuário está autenticado no gcloud
  if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    print_alert "Você precisa estar autenticado no Google Cloud para continuar."
    print_yellow "Executando autenticação..."
    gcloud auth login

    # Verificar se a autenticação foi bem-sucedida
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
      print_error "Falha na autenticação. Abortando."
      exit 1
    fi
  else
    local account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
    print_success "Autenticado como: $account"
  fi
}

# Função para criar o bucket
create_bucket() {
  print_header "Criando bucket '$BUCKET_NAME'..."

  if gcloud storage buckets create gs://$BUCKET_NAME --location=us-central1; then
    print_success "Bucket '$BUCKET_NAME' criado com sucesso!"
  else
    print_error "Erro ao criar o bucket '$BUCKET_NAME'. Verifique se o nome já está em uso ou se você tem permissões suficientes."
    exit 1
  fi
}

# Função para criar as subpastas no bucket
create_folders() {
  print_header "Criando estrutura de pastas..."

  # No Google Cloud Storage, as "pastas" são simuladas criando objetos vazios com nomes terminados em "/"
  for folder in "${FOLDERS[@]}"; do
    print_info "Criando pasta '$folder'..."

    # Criando um arquivo temporário vazio
    TEMP_FILE=$(mktemp)

    # Usando gcloud storage em vez de gsutil
    if gcloud storage cp $TEMP_FILE gs://$BUCKET_NAME/$folder; then
      print_success "Pasta '$folder' criada com sucesso!"
    else
      print_error "Erro ao criar a pasta '$folder'."
    fi

    # Removendo o arquivo temporário
    rm $TEMP_FILE
  done
}

# Função para exibir o resumo da operação
show_summary() {
  print_header "Processo concluído! Bucket '$BUCKET_NAME' criado com todas as subpastas necessárias."
  print_yellow "Estrutura criada:"
  print "gs://$BUCKET_NAME/"
  for folder in "${FOLDERS[@]}"; do
    print "└── gs://$BUCKET_NAME/$folder"
  done
}

# Função principal
main() {
  # Verificar ferramentas necessárias
  check_required_tools

  # Autenticar no Google Cloud
  authenticate_gcloud

  # Criar o bucket
  create_bucket

  # Criar as subpastas
  create_folders

  # Mostrar resumo
  show_summary
}

# Executar a função principal
main
