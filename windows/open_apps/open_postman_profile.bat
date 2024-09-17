@echo off

:: Function to check if an application is running
:is_app_running
set app_name=%1
tasklist /FI "IMAGENAME eq %app_name%.exe" 2>NUL | find /I /N "%app_name%.exe">NUL
if "%ERRORLEVEL%"=="0" (
    exit /b 0
) else (
    exit /b 1
)

:: Function to open Postman with a specific profile
:open_postman_with_profile
set profile=%1

call :is_app_running "Postman"
if "%ERRORLEVEL%"=="0" (
    echo Postman is already running.
) else (
    echo Opening Postman with profile %profile%...
    start "" "Postman.exe" --profile="%profile%"
)
exit /b

:: Main function to open Postman with the specified profile
set profile=%1

if "%profile%"=="" (
    echo No profile specified. Exiting...
    exit /b 1
)

call :open_postman_with_profile "%profile%"