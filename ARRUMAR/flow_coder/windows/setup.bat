@echo off
:: Wrapper script to call PowerShell setup.ps1
powershell -ExecutionPolicy Bypass -File "%~dp0setup.ps1"