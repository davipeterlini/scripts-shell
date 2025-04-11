# Bitbucket Scripts

Este diretório contém vários scripts para configurar e gerenciar contas do Bitbucket e chaves SSH. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### generate_ssh_key_bitbucket.sh
Este script gera uma nova chave SSH para um endereço de email do Bitbucket fornecido pelo usuário. Ele também copia a chave pública SSH para a área de transferência para facilitar a adição ao Bitbucket.

### connect_bitbucket_ssh_account.sh
Este script conecta uma conta Bitbucket usando uma chave SSH específica. Ele permite ao usuário escolher uma identidade (chave SSH) e adicioná-la ao agente SSH.

### setup_multiple_bitbucket_accounts.sh
Este script configura múltiplas contas do Bitbucket no mesmo sistema. Ele permite ao usuário gerenciar várias identidades SSH e alternar entre diferentes contas do Bitbucket.

### ssh_multiple_bitbucket_accounts.sh
Este script configura o SSH para gerenciar múltiplas contas do Bitbucket. Ele permite ao usuário adicionar várias chaves SSH ao agente SSH e configurar o SSH para usar diferentes chaves para diferentes contas do Bitbucket.

## Passo a Passo para Gerar e Configurar Chave SSH no Bitbucket

### 1. Gerar a Chave SSH
Para gerar uma nova chave SSH para o Bitbucket, execute o seguinte comando:
```shell
chmod +x grant_permissions.sh
./grant_permissions.sh
./bitbucket/outros/generate_ssh_key_bitbucket.sh
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
./bitbucket/setup_multiple_bitbucket_accounts.sh
```

### 4. Gerenciar Múltiplas Contas Bitbucket com SSH
Para gerenciar múltiplas contas do Bitbucket usando SSH, execute o seguinte comando:
```shell
chmod +x grant_permissions.sh
./grant_permissions.sh
./bitbucket/ssh_multiple_bitbucket_accounts.sh
```

teste