@echo off

:: List of directories to open in new terminal tabs
set tabs=(
    "C:\path\to\project1"
    "C:\path\to\project2"
    "C:\path\to\project3"
)

:: Function to open a new terminal tab
:open_tab
set tab_path=%1
echo Opening terminal tab for %tab_path%...
start "" "cmd.exe" /k "cd /d %tab_path%"
exit /b

:: Loop through the list of directories and open each one in a new terminal tab
for %%a in %tabs% do (
    call :open_tab "%%a"
)