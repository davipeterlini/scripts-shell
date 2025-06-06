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
  - Colocar os scripts de setup na paras do mac e adequá-los a nova estrutura
  - Criação de plugin para VScode
  - Criação de script de setup de vscode 
    - Nesse script chame o script install_plugins.sh
    - Lembres-se esse script deve conter configurações do vscode
    - Esse script deve manter o padrão que está sendo realizado em outros scripts ou melhor ter uma arquitetura limpa otimizada e coesa
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
  - Justes dos scripts de instalação do Mac
  - Testes e ajustes dos scripts do VScode
  - Crie um script para detecção do profile que está sendo utilizado na pasta utils
  - Ajustes dos scripts no diretório do linux 
- 11/02/2025
  - vs code config  
    - Teste do script vscode/install_vscode_plugins.sh
    - o script vscode/install_vscode_plugins.sh deve ser chamamdo dentro do vscode/setup_vscode.sh
    - Criar o script de geração do executável de instalação do coder para os SOs
- 12/02/2025
  - Entender o que o script de build faz para gerar o executável do mac
  - Identificar onde é feita a instalação do coder no mac which coder
    - /usr/local/Caskroom/miniconda/base/bin/coder
  - Atualizar script para instalar o coder sem o uso do conda 
  - Verificar o arquivo .zshrc para ver o novo path do coder
  - Verificar como é realizado no coder para pegar a versão latest
    - Ver no código do coder
    - A partir da url - https://storage.googleapis.com/flow-coder/update_info.json
  - Ajustes no script de instalação do coder 
  - Criação de alies para testes do coder
    - export PATH=$HOME/coder_env/bin:$PATH
    - source ~/.zshrc
    - alias coder_venv="$HOME/coder_env/bin/coder"
  - O script de instalação deve ter a possibilidade de instalar o conda 
  - Deve existir um script de check de instalação do coder 
  - Deve existir um script de check de onde o coder está executando 
  - Geração de pacote do Mac, Linux via mac 
  - geração de pacote do linux, via docker 
  - Geração de pacote do mac e windows via docker
  - Coloque algum separador que separe visualmente no terminal a geração de cada build para cada SO 
  - Use apenas um dockerfile com a imagem alpine:latest e gere o .deb (linux), .pkg e .dmg (mac) e o .exe (windows)
  - Remova o arquivo Dockerfile e o Dockerfile.windows da raiz do repo
- 22/02
  - Adicionar arquivo de config nas configurações global do vscode - settings.json - /Users/davi.peterlini/.config/Code/User
- 25/02/2025
  - Instalação do meld via brew - https://github.com/yousseb/meld/releases#:~:text=3-,meldmerge.dmg,-37.3%20MB
  - Github
    - Ajustes dos scipts do Git 
      - 1 - Criar o multi ssh - ssh_multiple_github_accounts.sh
      - 2 - Verificar para gerar o GIHUB_TOKEN - generate-classic-token-gh-local.sh
      - 3 - Habilitar a chave desejada para autenticação - connect_git_ssh_account.sh
    - Ajustes dos TODOS
  - Coder 
    - Instalação 
    - Script de instalação
  - Script Geral 
    - Adicionar chamada do git
  - Vscode 
    - Instalação da extensão - MDX, vscode-styled-components
    - Instalação das extensões no vscode 
      - Separar scripts para instalação das extensões da cit e de coisas da CI&T
      - Configuração do keymap 
      - Configuração o autosave
