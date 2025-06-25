#!/bin/bash

# Script para criar um bucket no Google Cloud Storage com subpastas específicas
# Este script cria um bucket chamado "flow-coder" e as seguintes subpastas:
# - flow-coder-ide/vscode
# - flow-coder-ide/jetbrains
# - flow-coder-cli
# - flow-coder-mcp

# Importando funções de cores para mensagens
source "$(dirname "$0")/../utils/colors_message.sh"

# Definindo variáveis
BUCKET_NAME="flow_coder"
FOLDERS=(
  "flow_coder_ide/vscode/"
  "flow_coder_ide/jetbrains/"
  "flow_coder_cli/"
  "flow_coder_mcp/"
)

# Verificar se o gcloud está instalado
if ! command -v gcloud &> /dev/null; then
  print_error "Google Cloud SDK (gcloud) não está instalado."
  print_yellow "Por favor, instale o Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
  exit 1
fi

# Verificar se o usuário está autenticado no gcloud
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
  print_alert "Você precisa estar autenticado no Google Cloud para continuar."
  print_yellow "Executando autenticação..."
  gcloud auth login
fi

# Criar o bucket
print_header "Criando bucket '$BUCKET_NAME'..."
if gcloud storage buckets create gs://$BUCKET_NAME --location=us-central1; then
  print_success "Bucket '$BUCKET_NAME' criado com sucesso!"
else
  print_error "Erro ao criar o bucket '$BUCKET_NAME'. Verifique se o nome já está em uso ou se você tem permissões suficientes."
  exit 1
fi

# Criar as subpastas usando o comando correto
# No Google Cloud Storage, as "pastas" são simuladas criando objetos vazios com nomes terminados em "/"
for folder in "${FOLDERS[@]}"; do
  print_info "Criando pasta '$folder'..."

  # Criando um arquivo temporário vazio
  TEMP_FILE=$(mktemp)

  # Usando gsutil para criar as "pastas" (objetos vazios com nomes terminados em /)
  if gsutil cp $TEMP_FILE gs://$BUCKET_NAME/$folder; then
    print_success "Pasta '$folder' criada com sucesso!"
  else
    print_error "Erro ao criar a pasta '$folder'."
  fi

  # Removendo o arquivo temporário
  rm $TEMP_FILE
done

print_header "Processo concluído! Bucket '$BUCKET_NAME' criado com todas as subpastas necessárias."
print_yellow "Estrutura criada:"
print "gs://$BUCKET_NAME/"
for folder in "${FOLDERS[@]}"; do
  print "└── gs://$BUCKET_NAME/$folder"
done
