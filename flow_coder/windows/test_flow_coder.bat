@echo off
:: Wrapper script to call PowerShell test_flow_coder.ps1
powershell -ExecutionPolicy Bypass -File "%~dp0test_flow_coder.ps1"