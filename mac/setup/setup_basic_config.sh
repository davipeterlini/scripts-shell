#!/bin/bash

# Importar utilitários de cores para mensagens
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/mac/install_homebrew.sh"

# Configuração de teclado
configure_keyboard() {
    print_header_info "Configurando teclado..."
    
    # Inverter teclas Command e Control para todos os teclados
    print_info "Invertendo teclas Command e Control para todos os teclados..."
    
    # Configuração global para todos os teclados
    defaults write NSGlobalDomain com.apple.keyboard.modifiermapping -array-add \
        '<dict>
            <key>HIDKeyboardModifierMappingDst</key>
            <integer>2</integer>
            <key>HIDKeyboardModifierMappingSrc</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>HIDKeyboardModifierMappingDst</key>
            <integer>0</integer>
            <key>HIDKeyboardModifierMappingSrc</key>
            <integer>2</integer>
        </dict>'
    
    # Adicionar teclado Português -> Brasileiro ABNT2
    print_info "Adicionando teclado Português -> Brasileiro ABNT2..."
    defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
        '<dict>
            <key>InputSourceKind</key>
            <string>KeyboardLayout</string>
            <key>KeyboardLayout ID</key>
            <integer>1278</integer>
            <key>KeyboardLayout Name</key>
            <string>Portuguese</string>
        </dict>'
    
    # Mostrar ícone na barra para trocar teclado
    print_info "Habilitando ícone de teclado na barra de menu..."
    defaults write com.apple.TextInputMenu visible -bool true
    
    # Configurar botão FN para trocar layout de teclado
    print_info "Configurando botão FN para trocar layout de teclado..."
    defaults write com.apple.HIToolbox AppleFnUsageType -int 2
    
    return 0
}

# Configuração de trackpad
configure_trackpad() {
    print_header_info "Configurando trackpad..."
    
    # Inverter direção de rolagem do trackpad (Natural Scrolling)
    print_info "Invertendo direção de rolagem do trackpad..."
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    
    return 0
}

# Configuração de aparência
configure_appearance() {
    print_header_info "Configurando aparência..."
    
    # Ativar modo escuro
    print_info "Ativando modo escuro..."
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
    
    return 0
}

# Configuração da central de controle
configure_control_center() {
    print_header_info "Configurando Central de Controle..." 
    
    # Habilitar ícone de som na barra de menu
    print_info "Habilitando ícone de som na barra de menu..."
    defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true
    
    # Habilitar ícone de bluetooth na barra de menu
    print_info "Habilitando ícone de bluetooth na barra de menu..."
    defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
    
    # Habilitar ícone de temperatura (CPU/GPU) na barra de menu
    print_info "Habilitando monitoramento de temperatura na barra de menu..."
    # Nota: Isso geralmente requer um app de terceiros como iStat Menus
    defaults write com.bjango.istatmenus.status ShowCPU -bool true
    defaults write com.bjango.istatmenus.status ShowTemp -bool true
    
    return 0
}

# Configuração do Dock
configure_dock() {
    print_header_info "Configurando Dock..."
    
    # Reduzir tamanho do Dock
    print_info "Reduzindo tamanho do Dock..."
    defaults write com.apple.dock tilesize -int 36
    
    # Ocultar e exibir o Dock automaticamente
    print_info "Configurando Dock para ocultar automaticamente..."
    defaults write com.apple.dock autohide -bool false
    
    return 0
}

# Aplicar todas as alterações
apply_changes() {
    print_info "Aplicando alterações..."
    killall Dock 2>/dev/null || true
    killall ControlCenter 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
    
    return 0
}

# Configurar todas as opções
configure_all() {
    configure_keyboard
    configure_trackpad
    configure_appearance
    configure_control_center
    configure_dock
    apply_changes
    
    print_success "Configuração básica do macOS concluída!"
    print
    print_alert "Algumas alterações podem exigir reinicialização para ter efeito completo."
    print
    
    return 0
}

add_dock_utilities() {
  print_header_info "Adicionando separador e utilitários à Dock com dockutil..."
  instalar_dockutil

  # Remove duplicatas se já estiverem
  print_info "Removendo itens duplicados da Dock..."
  dockutil --remove "Disk Utility" --no-restart
  dockutil --remove "Activity Monitor" --no-restart
  dockutil --remove '' --section apps --no-restart  # remove separadores em branco

  # Adiciona separador
  print_info "Adicionando separador à Dock..."
  dockutil --add '' --type spacer --after Finder --no-restart

  # Adiciona Utilitário de Disco
  print_info "Adicionando Utilitário de Disco à Dock..."
  dockutil --add "/System/Applications/Utilities/Disk Utility.app" --no-restart

  # Adiciona Monitor de Atividade
  print_info "Adicionando Monitor de Atividade à Dock..."
  dockutil --add "/System/Applications/Utilities/Activity Monitor.app" --no-restart

  # Reinicia a Dock para aplicar
  print_info "Reiniciando a Dock para aplicar alterações..."
  killall Dock

  print_success "Dock configurada com sucesso!"
}

instalar_dockutil() {
  print_info "Verificando instalação do Homebrew..."
  
  # Usa a função install_homebrew do script mac/install_homebrew.sh
  install_homebrew

  print_info "Verificando instalação do dockutil..."

  if ! brew list dockutil &>/dev/null; then
    print_alert "Instalando dockutil..."
    brew install dockutil
  else
    print_success "dockutil já está instalado."
  fi

  print_success "Tudo pronto! Você pode usar o dockutil agora."
}

open_utilities() {
  print_info "Abrindo Monitor de Atividade..."
  open -a "Activity Monitor"

  print_info "Abrindo Utilitário de Disco..."
  open -a "Disk Utility"
}

# Função principal
setup_basic_config() {
    print_header_info "Basic Setup for MAC"

    if ! confirm_action "Do you want Setup Basic Mac ?"; then
        print_info "Skipping configuration"
        return 0
    fi
    # Verificar se está sendo executado como root
    if [[ $EUID -eq 0 ]]; then
        print_error "Este script não deve ser executado como root/sudo."
        exit 1
    fi
    
    # Verificar se está sendo executado em um macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "Este script só funciona em sistemas macOS."
        exit 1
    fi
    
    # Verificar argumentos para execução seletiva
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Uso: $0 [opção]"
        echo "Opções:"
        echo "  --keyboard    Configurar apenas teclado"
        echo "  --trackpad    Configurar apenas trackpad"
        echo "  --appearance  Configurar apenas aparência"
        echo "  --control     Configurar apenas central de controle"
        echo "  --dock        Configurar apenas dock"
        echo "  --all         Configurar tudo (padrão)"
        echo "  --help        Exibir esta ajuda"
        exit 0
    elif [[ "$1" == "--keyboard" ]]; then
        configure_keyboard
        apply_changes
    elif [[ "$1" == "--trackpad" ]]; then
        configure_trackpad
        apply_changes
    elif [[ "$1" == "--appearance" ]]; then
        configure_appearance
        apply_changes
    elif [[ "$1" == "--control" ]]; then
        configure_control_center
        apply_changes
    elif [[ "$1" == "--dock" ]]; then
        configure_dock
        add_dock_utilities
        open_utilities
        apply_changes
    else
        # Configurar tudo por padrão
        configure_all
    fi
    
    return 0
}

# Executar o script apenas se não estiver sendo importado
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_basic_config "$@"
fi