- 30/06/2025
  - Ajuste no grand_permissions 
  - Ajustar o script setup_enviroment.sh
  - Ajustes para adaptar os scripts e melhorar a forma de instalação 
- 01/07/2025
  - Ajuste no load-env para carregar envs do assets via parametro 
  - Completar os ajustar o script setup_enviroment.sh
  - Estruturar scripts setup_enviroment.sh para: 
    - Carregar as envs 
    - Detectar o sistema operacional automáticamente 
    - liberar permissão de execução nos scripts 
    - Instalar os apps 
      - Mudar como pega as envs para instalar os apps 
      - Mudar forma de declaração dos scritps
      - Ajustar o script display_menu
      - Ajustar o script install_brew_apps para printar os apps que serão instalados
      - Arrumar os scripts do linux para instalação de apps
    - Ajustar o script de setup do iterm2
      - Configurar o iterm para que ao abrir um aba sempre abrir no dir corrente 
      - Criar no script função para configurar o iterm para sempre abrir da onde parou e sempre que for abrir uma nova aba abrir a partir do ultimo path selecionado
      - Failed to load settings from custom directory. Falling back to local copy.
        - Missing or malformed file at "~/.iterm2"
    - Ajustar o script de setup do terminal
    - Ajustes para o script do Github
    - Ajustes para o script do Bitbucket
    - Ajuste o script de confiugração do SSH 
    - Ajuste o script de configuração dos projetos
