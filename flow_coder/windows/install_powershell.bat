@echo off
echo ===================================================
echo Instalador do PowerShell para Windows
echo ===================================================
echo.

:: Verifica se está sendo executado como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script precisa ser executado como Administrador.
    echo Por favor, clique com o botão direito no arquivo e selecione "Executar como administrador".
    pause
    exit /b 1
)

echo Verificando a versão do Windows...
ver | findstr /i "10\." > nul
if %errorlevel% equ 0 (
    echo Windows 10 detectado.
) else (
    ver | findstr /i "11\." > nul
    if %errorlevel% equ 0 (
        echo Windows 11 detectado.
    ) else (
        echo Este script é otimizado para Windows 10/11.
        echo Seu sistema pode não ser compatível com a instalação automática.
        echo Deseja continuar mesmo assim? (S/N)
        set /p CONTINUE=
        if /i "%CONTINUE%" neq "S" exit /b 1
    )
)

echo.
echo Baixando o instalador do PowerShell...
echo.

:: Cria pasta temporária para download
mkdir "%TEMP%\PSInstall" 2>nul

:: Baixa o instalador mais recente do PowerShell
powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/PowerShell-7.4.1-win-x64.msi' -OutFile '%TEMP%\PSInstall\PowerShell-7.4.1-win-x64.msi'}"

if %errorlevel% neq 0 (
    echo Falha ao baixar o instalador do PowerShell.
    echo Verifique sua conexão com a internet e tente novamente.
    rmdir /s /q "%TEMP%\PSInstall" 2>nul
    pause
    exit /b 1
)

echo.
echo Instalando o PowerShell...
echo.

:: Instala o PowerShell silenciosamente
msiexec.exe /i "%TEMP%\PSInstall\PowerShell-7.4.1-win-x64.msi" /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1

echo.
echo Aguardando a conclusão da instalação...
timeout /t 10 /nobreak > nul

:: Limpa arquivos temporários
rmdir /s /q "%TEMP%\PSInstall" 2>nul

echo.
echo Verificando a instalação...
where pwsh > nul 2>&1
if %errorlevel% equ 0 (
    echo PowerShell foi instalado com sucesso!
    echo Você pode iniciar o PowerShell digitando 'pwsh' no prompt de comando.
) else (
    echo A instalação pode não ter sido concluída corretamente.
    echo Tente reiniciar o computador e verificar se o PowerShell está disponível.
)

echo.
echo Instalação concluída!
pause