@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

taskkill /f /im msedge.exe >nul 2>&1
taskkill /f /im MicrosoftEdgeUpdate.exe >nul 2>&1

for /f "tokens=*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients" /s /v pv 2^>nul ^| findstr /i "edge" ^| findstr /v "webview"') do (
    set "edgepath=%%a"
)

set "edgedir=%ProgramFiles(x86)%\Microsoft\Edge\Application"
if not exist "%edgedir%" set "edgedir=%ProgramFiles%\Microsoft\Edge\Application"

for /f "delims=" %%v in ('dir "%edgedir%" /b /ad 2^>nul ^| findstr /r "^[0-9]"') do (
    set "edgever=%%v"
)

if defined edgever (
    "%edgedir%\%edgever%\Installer\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall
)

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "InstallDefault" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /t REG_DWORD /d 1 /f >nul 2>&1

powershell -Command "Get-AppxPackage -AllUsers *MicrosoftEdge* | Where-Object {$_.Name -notlike '*WebView*'} | Remove-AppxPackage -AllUsers" >nul 2>&1

exit /b
