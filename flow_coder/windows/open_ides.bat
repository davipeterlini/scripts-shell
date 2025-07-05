@echo off
:: Wrapper script to call PowerShell open_ides.ps1
powershell -ExecutionPolicy Bypass -File "%~dp0open_ides.ps1" %*