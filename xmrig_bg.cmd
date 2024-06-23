@echo off

set "xmrigPath=C:\win\xmrig-main\xmrig.exe"

rem Check if xmrig.exe exists at the specified path
if not exist "%xmrigPath%" (
    echo xmrig.exe not found at: %xmrigPath%
    pause
    exit /b 1
)

rem Run xmrig.exe in the background using PowerShell
powershell -Command "Start-Process '%xmrigPath%' -WindowStyle Hidden"

echo Started xmrig.exe in the background.
pause
