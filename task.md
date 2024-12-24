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