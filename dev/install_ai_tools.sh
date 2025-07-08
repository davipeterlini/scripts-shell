#!/bin/bash

# Script para instalação e teste de ferramentas de IA
# - Claude Code
# - OpenAI Codex
# - Google Gemini CLI

echo "=== Iniciando instalação das ferramentas de IA ==="

# Verificar se o Node.js e npm estão instalados
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    echo "Node.js ou npm não encontrados. Por favor, instale-os primeiro."
    echo "Você pode instalá-los com: sudo apt install nodejs npm (Ubuntu/Debian)"
    exit 1
fi

# Função para verificar se a instalação foi bem-sucedida
check_installation() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 instalado com sucesso!"
    else
        echo "❌ Falha ao instalar $1. Verifique os erros acima."
        exit 1
    fi
}

# Instalação do Claude Code
echo -e "\n=== Instalando Claude Code ==="
npm install -g @anthropic-ai/claude-code
check_installation "Claude Code"

# Instalação do OpenAI Codex
echo -e "\n=== Instalando OpenAI Codex ==="
npm install -g @openai/codex
check_installation "OpenAI Codex"

# Instalação do Google Gemini CLI
echo -e "\n=== Instalando Google Gemini CLI ==="
npm install -g @google/gemini-cli
check_installation "Google Gemini CLI"

# Configuração das chaves de API
echo -e "\n=== Configuração das chaves de API ==="
echo "Por favor, forneça suas chaves de API:"

echo -n "OpenAI API Key (deixe em branco para pular): "
read openai_key
if [ ! -z "$openai_key" ]; then
    echo "export OPENAI_API_KEY=\"$openai_key\"" >> ~/.bashrc
    export OPENAI_API_KEY="$openai_key"
    echo "✅ Chave da OpenAI configurada"
else
    echo "⚠️ Chave da OpenAI não configurada. Configure manualmente com: export OPENAI_API_KEY=\"your-api-key-here\""
fi

echo -n "Gemini API Key (deixe em branco para pular): "
read gemini_key
if [ ! -z "$gemini_key" ]; then
    echo "export GEMINI_API_KEY=\"$gemini_key\"" >> ~/.bashrc
    export GEMINI_API_KEY="$gemini_key"
    echo "✅ Chave do Gemini configurada"
else
    echo "⚠️ Chave do Gemini não configurada. Configure manualmente com: export GEMINI_API_KEY=\"your-api-key-here\""
fi

# Recarregar o .bashrc para aplicar as variáveis de ambiente
source ~/.bashrc

# Teste das ferramentas
echo -e "\n=== Testando as ferramentas instaladas ==="

echo -e "\n--- Testando Claude Code ---"
if command -v claude &> /dev/null; then
    echo "O comando 'claude' está disponível."
    echo "Para usar o Claude Code, execute: claude <comando>"
else
    echo "❌ O comando 'claude' não está disponível. Verifique a instalação."
fi

echo -e "\n--- Testando OpenAI Codex ---"
if command -v codex &> /dev/null; then
    echo "O comando 'codex' está disponível."
    echo "Para usar o OpenAI Codex, execute: codex <comando>"
else
    echo "❌ O comando 'codex' não está disponível. Verifique a instalação."
fi

echo -e "\n--- Testando Google Gemini CLI ---"
if command -v gemini &> /dev/null; then
    echo "O comando 'gemini' está disponível."
    echo "Para usar o Google Gemini CLI, execute: gemini <comando>"
else
    echo "❌ O comando 'gemini' não está disponível. Verifique a instalação."
fi

echo -e "\n=== Instalação concluída ==="
echo "Lembre-se de configurar suas chaves de API se ainda não o fez."
echo "Você pode precisar reiniciar seu terminal para que todas as alterações tenham efeito."