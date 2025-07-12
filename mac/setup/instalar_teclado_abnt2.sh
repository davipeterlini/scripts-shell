#!/bin/bash

# Script de instalação do layout de teclado ABNT2 para macOS
# Baseado nas instruções do arquivo Leia-me.txt

echo "==================================================================="
echo "      Instalador do Layout Brasileiro ABNT2 para macOS"
echo "                         Versão 0.5"
echo "==================================================================="
echo ""

# Verifica se está sendo executado como root
if [ "$(id -u)" != "0" ]; then
   echo "Este script precisa ser executado como root (sudo)."
   echo "Por favor, execute: sudo $0"
   exit 1
fi

# Obtém o diretório do script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUNDLE_PATH="$SCRIPT_DIR/Brasil ABNT2 v0.5/Brasil ABNT2.bundle"
DEST_PATH="/Library/Keyboard Layouts/Brasil ABNT2.bundle"

# Verifica se o bundle existe
if [ ! -d "$BUNDLE_PATH" ]; then
    echo "Erro: Não foi possível encontrar o bundle do teclado em:"
    echo "$BUNDLE_PATH"
    exit 1
fi

# Remove instalação anterior se existir
if [ -d "$DEST_PATH" ]; then
    echo "Removendo instalação anterior..."
    rm -rf "$DEST_PATH"
fi

# Copia o bundle para o diretório de layouts de teclado
echo "Copiando layout de teclado para $DEST_PATH..."
cp -R "$BUNDLE_PATH" "$DEST_PATH"

# Ajusta permissões
echo "Ajustando permissões..."
chown -R root:wheel "$DEST_PATH"
chmod -R 755 "$DEST_PATH"

echo ""
echo "==================================================================="
echo "                  Instalação concluída com sucesso!"
echo "==================================================================="
echo ""
echo "IMPORTANTE: É NECESSÁRIO fazer logout ou reiniciar o computador"
echo "           para que as alterações sejam aplicadas."
echo ""
echo "Após reiniciar, siga estes passos para ativar o layout:"
echo ""
echo "1. Abra as 'Preferências do Sistema' no menu Apple"
echo "2. Clique em 'Teclado' (ou 'Idioma e Texto' em versões mais antigas)"
echo "3. Selecione a aba 'Fontes de Entrada' (ou 'Leiautes de Teclado')"
echo "4. Marque as opções 'Brasil Note' e/ou 'Brasil PC'"
echo "   - Brasil Note: Para teclados de notebooks (como MacBook)"
echo "   - Brasil PC: Para teclados ABNT2 externos conectados via USB"
echo ""
echo "Dicas de uso para teclas especiais em notebooks:"
echo "  - Option + Q = /"
echo "  - Option + W = ?"
echo "  - Option + Z = \\"
echo "  - Option + X = |"