- 05/03/2025
  - Configurar as chaves ssh da forma correta no mac do trabalho
  - Geração do README da pasta do git 
    - Documentar configuração do amviente e qual script do git executar primeiro
  - Atualize o README para ter os detalhes dos scripts 
    github/configure_two_ssh_github_keys.sh 
    github/connect_git_ssh_account.sh 
    github/generate-classic-token-gh-local.sh
    E adicione uma sessão de qual a sequencia deve ser executada dos scripts para a configuração correta do ambiente
  - Gere um script que execute a sequencia colocada no readme 
    salve o script na pasta github com o nome setup_github.sh
  - Coloque cores, no script gerado, para os prints de mensagens no terminal
  - Agora adicione cores nas mensgaens
  - Atualize o readme adicionando a documentação do novo script
  - Altere o script github/configure_two_ssh_github_keys.sh para que permita configurar multiplas chaves ssh 
    Ou seja ao configurar uma chave ssh deve aparecer a pergunta se deseja configurar mais uma chave e se o useuário pressionar Y então novamente abre a caixa de dialogo para configuração
  - Adicione a geração remota da chave do ssh
  - Adicione um novo método no script github/configure_multi_ssh_github_keys.sh para fazer o vinculo da chave ssh criada local, ao github remoto 
    Obs: não faça modificações no scrip, apenas adicione no final dele o método
  - Crie um script de color message echam nos scripts do git
  - Leve a estrutura de cores do script github/configure_multi_ssh_github_keys.sh para a pasta utils e chame ele no script github/configure_multi_ssh_github_keys.sh
  - Altere para que script faça overwrite da maneira correta no arquivo .ssh/config
  - Altere o script github/configure_multi_ssh_github_keys.sh para que gere um token GITHUB_TOKEN com as permissões: gh auth refresh -h github.com -s repo,workflow
  - Deixar todos os comentários e mensagens em inglês no github/configure_multi_ssh_github_keys.sh
- 06/03/2025
  - Remover a instalação das extensções do vscode do script do setup
  - Ajustes no script de setup da raiz
  - Ajustes dos scripts da pasta mac 
  - Criando um README para a pasta MAC
  - Aplique as cores nos script setup_enviroment.sh para que no terminal seja exibido com cor as mensagens
  - Colocar a configuração do settings.json do vscode na configuração global


  - Remova o arquivo $HOME/.ssh/known_hosts sempre que executar o script github/configure_multi_ssh_github_keys.sh

  - Altere para que a configuração do o SSO, após adicionar a key remota possar ser realizad via script 
    Alterar o script github/configure_multi_ssh_github_keys.sh, no método associate_ssh_key_with_github


  



  - Altere o script github/generate-classic-token-gh-local.sh para que posso verificar quais as chaves SSH da pasta home/.ssh geradas no script github/configure_two_ssh_github_keys.sh para que seja possível montar mostrar uma mensaqgem para escolher para qual 

  - Criação de script para montar ambiente de desenvolvimento
    - O script deve ter executado 
  - Configuraçãos do MAC - Iterm
    - Dado o script: mac/setup/setup_iterm.sh e mac/setup/setup_terminal.sh 
      Quais as diferenças entre os dois e quais os itens que estão duplicados
      Una os dois scripts mantendo o que faz mais sentido
  - Configuraçãos do MAC - Mac
    - Crie um script para fazer o passo a passo abaixo no mac
      - Abra uma janela do Finder clicando no ícone do Finder no Dock.
      - Selecione uma pasta que deseja visualizar no formato de lista.
      - Clique no botão "Lista" na barra de ferramentas do Finder para alterar a visualização para o formato de lista.
      - Acesse o menu "Visualizar" e selecione "Mostrar Opções de Visualização" ou pressione Command (⌘) + J.
      - Na janela que se abrir, ajuste as configurações conforme desejado para personalizar a visualização em lista.
- 10/05/20258
  - Crie um prompt baseado no prompt da imagem: prompt/prompt.jpeg para criação de um script para instalação do docker no mac, linux e windows 
    Obs: o script deve fazer a instalação de maneira isolada na máquina do usuário sem afetar instalações existentes 
    Obs: no mac use o colima para o docker e instale o docker e faz as configurações com brew 
  - O script deve fazer a configuração do docker após instalação para que funcione corretamente, e além disso subir uma imagem leve do docker para testes
  - Verificação da instalação
  - Aplique o script o clean code
    - Separe cada funcionalidade por método e chame na main
  - Verifique se o colima está instalado se sim verifique se está rodando se não execute o start 
    - Caso não esteja instalado faça a instação
- 11/05/2025
  - Ajustes Geral do repo
  - Remover Scripts que não são mais utilizados
- 14/04/2025
  - Ajuste de estrutura do repo
  - Ajustes de scripts do python 
