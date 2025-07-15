#!/bin/bash

# Configurações
VM_HOST="localhost"
VM_PORT="2222"
VM_USER="ubuntu"  # Substitua pelo seu nome de usuário na VM
VM_PASSWORD="password"  # Opcional: use chaves SSH em vez de senha para maior segurança
DESTINATION_PATH="/home/$VM_USER/"  # Caminho de destino na VM

# Verifica se um arquivo foi fornecido como argumento
if [ $# -lt 1 ]; then
    echo "Uso: $0 arquivo_para_transferir [caminho_destino_opcional]"
    exit 1
fi

SOURCE_FILE="$1"

# Verifica se o arquivo existe
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Erro: Arquivo '$SOURCE_FILE' não encontrado."
    exit 1
fi

# Se um caminho de destino foi fornecido, use-o
if [ $# -ge 2 ]; then
    DESTINATION_PATH="$2"
fi

# Verifica se a VM está acessível
echo "Verificando conexão com a VM..."
ssh -p $VM_PORT -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $VM_USER@$VM_HOST exit &>/dev/null
if [ $? -ne 0 ]; then
    echo "Erro: Não foi possível conectar à VM. Verifique se ela está ligada e se as configurações de rede estão corretas."
    exit 1
fi

# Transfere o arquivo
echo "Transferindo '$SOURCE_FILE' para a VM..."
scp -P $VM_PORT -o StrictHostKeyChecking=no "$SOURCE_FILE" $VM_USER@$VM_HOST:$DESTINATION_PATH

# Verifica se a transferência foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "Transferência concluída com sucesso!"
    echo "Arquivo disponível em: $DESTINATION_PATH$(basename "$SOURCE_FILE")"
else
    echo "Erro durante a transferência do arquivo."
    exit 1
fi