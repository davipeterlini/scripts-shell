# Build macOS .dmg
echo "Building macOS .dmg..."
pkgbuild --root coder-framework --identifier com.example.coder --version 1.0 --install-location /usr/local/bin coder-framework/build/mac/coder.pkg
hdiutil create coder-framework/build/mac/coder.dmg -volname "Coder Installer" -srcfolder coder-framework/build/mac/coder.pkg

1. `echo "Building macOS .dmg..."`: Esta linha imprime uma mensagem no terminal indicando que o processo de construção do instalador para macOS está começando.

2. `pkgbuild --root coder-framework --identifier com.example.coder --version 1.0 --install-location /usr/local/bin coder-framework/build/mac/coder.pkg`:
   - `pkgbuild`: Comando utilizado para criar um pacote de instalação para macOS.
   - `--root coder-framework`: Especifica o diretório raiz que contém os arquivos a serem incluídos no pacote.
   - `--identifier com.example.coder`: Define um identificador único para o pacote.
   - `--version 1.0`: Define a versão do pacote.
   - `--install-location /usr/local/bin`: Especifica o local onde os arquivos serão instalados no sistema de destino.
   - `coder-framework/build/mac/coder.pkg`: Especifica o caminho e o nome do arquivo de pacote a ser criado.

3. `hdiutil create coder-framework/build/mac/coder.dmg -volname "Coder Installer" -srcfolder coder-framework/build/mac/coder.pkg`:
   - `hdiutil create`: Comando utilizado para criar uma imagem de disco no macOS.
   - `coder-framework/build/mac/coder.dmg`: Especifica o caminho e o nome do arquivo de imagem de disco a ser criado.
   - `-volname "Coder Installer"`: Define o nome do volume que será exibido quando a imagem de disco for montada.
   - `-srcfolder coder-framework/build/mac/coder.pkg`: Especifica a pasta de origem que contém os arquivos a serem incluídos na imagem de disco.

### Explicação do Script `install_coder.sh`

1. **Instalação do Python**:
   - O script `install_python.sh` é executado para garantir que o Python está instalado e configurado corretamente.

2. **Função `get_latest_coder_url`**:
   - Obtém a URL da última versão do `coder` a partir de um arquivo JSON hospedado em uma URL específica.

3. **Função `install_coder`**:
   - Cria um ambiente virtual Python chamado `coder_env` no diretório `$HOME`.
   - Ativa o ambiente virtual.
   - Atualiza o `pip` para a versão mais recente.
   - Obtém a URL da última versão do `coder` e instala o pacote `coder` usando o comando `pip install`.
   - Desativa o ambiente virtual.

4. **Função `configure_path`**:
   - Adiciona o diretório `$HOME/coder_env/bin` ao PATH no arquivo de configuração do shell (`.zshrc`).
   - Verifica se a entrada do PATH já existe no arquivo de configuração do shell e a adiciona se não existir.

5. **Execução Principal do Script**:
   - Chama a função `install_python` para garantir que o Python está instalado.
   - Chama a função `install_coder` para instalar o `coder`.
   - Chama a função `configure_path` para configurar o PATH.
   - Exibe uma mensagem indicando que a instalação foi concluída e recomenda reiniciar o terminal ou executar `source ~/.zshrc` para aplicar as mudanças no PATH.

Com este script, você pode instalar o `coder` diretamente com Python e configurá-lo para ser executado sem o uso do conda.

### Nota Importante
Se você remover `$HOME/coder_env/bin` do seu profile, o `coder` deixará de funcionar, pois o executável `coder` não estará mais no PATH do sistema. Isso significa que o sistema não conseguirá localizar o comando `coder` quando você tentar executá-lo.