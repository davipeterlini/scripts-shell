# Shell Utils Library Makefile
# Makefile para empacotamento e distribuição da biblioteca

# Configurações
LIB_NAME = shell-utils
VERSION = 1.0.0
INSTALL_DIR = /usr/local/lib
BIN_DIR = /usr/local/bin
PACKAGE_DIR = ./package
BUILD_DIR = ./build

# Detectar OS
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    OS = linux
endif
ifeq ($(UNAME_S),Darwin)
    OS = macos
endif

# Cores para output
RED = \033[1;31m
GREEN = \033[1;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m

.PHONY: all clean install uninstall test package deb rpm homebrew help

# Target padrão
all: help

# Ajuda
help:
	@echo "$(BLUE)Shell Utils Library - Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)Targets disponíveis:$(NC)"
	@echo "  install        - Instalar globalmente"
	@echo "  uninstall      - Remover instalação global"
	@echo "  test           - Executar testes"
	@echo "  package        - Criar estrutura de empacotamento"
	@echo "  deb            - Criar pacote .deb (Linux)"
	@echo "  rpm            - Criar pacote .rpm (Linux)"
	@echo "  homebrew       - Preparar formula Homebrew (macOS)"
	@echo "  clean          - Limpar arquivos temporários"
	@echo "  help           - Mostrar esta ajuda"
	@echo ""
	@echo "$(YELLOW)Exemplos:$(NC)"
	@echo "  sudo make install"
	@echo "  make package"
	@echo "  make deb"

# Instalar globalmente
install:
	@echo "$(BLUE)Instalando $(LIB_NAME) globalmente...$(NC)"
	@install -d $(INSTALL_DIR)
	@install -d $(BIN_DIR)
	@install -m 755 shell-utils.sh $(INSTALL_DIR)/$(LIB_NAME).sh
	@echo '#!/bin/bash' > $(BIN_DIR)/$(LIB_NAME)
	@echo 'source "$(INSTALL_DIR)/$(LIB_NAME).sh"' >> $(BIN_DIR)/$(LIB_NAME)
	@echo 'shell_utils_info' >> $(BIN_DIR)/$(LIB_NAME)
	@chmod +x $(BIN_DIR)/$(LIB_NAME)
	@echo "$(GREEN)✅ Instalado com sucesso!$(NC)"
	@echo "$(BLUE)Para usar: source \"$(INSTALL_DIR)/$(LIB_NAME).sh\"$(NC)"

# Desinstalar
uninstall:
	@echo "$(BLUE)Removendo $(LIB_NAME)...$(NC)"
	@rm -f $(INSTALL_DIR)/$(LIB_NAME).sh
	@rm -f $(BIN_DIR)/$(LIB_NAME)
	@echo "$(GREEN)✅ Removido com sucesso!$(NC)"

# Executar testes
test:
	@echo "$(BLUE)Executando testes...$(NC)"
	@bash test/test-runner.sh
	@echo "$(GREEN)✅ Testes concluídos!$(NC)"

# Criar estrutura de empacotamento
package: clean
	@echo "$(BLUE)Criando estrutura de empacotamento...$(NC)"
	@mkdir -p $(PACKAGE_DIR)
	@mkdir -p $(BUILD_DIR)
	@echo "$(GREEN)✅ Estrutura criada!$(NC)"

# Criar pacote .deb (Debian/Ubuntu)
deb: package
	@echo "$(BLUE)Criando pacote .deb...$(NC)"
	@mkdir -p $(PACKAGE_DIR)/DEBIAN
	@mkdir -p $(PACKAGE_DIR)/usr/local/lib
	@mkdir -p $(PACKAGE_DIR)/usr/local/bin
	@mkdir -p $(PACKAGE_DIR)/usr/share/doc/$(LIB_NAME)
	
	# Copiar arquivos
	@cp shell-utils.sh $(PACKAGE_DIR)/usr/local/lib/
	@chmod +x $(PACKAGE_DIR)/usr/local/lib/shell-utils.sh
	
	# Criar wrapper
	@echo '#!/bin/bash' > $(PACKAGE_DIR)/usr/local/bin/$(LIB_NAME)
	@echo 'source "/usr/local/lib/shell-utils.sh"' >> $(PACKAGE_DIR)/usr/local/bin/$(LIB_NAME)
	@echo 'shell_utils_info' >> $(PACKAGE_DIR)/usr/local/bin/$(LIB_NAME)
	@chmod +x $(PACKAGE_DIR)/usr/local/bin/$(LIB_NAME)
	
	# Criar control file
	@echo "Package: $(LIB_NAME)" > $(PACKAGE_DIR)/DEBIAN/control
	@echo "Version: $(VERSION)" >> $(PACKAGE_DIR)/DEBIAN/control
	@echo "Section: utils" >> $(PACKAGE_DIR)/DEBIAN/control
	@echo "Priority: optional" >> $(PACKAGE_DIR)/DEBIAN/control
	@echo "Architecture: all" >> $(PACKAGE_DIR)/DEBIAN/control
	@echo "Depends: bash (>= 4.0)" >> $(PACKAGE_DIR)/DEBIAN/control
	@echo "Maintainer: Your Name <your.email@domain.com>" >> $(PACKAGE_DIR)/DEBIAN/control
	@echo "Description: Shell utilities library for automation" >> $(PACKAGE_DIR)/DEBIAN/control
	@echo " A comprehensive shell library providing utilities for automation and development." >> $(PACKAGE_DIR)/DEBIAN/control
	
	# Copiar documentação
	@cp README.md $(PACKAGE_DIR)/usr/share/doc/$(LIB_NAME)/
	@gzip -9 -c README.md > $(PACKAGE_DIR)/usr/share/doc/$(LIB_NAME)/README.gz
	
	# Criar pacote
	@dpkg-deb --build $(PACKAGE_DIR) $(BUILD_DIR)/$(LIB_NAME)_$(VERSION)_all.deb
	@echo "$(GREEN)✅ Pacote .deb criado: $(BUILD_DIR)/$(LIB_NAME)_$(VERSION)_all.deb$(NC)"

# Criar pacote .rpm (Red Hat/CentOS/Fedora)
rpm: package
	@echo "$(BLUE)Criando pacote .rpm...$(NC)"
	@mkdir -p $(BUILD_DIR)/rpm/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
	
	# Criar spec file
	@echo "Name: $(LIB_NAME)" > $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "Version: $(VERSION)" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "Release: 1%{?dist}" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "Summary: Shell utilities library" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "License: MIT" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "BuildArch: noarch" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "Requires: bash >= 4.0" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "%description" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "A comprehensive shell library providing utilities for automation and development." >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "%install" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "mkdir -p %{buildroot}/usr/local/lib" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "mkdir -p %{buildroot}/usr/local/bin" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "cp $(PWD)/shell-utils.sh %{buildroot}/usr/local/lib/" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "echo '#!/bin/bash' > %{buildroot}/usr/local/bin/$(LIB_NAME)" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "echo 'source \"/usr/local/lib/shell-utils.sh\"' >> %{buildroot}/usr/local/bin/$(LIB_NAME)" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "chmod +x %{buildroot}/usr/local/bin/$(LIB_NAME)" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "%files" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "/usr/local/lib/shell-utils.sh" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "/usr/local/bin/$(LIB_NAME)" >> $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	
	# Construir RPM
	@rpmbuild --define "_topdir $(PWD)/$(BUILD_DIR)/rpm" -bb $(BUILD_DIR)/rpm/SPECS/$(LIB_NAME).spec
	@echo "$(GREEN)✅ Pacote .rpm criado em: $(BUILD_DIR)/rpm/RPMS/noarch/$(NC)"

# Preparar formula Homebrew (macOS)
homebrew: package
	@echo "$(BLUE)Preparando formula Homebrew...$(NC)"
	@mkdir -p $(BUILD_DIR)/homebrew
	
	# Criar formula
	@echo 'class ShellUtils < Formula' > $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '  desc "Shell utilities library for automation and development"' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '  homepage "https://github.com/seu-usuario/shell-utils"' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '  url "https://github.com/seu-usuario/shell-utils/archive/v$(VERSION).tar.gz"' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '  version "$(VERSION)"' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '  # sha256 "..."  # Calcular hash do arquivo' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '  def install' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '    lib.install "libs/shell-utils.sh"' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '    bin.write_exec_script lib/"shell-utils.sh"' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '  end' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '  test do' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '    system "#{bin}/shell-utils"' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo '  end' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	@echo 'end' >> $(BUILD_DIR)/homebrew/$(LIB_NAME).rb
	
	@echo "$(GREEN)✅ Formula Homebrew criada: $(BUILD_DIR)/homebrew/$(LIB_NAME).rb$(NC)"
	@echo "$(BLUE)Para usar: brew install ./$(BUILD_DIR)/homebrew/$(LIB_NAME).rb$(NC)"

# Limpar arquivos temporários
clean:
	@echo "$(BLUE)Limpando arquivos temporários...$(NC)"
	@rm -rf $(PACKAGE_DIR)
	@rm -rf $(BUILD_DIR)
	@echo "$(GREEN)✅ Limpeza concluída!$(NC)"

# Informações sobre o sistema
info:
	@echo "$(BLUE)Informações do sistema:$(NC)"
	@echo "OS: $(OS)"
	@echo "Lib: $(LIB_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Install Dir: $(INSTALL_DIR)"
	@echo "Bin Dir: $(BIN_DIR)"