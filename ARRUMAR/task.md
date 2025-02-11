Geral


- 10/02/2025
  - Ajustes o script 
    #!/bin/bash

    # Load environment variables and utility functions if not already loaded
    if [ -z "$ENV_LOADED" ]; then
        source "$(dirname "$0")/utils/load_env.sh"
        load_env
        export ENV_LOADED=true
    fi
    source "$(dirname "$0")/../utils/display_menu.sh"
    source "$(dirname "$0")/install_homebrew.sh"
    source "$(dirname "$0")/update_apps.sh"

    # Function to install apps on macOS
    install_apps_mac() {
        # Check if dialog is installed
        if ! command -v dialog &> /dev/null; then
            echo "dialog is not installed. Installing dialog..."
            brew install dialog
        fi

        local apps=("$@")
        for app in "${apps[@]}"; do
            brew install "$app"
        done
    }

    # Main function to handle app installation based on user choice
    main() {
        # Update all Homebrew packages before installation
        update_all_apps_mac
        
        # Install Homebrew if not installed
        install_homebrew

        # Display menu and get user choices
        choices=$(display_menu)

        # Install selected apps
        [[ "$choices" == *"1"* ]] && install_apps_mac $(echo "$INSTALL_APPS_BASIC_MAC" | tr ',' ' ')
        [[ "$choices" == *"2"* ]] && install_apps_mac $(echo "$INSTALL_APPS_DEV_MAC" | tr ',' ' ')
        [[ "$choices" == *"3"* ]] && install_apps_mac $(echo "$APPS_TO_INSTALL_MAC" | tr ',' ' ')
    }

    main
  - 


- 26/01/2025
  - Criação do script para instalação do python e do coder framework da maneira correta na máquina 
  - Atualização do script do python para ir para a versão oficial de scripts e pastas 
  - Estrutura de scripts e pastas
  - Faça um esquema de configuração que não fique pedindo para atualizar excecutar novamente os scripts que foram executados
  - Ajustes nos scripts principais 
  - Removendo do git o que ainda precisa de organização 
  - Otimize os scripts da pasta utils e considere as informações; 
    - Manter uma arquitetura limpa 
    - Manter Coesão 
    - Remover as funções que não estão sendo utilizadas
  - Crie um script para detecção do profile que está sendo utilizado na pasta utils
  - Colocar os scripts de setup na paras do mac e adequá-los a nova estrutura
  - Criação de plugin para VScode
  - Criação de script de setup de vscode 
    - Nesse script chame o script install_plugins.sh
    - Lembres-se esse script deve conter configurações do vscode
    - Esse script deve manter o padrão que está sendo realizado em outros scripts ou melhor ter uma arquitetura limpa otimizada e coesa
  
  - Configurações do Google Cloud 
  - Configurações do Colima 
  - Configurações do Python


  - Remover o arquivo .env do commit 
  - Linux
    - Instalar todos os apps com fastpak 
    - Verificar se isso fale a pena em linux baseados na distribuição debians


- construa um plugin na pasta mac/vscode/install_plugins.sh
  - esse script deve instalar as extenções básicas no vscode 
  - dentre elas: 
      keymap do explise
      todos tree
      docker 
      python
      flow copilot
      
- script para configurar o vscode 
  - configurar o keymap do eclipse 
  - deixar o autosave habilitado 
- Precisa remover Apps se necessário para a instalação - brew reinstall --cask visual-studio-code
- Arrumar criar script de configuração e instalação de extenções no vscode
- Fechar os apps abertos para execução da instalação
- Ver como configuirar o .env.local
- Cria script para configurar via shell os detalhes das aplicações mais utilizadas (separar por script)
  - Configuração de teclado abnt 
  - Configuração do OBS Studio
  - Configuração do Drive
  - Configurações do mac

- Arrumar variável de ambient HOME no .env
- Arrumar pastas dos SOs para colocar o que é de SETUP em setup 
- Arrumar scripts do MAC - install_apps.sh (.env)
- Arrumar scripts do MAC - update_apps.sh (.env)
- Alterar a pasta de scripts dentro de cada SO



- Criar o script de Teste

- Arrumar script de install_apps e update_apps do linux
- Se o .env.local não existir crie ele
- Executar os scripts separadamente para ver o comportamento
- Unir os scripts de install_apps.sh 
- Corrigir os scripts de Update 
  - Para atualizar o SO e os pacotes de instalação (bre update e apt-get update && apt-get upgrade)
  - Atualizar os aplicativos a partir do pacote
- 




- O Script setup_multiple_repo_accounts.sh da pasta repository precisa ser corrigido 
  - ./repository/setup_multiple_repo_accounts.sh: line 102: Setting up multiple ${REPO_MANAGER^} accounts...: bad substitutio


no script load_env.sh eu preciso que a função check_existing_home seja executada antes de tudo para que não seja exibido no terminal, quando o usuário estiver executando qualquer script que chame o load_env.sh, a pergunta: 


- Os scripts da pasta BitBucket precisam ser alterados para serem genéricos e terem o seletor de manager repos
- Os scripts precisa mudar de pasta e serem adicionados na pasta repo 
- Remover o README da pasta bitbucket e levar para o README oficioal da aplicação as informaões desse README
- A pasta bitbucket precisa ser removida 
- A pasta do git pecisa ser removida 


Corrija o erro ao executar o script bitbucket/connect_bitbucket_ssh_account.sh
./connect_bitbucket_ssh_account.sh: line 90: [: missing `]'



- Adicione em todos os scripts um interceptador para executar o script grant_persmission.sh que está na raiz da aplicação





- Adicione a configuração do vscode para persistir as abas e paths dos terminais internos do vscode que estão abertos
- É possível aplicar configurações da aplicação karabiner - elements via script shell

- Colima

### Passo 1: Verifique o Caminho e Permissões do Script

Certifique-se de que o script `colima_hibernation.sh` está no local correto e tem permissões de execução:

```bash
chmod +x /Users/$(whoami)/colima_hibernation.sh
```

### Passo 2: Crie o Arquivo plist Manualmente

Crie o arquivo plist manualmente para garantir que ele está formatado corretamente:

```bash
nano ~/Library/LaunchAgents/com.user.colima-hibernation.plist
```

Adicione o seguinte conteúdo ao arquivo, substituindo `seu_usuario` pelo seu nome de usuário real:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.colima-hibernation</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/seu_usuario/colima_hibernation.sh</string>
        <string>sleep</string>
    </array>
    <key>WatchPaths</key>
    <array>
        <string>/private/var/vm/sleepimage</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```

### Passo 3: Defina as Permissões do Arquivo plist

Defina as permissões corretas para o arquivo plist:

```bash
chmod 644 ~/Library/LaunchAgents/com.user.colima-hibernation.plist
```

### Passo 4: Carregue o Agente

Tente carregar o agente novamente:

```bash
launchctl unload ~/Library/LaunchAgents/com.user.colima-hibernation.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/com.user.colima-hibernation.plist
```

Se o problema persistir, tente usar o comando `launchctl bootstrap` para obter mais informações sobre o erro:

```bash
sudo launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.colima-hibernation.plist
```

### Passo 5: Verifique os Logs

Se ainda houver problemas, verifique os logs do sistema para obter mais detalhes sobre o erro:

```bash
log show --predicate 'process == "launchd"' --info --last 1h
```

Isso deve fornecer mais informações sobre o motivo pelo qual o agente não está sendo carregado corretamente. Se houver mensagens de erro específicas, por favor, compartilhe-as para que possamos diagnosticar melhor o problema.