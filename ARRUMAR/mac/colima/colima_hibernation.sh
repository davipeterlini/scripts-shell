#!/bin/bash

# Função para parar o Colima
stop_colima() {
    echo "Parando o Colima..."
    colima stop
}

# Função para iniciar o Colima
start_colima() {
    echo "Iniciando o Colima..."
    colima start
}

# Verifica o estado de hibernação
case "$1" in
    "sleep")
        stop_colima
        ;;
    "wake")
        start_colima
        ;;
    *)
        echo "Use 'sleep' para parar o Colima e 'wake' para iniciar."
        ;;
esac