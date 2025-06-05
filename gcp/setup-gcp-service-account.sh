#!/bin/bash

# Script para configurar Service Account no GCP
# Usage: ./setup-gcp-service-account.sh [PROJECT_ID] [SERVICE_ACCOUNT_NAME]
# Se não fornecer parâmetros, o script irá guiá-lo através do processo

# Função para fazer login
login_gcp() {
    echo "🔐 Fazendo login no GCP..."
    echo "Abrindo navegador para autenticação..."
    
    if ! gcloud auth login; then
        echo "❌ Erro no login. Verifique sua conexão e tente novamente."
        exit 1
    fi
    
    echo "✅ Login realizado com sucesso!"
    echo ""
}

# Função para listar e selecionar projeto
select_project() {
    echo "📋 Listando projetos disponíveis..."
    echo ""
    
    # Armazenar a lista de projetos em variáveis
    PROJECT_IDS=($(gcloud projects list --format="value(projectId)"))
    PROJECT_NAMES=($(gcloud projects list --format="value(name)"))
    PROJECT_NUMBERS=($(gcloud projects list --format="value(projectNumber)"))
    
    # Exibir projetos com numeração
    echo "Nº | PROJECT_ID | NAME | NUMBER"
    echo "---|-----------|------|-------"
    for i in "${!PROJECT_IDS[@]}"; do
        printf "%2d | %s | %s | %s\n" $((i+1)) "${PROJECT_IDS[$i]}" "${PROJECT_NAMES[$i]}" "${PROJECT_NUMBERS[$i]}"
    done
    
    echo ""
    echo "Digite o número do projeto que deseja usar:"
    read -r PROJECT_NUM
    
    # Validar entrada
    if ! [[ "$PROJECT_NUM" =~ ^[0-9]+$ ]]; then
        echo "❌ Por favor, digite um número válido"
        exit 1
    fi
    
    if [ "$PROJECT_NUM" -lt 1 ] || [ "$PROJECT_NUM" -gt "${#PROJECT_IDS[@]}" ]; then
        echo "❌ Número fora do intervalo válido"
        exit 1
    fi
    
    # Ajustar índice (arrays começam em 0)
    PROJECT_INDEX=$((PROJECT_NUM-1))
    PROJECT_ID="${PROJECT_IDS[$PROJECT_INDEX]}"
    
    echo "✅ Projeto selecionado: $PROJECT_ID"
    echo ""
}

# Função para definir nome da service account
get_service_account_name() {
    echo "Digite o nome para a Service Account (ex: bucket-access-sa):"
    read -r SA_NAME
    
    if [ -z "$SA_NAME" ]; then
        echo "❌ Nome da Service Account não pode estar vazio"
        exit 1
    fi
    
    echo "✅ Service Account: $SA_NAME"
    echo ""
}

# Verificar se gcloud está instalado
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI não está instalado"
    echo "Instale o Google Cloud CLI: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Se não foram fornecidos parâmetros, executar modo interativo
