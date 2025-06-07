#!/bin/bash

# Importar o colors_message.sh para exibir mensagens coloridas
if [ -f "utils/colors_message.sh" ]; then
  source utils/colors_message.sh
else
  echo "[ERRO] O script utils/colors_message.sh não foi encontrado."
  exit 1
fi

# Verificar se a variável PROJECT_REPOS está definida
if [ -z "${PROJECT_REPOS[@]}" ]; then
  print_error "A variável PROJECT_REPOS não está definida ou está vazia."
  exit 1
fi

# Função para clonar repositórios
clone_repositories() {
  for repo_info in "${PROJECT_REPOS[@]}"; do
    # Dividir a string em link e diretório
    IFS="," read -r repo_link repo_dir <<< "$repo_info"

    if [ -z "$repo_link" ] || [ -z "$repo_dir" ]; then
      print_error "Informações do repositório inválidas: $repo_info"
      continue
    fi

    # Criar o diretório, se não existir
    if [ ! -d "$repo_dir" ]; then
      print_info "Criando diretório $repo_dir..."
      mkdir -p "$repo_dir"
    fi

    # Clonar o repositório
    print_info "Clonando repositório $repo_link em $repo_dir..."
    git clone "$repo_link" "$repo_dir"
  done
}

# Executar a função de clonagem
clone_repositories