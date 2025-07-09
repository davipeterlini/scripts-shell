# Layout Brasileiro ABNT2 para macOS

Este pacote contém o layout de teclado brasileiro ABNT2 para macOS, desenvolvido originalmente por Rodrigo Zanatta Silva.

## Conteúdo

- **Brasil Note**: Layout para teclados de notebooks (como MacBook)
- **Brasil PC**: Layout para teclados ABNT2 externos conectados via USB

## Instalação Automática

1. Abra o Terminal
2. Navegue até o diretório onde está este arquivo README
3. Execute o comando:
   ```
   sudo ./instalar_teclado_abnt2.sh
   ```
4. Digite sua senha quando solicitado
5. Reinicie o computador ou faça logout
6. Após reiniciar, ative o layout nas Preferências do Sistema:
   - Abra as Preferências do Sistema
   - Vá para Teclado > Fontes de Entrada (ou Idioma e Texto > Leiautes de Teclado)
   - Marque "Brasil Note" e/ou "Brasil PC"

## Desinstalação

1. Abra o Terminal
2. Navegue até o diretório onde está este arquivo README
3. Execute o comando:
   ```
   sudo ./desinstalar_teclado_abnt2.sh
   ```
4. Digite sua senha quando solicitado
5. Reinicie o computador ou faça logout

## Instalação Manual

1. Copie a pasta "Brasil ABNT2.bundle" para "/Library/Keyboard Layouts/"
2. Reinicie o computador ou faça logout
3. Ative o layout nas Preferências do Sistema conforme descrito acima

## Teclas Especiais em Notebooks

Devido às diferenças entre teclados ABNT2 e teclados de Mac, algumas teclas especiais podem ser acessadas usando:

- Option + Q = /
- Option + W = ?
- Option + Z = \\
- Option + X = |

## Problemas Conhecidos

- Na versão 0.5, foi identificado um problema onde a tecla que deveria produzir \\| está produzindo '".
- O macOS não diferencia Alt direito do Alt Esquerdo ("Alt Gr"), o que pode causar algumas inconsistências.

## Contato

Para dúvidas, erros ou sugestões, entre em contato com o desenvolvedor original:
rodrigozanattasilva@gmail.com