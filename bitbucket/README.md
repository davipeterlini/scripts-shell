# Bitbucket Scripts

Este diretório contém vários scripts para configurar e gerenciar contas do Bitbucket e chaves SSH. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### configure_multi_ssh_bitbucket_keys.sh
Este script configura múltiplas chaves SSH para diferentes contas do Bitbucket. Ele permite ao usuário adicionar várias chaves SSH ao agente SSH e configurar o SSH para usar diferentes chaves para diferentes contas do Bitbucket.

### connect_bitbucket_ssh_account.sh
Este script conecta uma conta Bitbucket usando uma chave SSH específica. Ele permite ao usuário escolher uma identidade (chave SSH) e adicioná-la ao agente SSH.

### generate-classic-token-bb-local.sh
Este script gera um token clássico para autenticação com a API do Bitbucket. Ele guia o usuário através do processo de criação do token e armazena o token gerado em um arquivo de perfil para uso futuro.

## Passo a Passo para Gerar e Configurar Chave SSH no Bitbucket

### 1. Gerar a Chave SSH
Para gerar uma nova chave SSH para o Bitbucket, execute o seguinte comando:
```shell
chmod +x grant_permissions.sh
./grant_permissions.sh
./bitbucket/generate_ssh_key_bitbucket.sh
```

### 2. Conectar a Conta Bitbucket com a Chave SSH
Para conectar sua conta Bitbucket usando a chave SSH gerada, execute o seguinte comando:
```shell
chmod +x grant_permissions.sh
./grant_permissions.sh
./bitbucket/connect_bitbucket_ssh_account.sh
```

### 3. Configurar Múltiplas Contas Bitbucket
Se você precisar configurar múltiplas contas do Bitbucket no mesmo sistema, execute o seguinte comando:
```shell
chmod +x grant_permissions.sh
./grant_permissions.sh
./bitbucket/configure_multi_ssh_bitbucket_keys.sh
```