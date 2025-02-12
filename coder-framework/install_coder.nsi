; Nullsoft Scriptable Install System (NSIS) script for Windows installer

OutFile "coder-framework/build/windows/coder_installer.exe"
InstallDir "$PROGRAMFILES\Coder"
RequestExecutionLevel admin

Section "Install"
  SetOutPath $INSTDIR
  File /r "coder-framework/build/windows\*"
  ExecWait '"$INSTDIR\install_coder.bat"'
SectionEnd

Section "Uninstall"
  Delete "$INSTDIR\install_coder.bat"
  RMDir /r "$INSTDIR"
SectionEnd