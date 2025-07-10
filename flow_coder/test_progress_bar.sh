#!/bin/bash

# Script para testar a barra de progresso
# Este script simula a instalação do Python, mas com tempos reduzidos

# Importar utilitários de cores e mensagens
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
source "$PROJECT_ROOT/utils/colors_message.sh"

# Função para exibir uma barra de progresso
_show_progress() {
    local duration=$1    # Duração em segundos
    local prefix=$2      # Texto a ser exibido antes da barra de progresso
    local width=50       # Largura da barra de progresso
    local interval=0.1   # Intervalo de atualização em segundos
    local steps=$((duration / interval))
    local progress=0
    
    # Ocultar cursor
    tput civis
    
    # Tempo inicial
    local start_time=$(date +%s)
    local current_time
    local elapsed
    local percent
    
    while [ $progress -lt $steps ]; do
        current_time=$(date +%s)
        elapsed=$((current_time - start_time))
        
        # Calcular porcentagem
        percent=$((elapsed * 100 / duration))
        if [ $percent -gt 100 ]; then
            percent=100
        fi
        
        # Calcular partes preenchidas e vazias da barra
        local filled=$((width * percent / 100))
        local empty=$((width - filled))
        
        # Construir a barra de progresso
        local bar=""
        for ((i=0; i<filled; i++)); do
            bar="${bar}█"
        done
        for ((i=0; i<empty; i++)); do
            bar="${bar}░"
        done
        
        # Imprimir a barra de progresso
        printf "\r${BLUE}${prefix}${NC} [${GREEN}%s${NC}] %3d%%" "$bar" "$percent"
        
        # Atualizar progresso
        progress=$((elapsed * steps / duration))
        if [ $progress -ge $steps ]; then
            break
        fi
        
        sleep $interval
    done
    
    # Completar a barra de progresso
    local bar=""
    for ((i=0; i<width; i++)); do
        bar="${bar}█"
    done
    printf "\r${BLUE}${prefix}${NC} [${GREEN}%s${NC}] %3d%%\n" "$bar" "100"
    
    # Mostrar cursor
    tput cnorm
}

# Função para executar um comando com uma barra de progresso
_run_with_progress() {
    local command=$1
    local message=$2
    local duration=$3
    
    # Executar o comando em segundo plano e redirecionar saída
    eval "$command" > /tmp/test_command_output.log 2>&1 &
    local pid=$!
    
    # Mostrar barra de progresso
    _show_progress "$duration" "$message"
    
    # Aguardar o comando terminar
    wait $pid
    local exit_code=$?
    
    # Verificar se o comando foi bem-sucedido
    if [ $exit_code -ne 0 ]; then
        print_error "Comando falhou com código de saída $exit_code"
        print_error "Verifique o arquivo de log em /tmp/test_command_output.log para detalhes"
        return $exit_code
    fi
    
    return 0
}

# Função para simular a instalação do Python
test_progress_bar() {
    print_header "Teste da Barra de Progresso"
    
    print_info "Simulando download do Python..."
    sleep 2
    
    print_info "Simulando extração do arquivo..."
    sleep 1
    
    print_info "Simulando configuração do Python..."
    sleep 2
    
    print_info "Simulando compilação do Python..."
    # Simular um comando que leva tempo (sleep 5 segundos)
    _run_with_progress "sleep 5" "Compilando Python" 5
    
    print_info "Simulando instalação do Python..."
    # Simular um comando que leva tempo (sleep 10 segundos)
    _run_with_progress "sleep 10" "Instalando Python" 10
    
    print_success "Teste da barra de progresso concluído com sucesso!"
}

# Executar o teste
test_progress_bar