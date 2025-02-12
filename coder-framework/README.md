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

2. **Função `install_coder`**:
   - Cria um ambiente virtual Python chamado `coder_env`.
   - Ativa o ambiente virtual.
   - Atualiza o `pip` para a versão mais recente.
   - Instala o pacote `coder` usando o comando `pip install https://storage.googleapis.com/flow-coder/coder-0.88-py3-none-any.whl`.
   - Desativa o ambiente virtual.

3. **Função `configure_path`**:
   - Adiciona o diretório `coder_env/bin` ao PATH no arquivo de configuração do shell (`.zshrc`).
   - Verifica se a entrada do PATH já existe no arquivo de configuração do shell e a adiciona se não existir.

4. **Execução Principal do Script**:
   - Chama a função `install_coder` para instalar o `coder`.
   - Chama a função `configure_path` para configurar o PATH.
   - Exibe uma mensagem indicando que a instalação foi concluída e recomenda reiniciar o terminal ou executar `source ~/.zshrc` para aplicar as mudanças no PATH.

Com este script, você pode instalar o `coder` diretamente com Python e configurá-lo para ser executado sem o uso do conda.