@echo off

:: Function to open Meld with file comparison
:open_meld_comparison
set file1=%1
set file2=%2

:: Create a temporary file if one of the files is not provided
if "%file1%"=="" (
    set file1=%TEMP%\empty_file1.txt
    echo. > "%file1%"
)

if "%file2%"=="" (
    set file2=%TEMP%\empty_file2.txt
    echo. > "%file2%"
)

:: Open Meld with the provided files
echo Opening Meld with files: %file1% and %file2%
start "" "meld.exe" "%file1%" "%file2%"
exit /b

:: Main function to handle input parameters
:main
set file1=%1
set file2=%2

call :open_meld_comparison "%file1%" "%file2%"
exit /b

:: Execute the main function with the provided arguments
call :main %1 %2