if [ $# -eq 0 ]; then
    echo "🚀 Setup interativo do GCP Service Account"
    echo "=========================================="
    echo ""
    
    # Verificar se já está logado
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
        login_gcp
    else
        CURRENT_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
        echo "✅ Já logado como: $CURRENT_ACCOUNT"
        echo ""
        echo "Deseja fazer login com outra conta? (y/N):"
        read -r RELOGIN
        if [[ "$RELOGIN" =~ ^[Yy]$ ]]; then
            login_gcp
        fi
    fi
    
    select_project
    get_service_account_name
elif [ $# -eq 2 ]; then
    PROJECT_ID=$1
    SA_NAME=$2
    echo "🚀 Configurando Service Account com parâmetros fornecidos"
    echo "=========================================================="
else
    echo "Usage: $0 [PROJECT_ID] [SERVICE_ACCOUNT_NAME]"
    echo "   ou: $0 (modo interativo)"
    echo ""
    echo "Exemplos:"
    echo "  $0                                    # Modo interativo"
    echo "  $0 meu-projeto-123 bucket-access-sa  # Com parâmetros"
    exit 1
fi

echo ""
echo "🚀 Configurando Service Account para o projeto: $PROJECT_ID"
echo "Service Account: $SA_NAME"
echo ""

# Configurar projeto antes de criar service account
echo "🔧 Configurando projeto padrão..."
gcloud config set project $PROJECT_ID

# Verificar se a Service Account já existe
if gcloud iam service-accounts describe "$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" &>/dev/null; then
    echo "⚠️  Service Account '$SA_NAME' já existe. Deseja continuar? (y/N):"
    read -r CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
        echo "❌ Operação cancelada"
        exit 1
    fi
    SKIP_CREATE=true
else
    SKIP_CREATE=false
fi

# 1. Criar Service Account (se não existir)
if [ "$SKIP_CREATE" = false ]; then
    echo "📝 Criando Service Account: $SA_NAME"
    if ! gcloud iam service-accounts create $SA_NAME \
        --project=$PROJECT_ID \
        --description="Service account para acesso ao bucket" \
        --display-name="$SA_NAME"; then
        echo "❌ Erro ao criar Service Account"
        exit 1
    fi
    echo "✅ Service Account criada com sucesso"
else
    echo "⏭️  Pulando criação da Service Account (já existe)"
fi

# 2. Perguntar se deseja atribuir permissões
echo "🔐 Deseja tentar atribuir permissões de Storage Admin? (y/N):"
read -r ASSIGN_PERMISSIONS
if [[ "$ASSIGN_PERMISSIONS" =~ ^[Yy]$ ]]; then
    echo "🔐 Atribuindo permissões de Storage Admin..."
    if ! gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/storage.admin"; then
        echo "❌ Erro ao atribuir permissões. Você pode não ter permissões suficientes."
        echo "⚠️  Você precisará solicitar a um administrador para atribuir manualmente a role 'roles/storage.admin'"
        echo "   à service account: $SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
    else
        echo "✅ Permissões atribuídas com sucesso"
    fi
else
    echo "⏭️  Pulando atribuição de permissões"
    echo "⚠️  Você precisará solicitar a um administrador para atribuir manualmente a role 'roles/storage.admin'"
    echo "   à service account: $SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
fi

# 3. Gerar chave JSON
echo "🔑 Gerando chave JSON..."
KEY_FILE="$HOME/$SA_NAME-$PROJECT_ID-key.json"

# Remover chave antiga se existir
if [ -f "$KEY_FILE" ]; then
    echo "⚠️  Chave existente encontrada. Sobrescrever? (y/N):"
    read -r OVERWRITE
    if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
        rm "$KEY_FILE"
    else
        echo "❌ Operação cancelada"
        exit 1
    fi
fi

if ! gcloud iam service-accounts keys create "$KEY_FILE" \
    --iam-account="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --project="$PROJECT_ID"; then
    echo "❌ Erro ao gerar chave JSON"
    exit 1
fi

# Definir permissões seguras para o arquivo
chmod 600 "$KEY_FILE"
echo "✅ Chave JSON criada e protegida"

# 4. Ativar Service Account
echo "✅ Ativando Service Account..."
if ! gcloud auth activate-service-account --key-file="$KEY_FILE"; then
    echo "❌ Erro ao ativar Service Account"
    exit 1
fi

# 5. Configurar projeto padrão (novamente para garantir)
gcloud config set project $PROJECT_ID

# 6. Configurar variável de ambiente
echo "🌍 Configurando variáveis de ambiente..."
export GOOGLE_APPLICATION_CREDENTIALS="$KEY_FILE"

# Adicionar ao .bashrc se não existir
BASHRC_ENTRY="export GOOGLE_APPLICATION_CREDENTIALS=\"$KEY_FILE\""
if [ -f ~/.bashrc ]; then
    if ! grep -Fq "$KEY_FILE" ~/.bashrc; then
        echo "$BASHRC_ENTRY" >> ~/.bashrc
        echo "📝 Adicionado ao ~/.bashrc"
    else
        echo "⏭️  Variável já existe no ~/.bashrc"
    fi
fi

# Adicionar ao .zshrc se existir
if [ -f ~/.zshrc ]; then
    if ! grep -Fq "$KEY_FILE" ~/.zshrc; then
        echo "$BASHRC_ENTRY" >> ~/.zshrc
        echo "📝 Adicionado ao ~/.zshrc"
    else
        echo "⏭️  Variável já existe no ~/.zshrc"
    fi
fi

echo ""
echo "🎉 Setup concluído com sucesso!"
echo "================================"
echo "📁 Chave salva em: $KEY_FILE"
echo "🔐 Service Account: $SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
echo "📊 Projeto ativo: $PROJECT_ID"
echo ""
echo "🔧 Para usar em novos terminais:"
echo "   source ~/.bashrc  (ou ~/.zshrc)"
echo ""
echo "📋 Comandos úteis:"
echo "   gcloud auth list                    # Ver contas ativas"
echo "   gsutil ls                          # Listar buckets"
echo "   gcloud config get-value project    # Ver projeto ativo"
echo ""
echo "🧪 Testando configuração atual..."
echo "─────────────────────────────────────"
echo "👤 Contas autenticadas:"
gcloud auth list
echo ""
echo "📊 Projeto ativo:"
gcloud config get-value project
echo ""
echo "🪣 Buckets disponíveis:"
if gsutil ls 2>/dev/null; then
    echo "✅ Acesso ao Storage funcionando!"
else
    echo "⚠️  Nenhum bucket encontrado ou permissões pendentes"
    echo "   Isso pode ser devido à falta de permissões. Solicite a um administrador para"
    echo "   atribuir a role 'roles/storage.admin' à service account."
fi
echo ""
echo "✅ Configuração finalizada!"