- 15/04/2025
  - Ajuste da estrutura do repo 
  - Ajustes de scripts do mac 
- 16/04/2025
  - Altere o load_env.sh para: 
    - Não olhar mais para o arquivo .env para pegar a variável home do usuário  (HOME)
    - Olhar para o arquivo .env.local
    - Se o arquivo não existir ele deve ser criado
  - Criar um script para trocar automaticamente entre o github da conta pessoal e github da conta de trabalho, fazer essa verificação com o comando do git que trás o repo e o usuário 
- 29/04/2025
  - Arrumar Scripts da automação do git
  - Colocar uma lógica no script github/setup_git_push_interceptor.sh que sempre sobreescreve as variáveis de ambiente que já existem no .env.local
  - Ajuste de script de setup para configurar o git no momento da instalação
  - Tenho mais de uma chave SSH em minha máquina e preciso gerenciar isso de maneira automatizada, para quando digitar git push no repo ele use a chave correta, como devo proceder para que isso acontece dessa forma
- 30/04
  - mostrar o repo para o ary 
  - proteger a branch main do repo scripts-shell
  - Gerar script para atualizar o repo de scripts-shell do trabalho assim que fizer git push nesse repo 
    - Copiar com o comando git para não perder histórico 
    - Comandos de commit git add . && git commit -m |update version| && git push 
- 02/05/2025
  - Salvar versões de config do .ssh 
  - Colocar variáveis globais no script de dev 1
  - Colocar o open manus dentro do project start para geração de plano  
  - Re autenticar no coder CLI - 
- 19/05/2025
  - Criando o script de instalação e configuração do docker no mac 
  - Crie um script para o setup do docker e outro para a instalação separe o script existente atualmente
- 23/05/2025
  - Crie um script para configurar o .env global 
    - Esse script deve fazer o seguinte:
      - Criar o .env na raiz do profile do usuário a partir do .env da pasta scripts/.env.example
      - De a opção de o usuário escolher o profile que ele quer salvar .zshrc ou .basrc
      - Salve a linha abaixo dentro do profile: 
          export $(grep -v '^#' .coder-ide/.env | xargs)
      - Imprima as variáveis salvas no terminal de acordo com o env criado
    - Esse script deve usar o esquema de cor do utils
    - Esse script deve estar na pasta scripts
  - Coloque cores no script 
  - Arrumar script de scripts/utils/grant_permissions.sh para sempre executar no dir correto 
  - Teste do script de setup de envs
  - Altere o script setup_env.sh para 
    - Criar o .env na raiz do profile do usuário a partir do .env da pasta scripts/.env.example
    As outras funções podem continar a existir
  - export $(grep -v '^#' ~/.env | xargs)
- 24/05/2025
  - Criar script de baixar repôs e criação de pastas locais do trabalho 
    - Armazenamento dos arquivos de configuração 
    - Ajustes do profile local com os tokens e informações dos api keys do projeto
- 02/05/2025
  - Atualizar o script de setup do trabalho para a configuração local 
  - Backup dos arquivos de configuração do .ssh
  - Atualize os scripts de setup_personal_projects.sh e setup_work_projects.sh para que se o repo existir e se estiver na main fazer o git pull 
    - Caso não estiver na main fazer o git pull origin main e se gerar conflito colocar uma mensagem de alerta do conflito
  - Lembre-se que não é para fazer clone se o dir existir e se o dir do repo tambem e sim apenas para atualizar 
  - Sempre antes de fazer a criação dos diretórios verifique se eles já existem, se não existem não crie novamente apenas passe a etapa 
  - Ajuste os scripts com clen code e clean arquitecture
  - Ajustes de scripts do github
  - Criar script de configurar o config do .ssh 
