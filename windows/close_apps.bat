@echo off

:: Function to close an application gracefully
:close_app
set app_name=%1

echo Closing %app_name%...
taskkill /IM "%app_name%.exe" /F
exit /b

:: List of applications to close
set apps=(
    "Code"
    "Robo3T"
    "Postman"
    "Meld"
    "Rambox"
    "chrome"
    "Spotify"
    "Docker Desktop"
)

for %%a in %apps% do (
    call :close_app "%%a"
)