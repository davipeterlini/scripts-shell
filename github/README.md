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