#!/bin/bash

# Importar o colors_message.sh para exibir mensagens coloridas
if [ -f "utils/colors_message.sh" ]; then
  source utils/colors_message.sh
else
  echo "[ERRO] O script utils/colors_message.sh não foi encontrado."
  exit 1
fi

# Função para listar os projetos disponíveis
list_projects() {
  if [ -f "utils/list_projects.sh" ]; then
    print_info "Listando projetos disponíveis:"
    bash utils/list_projects.sh
  else
    print_error "O script utils/list_projects.sh não foi encontrado."
    exit 1
  fi
}

# Função para executar o script de configuração escolhido
execute_setup_script() {
  local script_path=$1

  if [ -f "$script_path" ]; then
    print_info "Executando $script_path..."
    bash "$script_path"
  else
    print_error "O script $script_path não foi encontrado."
    exit 1
  fi
}

# Função principal
main() {
  list_projects

  print_info "\nEscolha o script de configuração a ser usado:"
  print_info "1) dev/setup_personal_projects.sh"
  print_info "2) dev/setup_work_projects.sh"
  print_info "Digite o número correspondente à sua escolha: "
  read -p "" choice

  case $choice in
    1)
      execute_setup_script "dev/setup_personal_projects.sh"
      ;;
    2)
      execute_setup_script "dev/setup_work_projects.sh"
      ;;
    *)
      print_error "Opção inválida. Saindo."
      exit 1
      ;;
  esac
}

# Executar a função principal
main