- 03/05/2025
  - Altere o script github/setup_ssh_config.sh para que esteja dentro da pasta dev e pegue o assests da pasta: assets/ssh-git
  - Criar um script de setup de repos dentro da pasta dev
    - Esse script deve executar o setup do git e bitbucket executando na sequências os scripts
      - github/configure_multi_ssh_github_keys.sh
      - bitbucket/configure_multi_ssh_bitbucket_keys.sh
      - dev/setup_ssh_config.sh
  - Mova a pasta assests na raiz para a pasta dev 
    - Altere o script dev/setup_ssh_config.sh para pegar da pastas assests correta 
  - Mova o script setup_git_and_bitbucket.sh para a pastas dev  
  - Criar um script para cconfigurar o setup project e solicitar ao usuário qual deve ser o script que vai ser usado abaixo a partir do utils/list_projects.sh
    - dev/setup_personal_projects.sh
    - dev/setup_work_projects.sh
  - Crie um script de setup na pasta dev para fazer as seguintes execuções 
    - Selecionar o profile com utils/choose_shell_profile.sh 
    - Escolher o SO e salvar em variável global a partir do script utils/detect_os.sh
    - Execução do script dev/project-folder/setup_project.sh
    - Execução do script dev/setup_git_and_bitbucket.sh
    - Execução do script dev/git/setup_git_and_bitbucket.sh
    - Execução do script dev/git/setup_ssh_config.sh
  - Ajustar scripts de dev para seguir o padrão de clean code 
    - setup.sh 
  - Ajustar todos scripts da pasta utils para usar o colors_message
  - Ajuste do Script - dev/project-folder/setup_work_projects.sh para funcionar corretamente
  - Aplique as boas práticas aplicadas no script dev/project-folder/setup_work_projects.sh para o script dev/project-folder/setup_personal_projects.sh
  - No script de dev/setup_project.sh list os projetos a partir do 
  - Ajustar os scripts: 
    - dev/setup_personal_projects.sh
    - dev/setup_work_projects.sh
  - Ajustar o ~/.ssh/config que atualmente é: 

    ```
    Include $HOME/.colima/ssh_config

    Host github.com
      HostName github.com
      User git
      IdentityFile $HOME/.ssh/id_rsa_work
      IdentitiesOnly yes
      Match exec "git config --get remote.origin.url 2>/dev/null | grep -qE '^git@github.com:davipeterlini(/|$)'"
        IdentityFile $HOME/.ssh/id_rsa_personal

    Host bitbucket.org
      HostName bitbucket.org
      User git
      IdentityFile $HOME/.ssh/id_rsa_bb_work
      IdentitiesOnly yes 
    ```

    Eu preciso que essa configuração acima seja ajustada para respeitar as seguintes regras 
      - Se o repo for da URL: git@github.com:CI-T-HyperX ou git@github.com:davipeterlinicit ele deve usar o $HOME/.ssh/id_rsa_work e o usuário davipeterlinicit (isso para push o pull)
      - Se o repo for da URL: git@github.com:davipeterlini ou git@github.com:futureit ou git@github.com:medicalclub  ele deve usar o $HOME/.ssh/id_rsa_personal e o usuário davipeterlini (isso para push o pull)

    para a respotas altere o arquivo: dev/assets/ssh-git/config-ssh-v2 com a forma correta de configuração para que tudo funcione corretamente 
    ou seja ao estar em um repo git@github.com:CI-T-HyperX ou git@github.com:davipeterlinicit ele use o usuário davipeterlinicit e assim por diante
  - Teste para verificar se o esquema do config funcionou 
- 04/05/2025
  - Ajustar o arquivo config-ssh-v4 para que funcione corretamente entre as versões do git
    o que não funciona nesse arquivo pe o comando: git config --get remote.origin.url 2>/dev/null | grep -qE '^git@github.com:CI-T-HyperX(/|$)'
  - Colocar a execução dos scripts abaixo no dev/setup.sh
    github/configure_multi_ssh_github_keys.sh
    bitbucket/configure_multi_ssh_bitbucket_keys.sh
  - Ajustar a arquivo de configuração .ssh/config para fazer da forma correta
  - Ajustar o scrip de ssh para configurar as coisas da forma correta 
- 05/06/2025
  - Atualiza o script de configuração das chaves sshs do git para funcionar corretamente 
    - Crie Alis no arquivo .gitconfig
  - O que deve ser salvo no .gitconfig é a url do ssh e não http conforme exemplo abaixo
