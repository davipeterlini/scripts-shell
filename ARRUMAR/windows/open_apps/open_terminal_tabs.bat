@echo off

:: Load environment variables from .env file
for /f "tokens=1,* delims==" %%a in ('type .env') do set %%a=%%b

:: Function to open a new terminal tab
:open_tab
set tab_path=%1
echo Opening terminal tab for %tab_path%...
start "" "cmd.exe" /k "cd /d %tab_path%"
exit /b

:: List of directories to open in new terminal tabs
setlocal enabledelayedexpansion
set tabs=(
    %ITERM_OPEN_TABS_WORK_1%
    %ITERM_OPEN_TABS_WORK_2%
    %ITERM_OPEN_TABS_WORK_3%
)

:: Loop through the list of directories and open each one in a new terminal tab
for %%a in (!tabs!) do (
    call :open_tab "%%a"
)
endlocal