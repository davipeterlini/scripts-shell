FROM alpine:latest

# Instala dependências para Linux, macOS e Windows
RUN apk add --no-cache \
    dpkg \
    dpkg-dev \
    mingw-w64 \
    bash \
    curl \
    file \
    nsis \
    xorriso \
    make \
    gcc \
    g++ \
    libbz2 \
    zlib \
    xz \
    readline \
    libffi \
    openssl \
    sqlite \
    ncurses \
    gdbm \
    db \
    expat \
    pcap \
    bzip2 \
    lzma

# Defina o diretório de trabalho
WORKDIR /workspace

# Copie o código-fonte para o contêiner
COPY . .

# Compila o código-fonte para Windows
RUN x86_64-w64-mingw32-gcc install/install_coder.c -o build/windows/coder_installer.exe

# Cria o pacote .deb para Linux
RUN mkdir -p build/linux/coder/DEBIAN && \
    echo "Package: coder\nVersion: 1.0\nSection: base\nPriority: optional\nArchitecture: all\nDepends: python3, python3-pip\nMaintainer: Your Name <your_email@example.com>\nDescription: Coder installation package" > build/linux/coder/DEBIAN/control && \
    mkdir -p build/linux/coder/usr/local/bin && \
    cp install/install_coder.sh build/linux/coder/usr/local/bin/install_coder.sh && \
    dpkg-deb --build build/linux/coder && \
    mv build/linux/coder.deb build/linux/coder_1.0_all.deb

# Cria o pacote .pkg e .dmg para macOS
RUN pkgbuild --root install --identifier com.example.coder --version 1.0 --install-location /usr/local/bin build/mac/coder.pkg && \
    hdiutil create build/mac/coder.dmg -volname "Coder Installer" -srcfolder build/mac/coder.pkg

# Comando padrão
CMD ["bash"]