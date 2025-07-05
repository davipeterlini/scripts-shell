# GitHub SSH Configuration Tools

Este diretório contém scripts e arquivos de configuração para gerenciar múltiplas identidades SSH para GitHub e outros serviços Git.

## Índice

- [Visão Geral](#visão-geral)
- [Estrutura de Arquivos](#estrutura-de-arquivos)
- [Scripts Disponíveis](#scripts-disponíveis)
  - [setup_ssh_config.sh](#setup_ssh_configsh)
- [Arquivos de Configuração](#arquivos-de-configuração)
  - [config-ssh-v1](#config-ssh-v1)
  - [config-ssh-v2](#config-ssh-v2)
  - [config-ssh-v3](#config-ssh-v3)
- [Uso](#uso)
- [Solução de Problemas](#solução-de-problemas)
- [Contribuição](#contribuição)

## Visão Geral

Este conjunto de ferramentas foi desenvolvido para facilitar o gerenciamento de múltiplas identidades SSH para diferentes contas do GitHub, Bitbucket e outros serviços Git. Isso é particularmente útil quando você precisa alternar entre contas pessoais e de trabalho no mesmo computador.

## Estrutura de Arquivos

```
github/
├── README.md                # Este arquivo
├── setup_ssh_config.sh      # Script principal para configurar o SSH
└── assets/
    ├── config-ssh-v1        # Configuração básica com hosts separados
    ├── config-ssh-v2        # Configuração com Match exec para seleção automática de chave
    └── config-ssh-v3        # Configuração avançada com múltiplos padrões de Match
```

## Scripts Disponíveis

### setup_ssh_config.sh

Este script configura automaticamente o arquivo `~/.ssh/config` com uma das três versões de configuração disponíveis.

**Funcionalidades:**

- Cria o diretório `~/.ssh` se não existir
- Faz backup do arquivo `~/.ssh/config` existente
- Permite escolher entre três versões de configuração
- Substitui variáveis de ambiente `$HOME` pelo valor real
- Define as permissões corretas (600) para o arquivo de configuração
- Exibe mensagens coloridas para melhor experiência do usuário

**Execução:**

```bash
cd /caminho/para/o/repositorio
./github/setup_ssh_config.sh
```

**Exemplo de saída:**

```
========================================
Configuração do SSH para GitHub
========================================

ℹ️  Fazendo backup do arquivo ~/.ssh/config existente...
✅ Backup criado: /home/usuario/.ssh/config.backup.20230615123456

========================================
Seleção da Versão
========================================

Selecione a versão do arquivo de configuração:
1) Versão 1
2) Versão 2
3) Versão 3
Escolha (1-3): 2

✅ Usando arquivo de configuração: config-ssh-v2

========================================
Configurando SSH
========================================

ℹ️  Configurando arquivo ~/.ssh/config...
✅ Permissões do arquivo definidas como 600 (leitura/escrita apenas para o proprietário)

========================================
Configuração Concluída
========================================

✅ O arquivo ~/.ssh/config foi configurado usando config-ssh-v2

ℹ️  As variáveis de ambiente $HOME foram substituídas pelo valor real: /home/usuario

========================================
Conteúdo do Arquivo Configurado
========================================

Include /home/usuario/.colima/ssh_config

Host github.com
  HostName github.com
  User git
  IdentityFile /home/usuario/.ssh/id_rsa_work
  IdentitiesOnly yes
  Match exec "git config --get remote.origin.url 2>/dev/null | grep -qE '^git@github.com:davipeterlini(/|$)'"
    IdentityFile /home/usuario/.ssh/id_rsa_personal

Host bitbucket.org
  HostName bitbucket.org
  User git
  IdentityFile /home/usuario/.ssh/id_rsa_bb_work
  IdentitiesOnly yes
----------------------------------------

========================================
Operação Finalizada com Sucesso!
========================================
```

## Arquivos de Configuração

### config-ssh-v1

Configuração básica que usa hosts separados para diferentes identidades. Ideal para quem prefere especificar explicitamente qual identidade usar.

**Características:**
- Usa hosts diferentes para cada identidade (github.com-work, github.com-personal)
- Requer especificação explícita do host ao clonar ou configurar repositórios
- Mais simples e direto

**Exemplo de uso:**
```bash
# Clonar usando a identidade de trabalho
git clone git@github.com-work:organização/repositorio.git

# Clonar usando a identidade pessoal
git clone git@github.com-personal:usuario/repositorio.git
```

### config-ssh-v2

Configuração intermediária que usa a funcionalidade `Match exec` para selecionar automaticamente a chave correta com base no URL remoto.

**Características:**
- Usa o host padrão (github.com) para todas as identidades
- Seleciona automaticamente a chave com base no URL remoto
- Inclui configuração para Colima (Docker/Kubernetes)

**Exemplo de uso:**
```bash
# Clonar qualquer repositório - a chave será selecionada automaticamente
git clone git@github.com:organização/repositorio.git
```

### config-ssh-v3

Configuração avançada similar à v2, mas com regras adicionais para o Bitbucket.

**Características:**
- Similar à v2, mas com regras de Match para Bitbucket também
- Oferece a maior flexibilidade para múltiplos serviços
- Ideal para quem trabalha com vários serviços Git

**Exemplo de uso:**
```bash
# Clonar qualquer repositório do GitHub ou Bitbucket
git clone git@github.com:organização/repositorio.git
git clone git@bitbucket.org:organização/repositorio.git
```

## Uso

1. **Preparação das chaves SSH:**
   
   Antes de usar estes scripts, certifique-se de ter gerado suas chaves SSH:

   ```bash
   # Gerar chave para conta de trabalho
   ssh-keygen -t rsa -b 4096 -C "seu.email@trabalho.com" -f ~/.ssh/id_rsa_work
   
   # Gerar chave para conta pessoal
   ssh-keygen -t rsa -b 4096 -C "seu.email@pessoal.com" -f ~/.ssh/id_rsa_personal
   ```

2. **Executar o script de configuração:**

   ```bash
   ./github/setup_ssh_config.sh
   ```

3. **Testar a configuração:**

   ```bash
   # Testar conexão com GitHub
   ssh -T git@github.com
   
   # Se estiver usando a configuração v1, teste também:
   ssh -T git@github.com-personal
   ssh -T git@github.com-work
   ```

## Solução de Problemas

### Problemas comuns:

1. **Permissões incorretas:**
   
   Se encontrar erros de permissão, certifique-se de que seu diretório ~/.ssh e arquivos têm as permissões corretas:
   
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/config
   chmod 600 ~/.ssh/id_rsa*
   ```

2. **Chave não reconhecida:**
   
   Certifique-se de que o agente SSH está carregando suas chaves:
   
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_rsa_work
   ssh-add ~/.ssh/id_rsa_personal
   ```

3. **Erro "Too many authentication failures":**
   
   Isso pode acontecer quando o SSH tenta muitas chaves. Use a opção `-o IdentitiesOnly=yes` ao conectar:
   
   ```bash
   ssh -o IdentitiesOnly=yes -T git@github.com
   ```

## Contribuição

Sinta-se à vontade para contribuir com este projeto criando novas versões de configuração ou melhorando os scripts existentes. Para contribuir:

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-configuracao`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova configuração'`)
4. Push para a branch (`git push origin feature/nova-configuracao`)
5. Crie um novo Pull Request