#!/bin/bash

set -e

TEMP_FILE="test_python_script.py"

check_python() {
    echo "Verificando instalação do Python..."
    if ! command -v python3 &>/dev/null; then
        echo "Python não está instalado."
        exit 1
    fi

    echo "Python encontrado:"
    python3 --version

    echo "Criando e executando um script de teste..."
    echo -e "print('Hello, World!')" > "$TEMP_FILE"
    python3 "$TEMP_FILE"

    echo "Limpando arquivos temporários..."
    rm -f "$TEMP_FILE"
    echo "Verificação concluída com sucesso!"
}

check_python
