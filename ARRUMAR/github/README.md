# GitHub Scripts

Este diretório contém vários scripts para configurar e gerenciar contas do GitHub, chaves SSH e tokens de acesso. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### connect_git_ssh_account.sh
Este script conecta uma conta GitHub usando uma chave SSH específica. Ele permite ao usuário escolher uma identidade (chave SSH) e adicioná-la ao agente SSH.

### install_configure_github_gh.sh
Este script instala e configura a CLI do GitHub (`gh`) usando Homebrew. Ele também remove qualquer variável de ambiente `GITHUB_TOKEN` existente e autentica o usuário no GitHub CLI.

### save_github_token_to_profile.sh
Este script salva um token de acesso pessoal do GitHub no perfil do shell escolhido pelo usuário. Ele garante que a variável de ambiente `GITHUB_TOKEN_PERSONAL` esteja definida e a adiciona ao arquivo de perfil.

### setup_multiple_github_accounts.sh
Este script configura múltiplas contas do GitHub no mesmo sistema. Ele permite ao usuário gerenciar várias identidades SSH e alternar entre diferentes contas do GitHub.

### ssh_multiple_github_accounts.sh
Este script configura o SSH para gerenciar múltiplas contas do GitHub. Ele permite ao usuário adicionar várias chaves SSH ao agente SSH e configurar o SSH para usar diferentes chaves para diferentes contas do GitHub.

## Outros Scripts

### generate_ssh_key.sh
Este script gera uma nova chave SSH para um endereço de email do Gmail fornecido pelo usuário. Ele também copia a chave pública SSH para a área de transferência para facilitar a adição ao GitHub.

### gh
Este documento fornece instruções para resolver problemas de autenticação com a CLI do GitHub (`gh`). Ele orienta o usuário a limpar a variável de ambiente `GITHUB_TOKEN`, autenticar-se no GitHub e adicionar segredos ao repositório.

### gh_v1
Este documento fornece instruções para gerar um token de acesso pessoal (PAT) usando a CLI do GitHub (`gh`). Ele orienta o usuário a autenticar-se no GitHub, gerar um novo token e adicioná-lo como um segredo no GitHub Actions.

### githubpipeline
Este documento fornece um guia passo a passo para configurar e rodar o `deploy.yml` do GitHub Actions. Ele orienta o usuário a adicionar o arquivo `deploy.yml` ao repositório, configurar segredos no GitHub e verificar a execução do workflow.

### install_configure_gh_API.sh
Este script instala a CLI do GitHub (`gh`) e configura um token de acesso pessoal (PAT) usando a API do GitHub. Ele verifica se há tokens existentes, cria novos tokens se necessário e armazena o token no perfil do shell do usuário.

### install_configure_gh_GH.sh
Este script instala a CLI do GitHub (`gh`) e configura um token de acesso pessoal (PAT) usando a CLI do GitHub. Ele verifica se há tokens existentes, cria novos tokens se necessário e armazena o token no perfil do shell do usuário.
Resumo: Gera o Classic Token remoto e disponibiliza local

## Scripts






# GitHub Scripts

Este diretório contém scripts relacionados à automação e configuração de repositórios GitHub. Abaixo está uma descrição detalhada de cada script presente nesta pasta.

## Scripts

### 1. `configure_two_ssh_github_keys.sh`
**Descrição:** Este script configura duas chaves SSH distintas para serem usadas com diferentes contas do GitHub. Ele permite que você gerencie múltiplas contas GitHub no mesmo ambiente local.

**Uso:**
```bash
./configure_two_ssh_github_keys.sh
```

---

### 2. `generate-classic-token-gh-local.sh`
**Descrição:** Este script gera um token clássico de acesso pessoal (Personal Access Token - PAT) para o GitHub e o armazena localmente para ser usado em operações autenticadas, como push e pull.

**Uso:**
```bash
./generate-classic-token-gh-local.sh
```

---

### 3. `connect_git_ssh_account.sh`
**Descrição:** Este script conecta uma conta GitHub ao seu ambiente local usando uma chave SSH previamente configurada. Ele atualiza o arquivo de configuração SSH para associar a chave à conta GitHub.

**Uso:**
```bash
./connect_git_ssh_account.sh
```

---

## Sequência de Execução dos Scripts

Para configurar corretamente o ambiente GitHub, siga a sequência abaixo:

1. **Configure as chaves SSH para múltiplas contas:**
   Execute o script `configure_two_ssh_github_keys.sh` para criar e configurar as chaves SSH necessárias.

   ```bash
   ./configure_two_ssh_github_keys.sh
   ```

2. **Gere um token clássico de acesso pessoal:**
   Execute o script `generate-classic-token-gh-local.sh` para criar e armazenar um token de acesso pessoal.

   ```bash
   ./generate-classic-token-gh-local.sh
   ```

3. **Conecte uma conta GitHub usando SSH:**
   Use o script `connect_git_ssh_account.sh` para associar uma chave SSH a uma conta GitHub específica.

   ```bash
   ./connect_git_ssh_account.sh
   ```

Seguindo esta ordem, você garantirá que o ambiente esteja configurado corretamente para trabalhar com múltiplas contas GitHub e autenticação segura.

---

## Como Executar os Scripts

1. Certifique-se de que os scripts possuem permissões de execução:
   ```bash
   chmod +x script_name.sh
   ```

2. Execute o script desejado:
   ```bash
   ./script_name.sh
   ```

---

## Contribuição

Se você deseja adicionar ou modificar scripts nesta pasta, siga as diretrizes abaixo:
1. Certifique-se de que o script está bem documentado.
2. Teste o script antes de enviá-lo.
3. Envie um pull request com uma descrição clara das alterações.

---