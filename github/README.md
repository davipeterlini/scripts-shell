# GitHub Scripts

Este diretório contém vários scripts para configurar e gerenciar contas do GitHub e chaves SSH. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### configure_multi_ssh_github_keys.sh
Este script configura múltiplas chaves SSH para diferentes contas do GitHub. Ele permite ao usuário adicionar várias chaves SSH ao agente SSH e configurar o SSH para usar diferentes chaves para diferentes contas do GitHub.

### connect_git_ssh_account.sh
Este script conecta uma conta GitHub usando uma chave SSH específica. Ele permite ao usuário escolher uma identidade (chave SSH) e adicioná-la ao agente SSH.

### generate-classic-token-gh-local.sh
Este script gera um token clássico para autenticação com a API do GitHub. Ele guia o usuário através do processo de criação do token e armazena o token gerado em um arquivo de perfil para uso futuro.

## Passo a Passo para Gerar e Configurar Chave SSH no GitHub

### 1. Gerar a Chave SSH
Para gerar uma nova chave SSH para o GitHub, execute o seguinte comando:
```shell
chmod +x grant_permissions.sh
./grant_permissions.sh
./github/generate_ssh_key.sh
```

### 2. Conectar a Conta GitHub com a Chave SSH
Para conectar sua conta GitHub usando a chave SSH gerada, execute o seguinte comando:
```shell
chmod +x grant_permissions.sh
./grant_permissions.sh
./github/connect_git_ssh_account.sh
```

### 3. Configurar Múltiplas Contas GitHub
Se você precisar configurar múltiplas contas do GitHub no mesmo sistema, execute o seguinte comando:
```shell
chmod +x grant_permissions.sh
./grant_permissions.sh
./github/configure_multi_ssh_github_keys.sh
```