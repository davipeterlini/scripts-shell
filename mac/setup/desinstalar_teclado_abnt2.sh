#!/bin/bash

# Script de desinstalação do layout de teclado ABNT2 para macOS

echo "==================================================================="
echo "    Desinstalador do Layout Brasileiro ABNT2 para macOS"
echo "==================================================================="
echo ""

# Verifica se está sendo executado como root
if [ "$(id -u)" != "0" ]; then
   echo "Este script precisa ser executado como root (sudo)."
   echo "Por favor, execute: sudo $0"
   exit 1
fi

DEST_PATH="/Library/Keyboard Layouts/Brasil ABNT2.bundle"

# Verifica se o bundle existe
if [ ! -d "$DEST_PATH" ]; then
    echo "O layout de teclado ABNT2 não parece estar instalado no sistema."
    exit 0
fi

# Remove o bundle
echo "Removendo layout de teclado ABNT2..."
rm -rf "$DEST_PATH"

echo ""
echo "==================================================================="
echo "               Desinstalação concluída com sucesso!"
echo "==================================================================="
echo ""
echo "IMPORTANTE: É NECESSÁRIO fazer logout ou reiniciar o computador"
echo "           para que as alterações sejam aplicadas."
echo ""
echo "Após reiniciar, você precisará desativar o layout nas preferências:"
echo ""
echo "1. Abra as 'Preferências do Sistema' no menu Apple"
echo "2. Clique em 'Teclado' (ou 'Idioma e Texto' em versões mais antigas)"
echo "3. Selecione a aba 'Fontes de Entrada' (ou 'Leiautes de Teclado')"
echo "4. Desmarque as opções 'Brasil Note' e 'Brasil PC'"
echo ""