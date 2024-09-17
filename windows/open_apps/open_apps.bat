@echo off

:: Load environment variables from .env file
for /f "tokens=1,* delims==" %%a in ('type .env') do set %%a=%%b

:: Function to open an application
:open_app
set app_name=%1
echo Opening %app_name%...
start "" "%app_name%"
exit /b

:: List of applications to open
setlocal enabledelayedexpansion
set apps=%APPS_TO_OPEN_WORK%

for %%a in (!apps!) do (
    if "%%a"=="Google Chrome" (
        call open_chrome_profile.bat %PROJECT_DIR_WORK%
    ) else if "%%a"=="Postman" (
        call open_postman_profile.bat %PROJECT_DIR_WORK%
    ) else (
        call :open_app "%%a"
    )
)

:: Open terminal tabs
call open_terminal_tabs.bat %PROJECT_DIR_WORK%

:: Execute all other open scripts in the open_apps directory
for %%f in ("%~dp0*.bat") do (
    if not "%%~nxf"=="%~nx0" (
        echo Executing %%~nxf
        call "%%~dpnx0" %PROJECT_DIR_WORK%
    )
)

:: Call open_meld_comparison.bat separately
call open_meld_comparison.bat
endlocal