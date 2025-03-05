@echo off

:: Load environment variables from .env file
for /f "tokens=1,* delims==" %%a in ('type .env') do set %%a=%%b

:: Function to install software if it's not already installed
:install_if_not_installed
set name=%1
set installer=%2

:: Check if the software is already installed
where %name% >nul 2>nul
if %errorlevel% neq 0 (
    echo Installing %name%...
    %installer%
    :: Call the corresponding setup script if it exists
    if exist "%~dp0setup_%name%.bat" (
        set /p choice="Do you want to run the setup script for %name%? (y/n): "
        if /i "%choice%"=="y" (
            echo Running setup script for %name%...
            call "%~dp0setup_%name%.bat"
        )
    )
) else (
    echo %name% is already installed.
)
exit /b

:: Main function to install applications
:main
:: List of applications to install
setlocal enabledelayedexpansion
set apps=(
    "Google Chrome" "start /wait msiexec /i https://dl.google.com/chrome/install/GoogleChromeStandaloneEnterprise64.msi /quiet"
    "Zoom" "start /wait msiexec /i https://zoom.us/client/latest/ZoomInstallerFull.msi /quiet"
    "Rambox" "start /wait msiexec /i https://github.com/ramboxapp/download/releases/download/v2.3.1/Rambox-2.3.1-win-x64.exe /quiet"
    "IntelliJ IDEA" "start /wait msiexec /i https://download-cdn.jetbrains.com/idea/ideaIU-2023.3.6.exe /quiet"
    "Android Studio" "start /wait msiexec /i https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.1.1.21/android-studio-2022.1.1.21-windows.exe /quiet"
    "DBeaver" "start /wait msiexec /i https://dbeaver.io/files/dbeaver-ce-latest-x86_64-setup.exe /quiet"
    "Postman" "start /wait msiexec /i https://dl.pstmn.io/download/latest/win64 /quiet"
    "Visual Studio Code" "start /wait msiexec /i https://vscode.download.prss.microsoft.com/dbazure/download/stable/863d2581ecda6849923a2118d93a088b0745d9d6/VSCodeUserSetup-x64-1.87.2.exe /quiet"
    "Flutter" "start /wait msiexec /i https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.4-stable.zip /quiet"
    "Go" "start /wait msiexec /i https://dl.google.com/go/go1.22.1.windows-amd64.msi /quiet"
    "Trello" "start /wait msiexec /i https://downloads.trello.com/desktop/windows/latest /quiet"
    "WhatsApp" "start /wait msiexec /i https://web.whatsapp.com/desktop/windows/release/x64 /quiet"
    "Python" "start /wait msiexec /i https://www.python.org/ftp/python/3.10.4/python-3.10.4-amd64.exe /quiet"
)

:: Loop through the list of applications and install each one
for %%a in (!apps!) do (
    call :install_if_not_installed "%%a"
)
endlocal
exit /b

:: Execute the main function
call :main