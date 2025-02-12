@echo off

REM Ensure Python is installed and PATH is configured
call install_python.bat

REM Function to install coder
:install_coder
echo Installing coder...
pip install https://storage.googleapis.com/flow-coder/coder-0.88-py3-none-any.whl
echo Coder installed successfully.

REM Main script execution
call :install_coder

echo Coder installation completed. Please restart your terminal to apply PATH changes.
pause