- 02/07/2025
  - Crie um script para a configuração do teclado no mac de acordo com os passos abaixo (https://github.com/lailsonbm/ABNT2-Layout?tab=readme-ov-file)
    Layout de teclado padrão ABNT2 Brasileiro para Mac OS X, útil para quem usa teclado externo neste padrão.
      ##Instruções

      Baixe e abra o arquivo compactado(https://github.com/lailsonbm/ABNT2-Layout?tab=readme-ov-file#:~:text=e%20abra%20o-,arquivo%20compactado,-.).

      Na pasta em que o arquivo foi descompactado, localize o arquivo Brazilian ABNT2.bundle.

      Copie este arquivo para a pasta ~/Library/Keyboard Layouts (para que o layout fique disponível apenas para o seu usuário) OU /Library/Keyboard Layouts/ (para que o layout fique disponível para todos os usuários).

      Faça Logout (Finalizar Sessão) e entre novamente no sistema para que o layout seja carregado.

      Nas Preferências do Sistema (System Preferences), vá em Idioma & Texto (Language & Text). No item Leiautes de Teclado (Input Sources), selecione Brasileiro ABNT2 (Brazilian ABNT2). Se você usar apenas o teclado ABNT2, desmarque os outros itens.

      Pronto, agora você pode usar o teclado normalmente.
  - Aplique o esquema de prints do colors_message do utils no script criado e mova ele para mac/setup e depois coloque uma chamada dele na função _setup_mac do script @setup_enviroment.sh 
  - no script deve ter a opção de fazer o logout do mac via terminal, porém perguntando ao usuário 
  - Acrescente no script o comando ls -al ~/Library/Keyboard Layouts após finalizar a copia 
  - Dentro da pasta gcloud
    - Crie um script com o nome setup_gcloud que executa a instalação (gcloud/install_gcloud_tools.sh) do gcloud e a configuração (Autenticação seleção de projeto - gcloud/config_gcloud.sh
      - nesses scripts use o esquema de colors_message do ultils
      - mova o script de setup do gcloud para a pasta gcloud
      - Os comentários e mensagens devem estar em inglês nos scripts da pasta gcloud
      - Aplique o clean code e clean arquitetura nos scripts da pasta gcloud
    - Chame o script de setup_gcloud dentro do script setup_enviroment.sh
  - Gere uma regra parecida com a estrutura da regra abaixo para gerar comentário e mensagens dentro do código tudo em inglês 
      name: edit files
      rule: Every time tools run to refactor or change code do not generate intermediate files. Change existing files or what was informed in the context
    - resuma mais a descrição da regra para que fique curta e que faça o que foi pedido anterioormente 
  - Gere outra regra para sempre que gerar um script gerar com clean code e clean arquitecture
  - escopo de geração de códifo, não importando qual a liguagem 
  - Tem como mover um zip para dentro de uma VM criada com UTM ?
    - Como faço a transferencia via script do mac (host) para uma vm linux (ubuntu) no utm
    - Mova o script criado para a pasta flow_coder e depois mova os zips criados para dentro da VM
    - Adicione no readme as instruções de como configurar as vms no utm para que o script possa ser excecutado (adicione o passo a passo)
  - [IDE] Criação de ambiente virtualizado com ubuntu e windows 11
    - Instalação do Windows 11 Arm64 no utm 
    - Instalação do Ubuntu (ultima versão) Arm64 no utm 
    - Configuração e atualização do ubuntu 
    - Configuração e atualização do windows 
    - Criar script para instalação do utm nos SOs
    - Criar o script para instalação do vscode, jetbrains utlimate, jetbrains community edition no mac, linux e windows 
      - o script de mac e linux devem estar juntos 
      - renomeie o script install_dev_tools para install_ides
      - una os scripts vm/install_ides_linux.sh e vm/install_ides_mac.sh e o nome deve ser install_ides.sh
    - Crie um script com nome install_flow_coder, para instalar extenção flow coder no vscode e no , jetbrains utlimate, jetbrains community edition 
      - Considere tratativa para os diferentes SOs 
      - Considere a pasta de instalação de extensões no vscode e de plugins no jetbrains 
      - O script de mac e linux devem estar no mesmo script install_flow_coder.sh e o de windows install_flow_coder.bat
      - correção de como instalar o coder nas diferentes ide de acordo com os links 
        - jetBrains - https://downloads.marketplace.jetbrains.com/files/27434/780089/flow-coder-extension-0.2.0.zip?updateId=780089&pluginId=27434&family=INTELLIJ
        - vscode - ciandt-global.ciandt-flow
    - Crie um script com nome de open_ides para abrir as IDEs vscode, jetbrains utlimate, jetbrains community edition nos diferentes SO
      - lembre-se que o script de mac e linux devem estar juntos
      - Mova os scripts criados para a pasta VM e atualize o readem
    - Crie um script com nome de test_flow_coder para abrir as IDEs vscode, jetbrains utlimate, jetbrains community edition nos diferentes SO e executar um teste na extensão flow_coder de cada ide 
      - lembre-se que o script de mac e linux devem estar juntos
      - crie o script na pasta vm
    - Todos os scripts da pasta vm devem estar com comentários e mensagens em inglês 
    - Todos os scripts da pasta vm devem ter clean code e clean arquitecture
    - Crie um script para instalar o power shell no windows via cmd
    - Crie um script para zip dos scripts de linux e zip de scripts de windows
      - Permita que o usuário tenha opção do que quer fazer 
      - coloque na pasta flow_coder
    - Criar o script para subir os zips (escolhendo qual ou ambos) no bucket - https://console.cloud.google.com/storage/browser/flow-coder
      - crie o script na pasta flow_coder
      - no script deve existir: 
        - Verificação se o gcloud está configurado 
        - Verificação se o gcloud está autenticado 
        - Verificação da existencia dos zips
    - Crie um script que deve estar na raiz da pasta flow_coder e que executa os scripts conforme a sequência abaixo: 
      - flow_coder/create_script_zips.sh
      - flow_coder/upload_zips_to_gcs.sh
    - Atualização básica da VM do ubuntu
    - Zipar a VM do ubuntu criada e fazer backup no drive 
    - Backup da vm do ubuntu no drive
    - Atualização básica da VM do windows
    - Zipar a VM do windows criada e fazer backup no drive 
    - Backup da vm do windows no drive
    - Instalar os scripts na vm ubuntu - https://storage.googleapis.com/flow-coder/linux_scripts.zip
    - Crie um script com o nome de setup_test_flow_coder e coloque no script as chamadas dos scripts da pasta vm conforme sequência abaixo 
      - vm/install_utm.sh
      - vm/install_ides.sh
      - vm/install_flow_coder.sh
      - vm/install_ides.sh
      - vm/open_ides.sh
      - vm/test_flow_coder
      - Ajuste os scripts para fazer os imports corretamente 
    - Os scripts abaixo da pasta vm devem ter clean code e clean arquitecture
      - install_ides
      - install_flow_coder  
    - Os scripts abaixo da pasta vm devem ter clean code e clean arquitecture
      - install_utm
      - open_ides
    - Os scripts abaixo da pasta vm devem ter clean code e clean arquitecture
      - setup_test_flow_coder
      - test_flow_coder
    - Mude o nome da pasta vm para flow_coder
    - Mova os scripts abaixo para a pasta flow_coder/windows
      - install_powershell.bat
      - install_ides.sp1
      - install_flow_coder.bat
      - install_ides.sp1
      - open_ides.bat
      - test_flow_coder.sp1
    - Agora mova os do shell para a pasta 
    - Altere o script de flow_coder/unix/setup.sh para não executar mais o flow_coder/install_utm.sh
    - ajustes dos scripts de geração do zip dos scripts e subida no gcp
- 03/07/2025 
  - [IDE] Criação de ambiente virtualizado com ubuntu e windows 11
    - Ajustes nos scripts para manter o padrão
    - Remover a VM do ubuntu 
    - Baixar a VM salva 
    - Teste para ver se está funcionando
    - Teste para ver o tamanho do disco dentro da vm
      - Garantir que o tamanho está bom
    - Teste dos scripts no mac após modificação
    - ao executar o script ./flow_coder/linux/setup.sh nada é feito 
    - Se essa função for chamada por outro script deve detectar o os como é feito, porém não mostrar o menu e instalar tudo 
    - faça a mesma tratativa para o script @install_flow_coder.sh 
- 04/07/2025
  - [IDE] Criação de ambiente virtualizado com ubuntu e windows 11
    - Ajustes no script de instalar o flow coder no mac e linux
    - Ajustes finos nos scripts do linux
    - Ajustes finos nos scripts do windows 
      - Agora ajuste a estrutura de scripts do windows para que siga a mesma estrutura de dos scripts do linux, ou seja, diretórios, estrutura de cada scripts e utils
    - Crie um readme para cada pasta linux e windows e atualize o readme da pasta flow_coder apenas com os scripts que estão fora das pastas linux e windows
    - Ajustes da resolução de tela do windows 
    - aumento do disco da vm ubuntu
      - Instalação do gparted na VM 
      - Resize de disco via gparted
    - Execução dos scripts na VM ubuntu
      - Instalar a extensão no jetbrains - intelijj no ubuntu para ver o path onde foi instalado
      - alterar script para correção
    - Execução dos scripts na VM windows
  - scripts
    - Ajuste nas envs do script de setup_projects
    - No script @setup_projects.sh precisam ter as seguintes tratativas 
      - Quando for realizar o clone e a pasta já existir não realizar o clone e sim entre na pasta e realize o comando git pull origin main e depois continue o processo de clone
    - No script @setup_projects.sh precisam ter as seguintes tratativas 
      - Se o repo não existir pule  e continue para o proximo repo a ser clonado
    - Ajustes essas funções para usar o print do colors_message como as outras funções
    - no script de instalar_dockutil deve chamar o mac/install_homebrew.sh para conferir se o homebrew está instalado 
    - Atualização de repos se ele existir
    - Ajuste do scritp @setup_projects.sh para que ele volte ao menu abaixo quando finalizar a execução e coloque no menu um sair para que ao escolher a opção sair ele continue executando os scripts do setup_enviroment.sh na sequência
    1) /Users/davi.peterlini/scripts-shell/assets/.env.personal
    2) /Users/davi.peterlini/scripts-shell/assets/.env.work
    - Colocar o script dev/setup_global_env.sh para ser chamado na configuração de setup
      - Ajuste finos nesse script
    - Pedir acesso de adimin para o charles 
    - Remover o miniconda 
    - Remover o virtualbox 
    - Garantir que eles não são mais instalados no script de instalação 
    - Limpeza de cache do brew - brew cleanup      
    - Adicionar instalação do poetry via brew 
- 05/07/2025
  - [IDE] Criação de ambiente virtualizado com ubuntu e windows 11
  - Scripts    
    - Configurar o terminal para abrir o finger print quando pedir a senha no mac
    - crie um script de setup_mac na raiz da pasta mac ele deve ser semelhante ao @setup_dev.sh porém chamar todos os scripts de setup do mac como é chamado no @setup_enviroment.sh  na função _setup_mac
    - agora subistitua no @setup_enviroment.sh a funão setup_mac pela chamada desse script 
    - Corrigir problemas do iterm2
- 08/07/2025
  - Ajuste no script de sync_drive_folders
    -  Remover a parte de criar o link simbólico para os repos da pasta ~/.coder-ide/no-commit
  - Adicionar o screen studio via brew e colocar isso no env 
  - Adicionando no script de install_homebrew e remover o brew analytics off
  - crie um script para a instalação das seguintes aplicações 
    - code claude - npm install -g @anthropic-ai/claude-code
    (https://docs.anthropic.com/en/docs/claude-code/overview)
    - codex - npm install -g @openai/codex
    configs - export OPENAI_API_KEY="your-api-key-here"
    (https://github.com/openai/codex)
    - npm install -g @google/gemini-cli
    (https://github.com/google-gemini/gemini-cli)
    config 
    export GEMINI_API_KEY="YOUR_API_KEY"

    Após instalar teste as aplicações 
    comandos de teste: 
      claude 
      codex
      gemini
  - aplique o clean code nesse codigoe crie um main 
  - 



    - Criar script para instalção de aplicativos de IA 
      - flow-coder 
      - claude 
      - codex 
      - coder cli 
    
    - Instalação do Python na versão correta 
    - Instalação do coder-cli
    - Instalação do flow-coder
    - crie um scrtipt para o setup desse repo a partir do que está escrito no git e coloque o script dentro da pasta scripts/setup.sh 
      - Dentro do setup coloque a instalação do poetry no mac e linux

    - Colocar o script dev/sync_drive_folders.sh para ser chamado na configuração de setup
      - Teste e ajustes finos 
    - Colocar o script dev/setup_global_env.sh para ser chamado na configuração de setup
      - Teste e ajustes finos        





    # Select environment
    select_environment
    selected_env=$env_file
    
    # Get directories from environment file
    project_dirs=$(get_env_directories "$selected_env")
    
    # If no directories found in env file, use default directories
    if [ -z "$project_dirs" ]; then
        print_info "Using default project directories"
        
        # Check if PROJECT_REPOS is defined
        if [ -n "$PROJECT_REPOS" ]; then
            print_info "Using repositories from PROJECT_REPOS variable"
            
            # Process each repository in PROJECT_REPOS
            IFS=',' read -ra repos <<< "$PROJECT_REPOS"
            for repo in "${repos[@]}"; do
                # Extract directory and repo name (format: "directory:repo_name")
                IFS=':' read -r dir repo_name <<< "$repo"
                
                # Create directory if it doesn't exist
                mkdir -p "$HOME/$dir" 2>/dev/null
                
                # Create symbolic link for this repository
                ln -sf "$HOME/.coder-ide/no-commit" "$HOME/$dir/$repo_name"
                
                # Add no-commit to .gitignore in the repository
                echo "no-commit/" >> "$HOME/$dir/$repo_name/.gitignore" 2>/dev/null
                
                print_success "Set up repository: $HOME/$dir/$repo_name"
            done
        else
            # Fallback to default directories if PROJECT_REPOS is not defined
            mkdir -p "$HOME/projects-cit/flow/coder-assistants" 2>/dev/null
            mkdir -p "$HOME/projects-personal" 2>/dev/null
            
            # Create symbolic links for default projects
            ln -sf "$HOME/.coder-ide/no-commit" "$HOME/projects-cit/flow/coder-assistants/flow-coder-extension"
            ln -sf "$HOME/.coder-ide/no-commit" "$HOME/projects-personal/scripts-shell"
            
            # Add no-commit to .gitignore in each project
            echo "no-commit/" >> "$HOME/projects-cit/flow/coder-assistants/flow-coder-extension/.gitignore" 2>/dev/null
            echo "no-commit/" >> "$HOME/projects-personal/scripts-shell/.gitignore" 2>/dev/null
        fi
    else
        # Create symbolic links for projects from environment
        for dir in $project_dirs; do
            if [ -d "$dir" ]; then
                print_info "Creating symbolic link for $dir"
                ln -sf "$HOME/.coder-ide/no-commit" "$dir"
                
                # Add no-commit to .gitignore
                echo "no-commit/" >> "$dir/.gitignore" 2>/dev/null
                print_success "Added no-commit to .gitignore in $dir"
            else
                print_info "Creating directory: $dir"
                mkdir -p "$dir"
                ln -sf "$HOME/.coder-ide/no-commit" "$dir"
                echo "no-commit/" >> "$dir/.gitignore" 2>/dev/null
            fi
        done
    fi



Teste do Flow Coder Extension em Contratos com VPN/Proxy Ativo
Este teste consiste em validar o funcionamento da extensão nas IDEs do Jetbrains ou no VS Code para os cenários de VPN/proxy ativo
    
  - Scripts
    - Criar pasta para virtualização 
    - Crie um script em shel para abrir a pasta ~/Library/Containers/com.utmapp.UTM/Data/Documents no finder

  - Rules
    - As funçoes precisam estar autoexplicativas
    - Remova os comentários de código e deixa apena os necessários


  






    - Crie um script de setup para o windows (.bat) para executar os scripts na ordem abaixo e siga a estrutura e engenharia do script de flow_coder/unix/setup.sh



    
    - no script setup_test_flow_coder para cada script que for ser executado deve ter uma pergunta se quer executar ou não isso deve estar dentro de cada main de cada script 

    - renomei a main de todos os scripts de unix com o nome do arquivo e acrescente as linhas abaixo no script  
      - if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
          install_apps "$@"
        fi
      - Se for necessário altere a estrutura das chamadas e source dos scripts




    - Mude o nome do script flow_coder/setup_test_flow_coder.sh para setup.sh e crie o do windows 
    - Ajuste o script setup.sp1 para seguir a ordem de execuação abaixo: 
      - install_powershell.bat
      - install_ides.sp1
      - install_flow_coder.bat
      - vm/install_ides.sp1
      - vm/open_ides.bat
      - vm/test_flow_coder.sp1




    - Crie um script para 


    - Os scripts install_flow_coder.bat e open_ides.bat não deveriam ser sp1 ? 

    - Zip dos scripts e colocar no bucket 
    - Baixar nas VMs e rodar 

    - Teste dos scripts na VM
    - Script para baixar as vms e configurar no UTM
    - Backup das VM em pasta no drive
    
    - Separe os scripts em pastas, unix e windows
    






  - O layout do teclado precisa ser arrumado está com o problema do botão de aspas duplas 
  - Desinstalar aplicações 
    - brew uninstall miniconda
    - brew uninstall virtualbox







    - Deixe os comentários e mensagens dos scripts do @codebase em inglês
  

  - Criar os scripts de windows para configuração da vm do windows  





  - Ajuste no script de setup.sh 
  - Ajustes no script do bitbucket/setup_bitbucket_accounts.sh




  - Configuracoes do mac
  - mostrar icone de som na barra 
  - mostrar icone de bluetooth na barra 
  - mostrar icone do teclado na barra
  - configurar teclado para no fn modar de tipo de teclado 
  - desligar retroiluminao apos 10 segundos 
  - diminuir barra docs do mac 
  - habilitar pasta home no finder do mac
- Scripts

- eu náo quero que fique pedindo senha para instala
- Antes de tudo instalar o iterm se estiver rodando no mac 
- náo configurou corretamente o terminal ao instalar tudo do setup 



davipeterlinicit







- Logs (Épico)
  
  - Flow Coder - LLM Prompt ... (Story)
    - Melhoria de log 
    - Prompt que o usuário envio, System prompts 
    - Remoção do arquivos abertos 
    - Listagem apenas dos arquivos 
    - Aplicar um separador - ##################################################################################################
   - Flow Coder - LLM Request ... (Story)
    - Chamada (URL)
    - Body
    - Tempo de Request 
    - Tempo de Response 
    - Esquema do token
    - ...
- Tratativa de erros (Épico)
  - Skype de erros do LLM (Falar Pierre) 
    - 400, 500 - 429, 404, 403
    - Voltar amigável para o usuário
    400 - Erro ao consultar llm
    500 - LLM fora do ar 

  - Erros Atuais, já mapeados
    - Modal com erros amigáveis (nome aos bois)
  - LLM - Premature 
  - Modo agent
     
  - ...
  - ...
  
- Melhoria de Contexto (Epico)
  - Sugestão de troca de chat




    - Flow Coder Load do MCP ... (Story)
      - Basico de MCP
      - Erro por que não conseguiu conectar no MCP
    - Flow Coder LLM Load Models ... (Story)
    - Flow Coder Agent Mode ... (Story)
    - Flow Coder Chat Mode ... (Story)
    - Flow Coder Load de Docs ... (Story)
        - Exemplo: URL precisa de login





- Tratativa de erros (Épico)
    - Erros Amigáveis 
    - Modal com erros amigáveis 
