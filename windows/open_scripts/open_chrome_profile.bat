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

:: Function to open Google Chrome with a specific profile
:open_chrome_with_profile
set profile=%1

call :is_app_running "chrome"
if "%ERRORLEVEL%"=="0" (
    echo Google Chrome is already running.
) else (
    echo Opening Google Chrome with profile %profile%...
    start "" "chrome.exe" --profile-directory="%profile%"
)
exit /b

:: Main function to open Google Chrome with the specified profile
set profile=%1

if "%profile%"=="" (
    echo No profile specified. Exiting...
    exit /b 1
)

call :open_chrome_with_profile "%profile%"