- 06/06/2025
  - Ajustar para que o script setup_ssh_config.sh funcione salvando de forma correta no .gitconfig da raiz do profile  
  - Deixar o script bitbucket/configure_multi_ssh_bitbucket_keys.sh com a mesma estrutura do script github/configure_multi_ssh_github_keys.sh
  - Assim que concluir a execução no script setup_ssh_config.sh abra o vscode com os arquivos abertos: ~/.gitconfig e ~/.ssh/config
  - 


  - o script setup_ssh_config.sh está duplicando os valores dentro do .gitconfig e não deve duplicar 


  - Eu preciso que ao executar o script setup_projects.sh sejam feitos os seguintes passos 
    - Abra um seletor para que o usuário escolha entre personal e work, de acordo com os arquivos de .evn da pasta assests/envs
    - Carrege as variaveis do arquivo env.xxxxx escolhido para a execução 
    - Na sequência crie as pastas a partir da variável: PROJECT_DIR
    - E depois execute o clone do repo a partir da variável: PROJECT_REPOS
    Essa variável contem o repo e a pasta onde deve ser colocado
  - 


- Problemas extensão 
  - Locking
    - Quando estou executando algo e ele está no meu da geração de arquivo e finalizo causa um locking no vscode deixando o usuário travado em várias coisas que ele está fazendo 
    - Quando clico em cancel a operação realmente está parando
  - Agent com GPT4
    - Precisa de uma regra - sempre que for executar algo usando o modo agent com o modelo gpt-4o faça as alterações e implmentações sugeridas 


  - Ajustar o config do ssh para que possa funcionar da forma correta nos repos corretos 

  - Colocar a configuração do NPMTOKEN no script de trabalho 
    - Verificar como fazer no repo do llm orchastrator
    - Gerar o git do token via GH e gravar no .env e no .zshrc
  - Ajustar o .zshrc para que possa deixar separado as variáveis de ambiente corretamente
  - Instalação do MCP do flow
    - Fazer donwload do MCP do flow e Instalar
      https://drive.usercontent.google.com/download?id=1iADIQiNa7Mw5Fz4VjWkR55bcoWC7an7q&export=download&authuser=0
    - Intalação
      - npm i -g <PATH_TO_PACKAGE>/mcp-ciandt-flow.tgz
  - Crie um script na pasta dev para executar os scripts dessa pasta selecionando a partir de trabalho e pessoal
    - Coloque os scripts do git aqui para confiugração correta
  - Atualizar o script do setup geral para executar a instalação e configuração do docker no Mac e no Linux
    - Atualizar script do docker para no final executar um teste em uma imagem simples do docker e assim que o teste for concluído dar down no docker e remover a imagem, lembre-se de iniciar o colima para subir o docker 










  - Necessário alterar o config para não commitar mais com o user da CI&T no git pessoal 
    - https://github.com/davipeterlini/scripts-shell/graphs/contributors


  - Vscode 
    - Configurar o botão de F2 no visual code 
    - Mudar linguagem de exibição do vscode para inglês







Para aplicar essa visualização a todas as pastas, clique em "Usar como Padrão".

    - Verificar script para configurar o multi ssh na máquina
    - Criar script para executar o passo a passo do git em máquina nova 


    - Criar um script para verificar se existe o GITHUB-comprefixo
      Se sim crie outra variável no local profile com nome NPM_TOKEN e grave o mesmo valor da GITHUB_WORK
      se não existir crie rode o script generate-classic-token-gh-local e faça a criação do NPM_TOKEN




  - Alterar no script de build 
  - Instanciar o docker do windows e linux para fazer o build do script do coder e gerar o executável  
  - Testar no MAC
    - Remover o coder da máquina
  - Clonar VM do linux para testes










  - Finalizar testes de script de instalação no mac
  - Script do coder - Instalação e configuração
    - Geração de executável para windows, mac e linux
  - Ver complice de execução de brew na máquina do dev (Ver com a CI&T)
  
  - Configurar o python e o conda
  - Acrescentar mais scripts no setup_enviroment.sh
  - Testar scripts do linux
  



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