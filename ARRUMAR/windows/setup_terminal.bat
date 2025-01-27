@echo off

:: Check if Windows Terminal is installed
where wt >nul 2>nul
if %errorlevel% neq 0 (
    echo Windows Terminal is not installed. Please install Windows Terminal from the Microsoft Store.
    exit /b 1
)

:: Function to open a new tab in Windows Terminal
:open_terminal_tab
set tab_path=%1
echo Opening terminal tab for %tab_path%...
start wt -d "%tab_path%" new-tab
exit /b

:: List of directories to open in new terminal tabs
set tabs=(
    "C:\path\to\project1"
    "C:\path\to\project2"
    "C:\path\to\project3"
)

:: Loop through the list of directories and open each one in a new terminal tab
for %%a in %tabs% do (
    call :open_terminal_tab "%%a"
)

:: Call the corresponding setup script if it exists
if exist "%~dp0setup_terminal.bat" (
    set /p choice="Do you want to run the setup script for terminal? (y/n): "
    if /i "%choice%"=="y" (
        echo Running setup script for terminal...
        call "%~dp0setup_terminal.bat"
    )
)