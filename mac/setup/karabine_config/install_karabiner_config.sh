#!/bin/bash

# Script para instalar configurações do Karabiner-Elements
# Permite selecionar quais configurações aplicar

# Cores para melhor visualização
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/configs"
KARABINER_DIR="$HOME/.config/karabiner"
KARABINER_CONFIG="$KARABINER_DIR/karabiner.json"
TEMP_CONFIG="/tmp/karabiner_temp.json"

# Função para verificar se o jq está instalado
_check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}O utilitário 'jq' não está instalado, mas é necessário para este script.${NC}"
        echo "Deseja instalar o jq agora? (s/n)"
        read -r install_jq
        if [[ "$install_jq" =~ ^[Ss]$ ]]; then
            if command -v brew &> /dev/null; then
                brew install jq
            else
                echo "Homebrew não encontrado. Por favor, instale o jq manualmente:"
                echo "https://stedolan.github.io/jq/download/"
                exit 1
            fi
        else
            echo "Este script requer o jq para funcionar. Saindo."
            exit 1
        fi
    fi
}

# Função para verificar se o Karabiner-Elements está instalado
_check_karabiner() {
    if ! [ -d "$KARABINER_DIR" ]; then
        echo -e "${YELLOW}Karabiner-Elements não parece estar instalado.${NC}"
        echo "Por favor, instale-o primeiro: https://karabiner-elements.pqrs.org/"
        echo "Ou via Homebrew: brew install --cask karabiner-elements"
        exit 1
    fi
}

# Função para criar um arquivo de configuração base se não existir
_create_base_config() {
    if [ ! -f "$KARABINER_CONFIG" ]; then
        echo "Criando arquivo de configuração base do Karabiner-Elements..."
        mkdir -p "$KARABINER_DIR"
        cp "$SCRIPT_DIR/karabiner.json" "$KARABINER_CONFIG"
    fi
}

# Função para adicionar uma configuração ao arquivo karabiner.json
_add_config() {
    local config_file="$1"
    local config_name=$(jq -r '.title' "$config_file")
    local rules=$(jq '.rules' "$config_file")
    
    # Adiciona as regras ao arquivo de configuração
    jq --argjson new_rules "$rules" '.profiles[0].complex_modifications.rules += $new_rules' "$KARABINER_CONFIG" > "$TEMP_CONFIG"
    mv "$TEMP_CONFIG" "$KARABINER_CONFIG"
    
    echo -e "${GREEN}✓${NC} Configuração adicionada: $config_name"
}

# Função principal
main() {
    _check_jq
    _check_karabiner
    _create_base_config
    
    echo "=== Instalador de Configurações do Karabiner-Elements ==="
    echo "Selecione quais configurações deseja instalar:"
    
    # Lista todas as configurações disponíveis
    configs=("$CONFIG_DIR"/*.json)
    for i in "${!configs[@]}"; do
        config_name=$(jq -r '.title' "${configs[$i]}")
        echo "$((i+1)). $config_name"
    done
    
    echo "A. Instalar todas as configurações"
    echo "Q. Sair sem instalar"
    
    read -r -p "Sua escolha (separadas por espaço, ex: 1 3 5): " choices
    
    # Converte para minúsculas
    choices=$(echo "$choices" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$choices" == "q" ]]; then
        echo "Saindo sem instalar configurações."
        exit 0
    elif [[ "$choices" == "a" ]]; then
        echo "Instalando todas as configurações..."
        for config in "${configs[@]}"; do
            _add_config "$config"
        done
    else
        # Instala as configurações selecionadas
        for choice in $choices; do
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#configs[@]}" ]; then
                _add_config "${configs[$((choice-1))]}"
            else
                echo -e "${YELLOW}Opção inválida: $choice${NC}"
            fi
        done
    fi
    
    echo -e "\n${GREEN}Configuração concluída!${NC}"
    echo "Nota: Pode ser necessário reiniciar o Karabiner-Elements para aplicar as alterações."
    echo "      Você pode fazer isso através do menu do Karabiner-Elements na barra de menu."
}

# Executa a função principal
main