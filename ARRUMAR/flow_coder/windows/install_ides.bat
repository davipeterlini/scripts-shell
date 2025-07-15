@echo off
:: Wrapper script to call PowerShell install_ides.ps1
powershell -ExecutionPolicy Bypass -File "%~dp0install_ides.ps1"