@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul

:: 检查参数
if "%~1"=="" (
    echo Usage: proxy_manager.bat -d <device_id> -h <proxy_host> -p <proxy_port> [set|reset]
    exit /b 1
)

:: 解析参数
set DEVICE_ID=
set PROXY_HOST=
set PROXY_PORT=

:parse_args
shift
if "%~1"=="" goto end_parse
if "%~1"=="-d" (
    set DEVICE_ID=%~2
    shift
) else if "%~1"=="-h" (
    set PROXY_HOST=%~2
    shift
) else if "%~1"=="-p" (
    set PROXY_PORT=%~2
    shift
) else if "%~1"=="set" (
    set COMMAND=set
) else if "%~1"=="reset" (
    set COMMAND=reset
) else (
    echo Invalid argument: %~1
    exit /b 1
)
goto parse_args

:end_parse

:: 检查必要参数
if "%DEVICE_ID%"=="" (
    echo Device ID is required.
    exit /b 1
)
if "%PROXY_HOST%"=="" (
    echo Proxy host is required.
    exit /b 1
)
if "%PROXY_PORT%"=="" (
    echo Proxy port is required.
    exit /b 1
)

:: 检查 ADB 是否可用
adb start-server
if errorlevel 1 (
    echo ADB server failed to start.
    exit /b 1
)

:: 设置当前设备
adb -s %DEVICE_ID% devices
if errorlevel 1 (
    echo No devices found with ID %DEVICE_ID%.
    exit /b 1
)

:: 尝试获取 root 权限
adb -s %DEVICE_ID% root
if errorlevel 1 (
    echo Failed to get root access. Exiting.
    exit /b 1
)

:: 备份当前的 iptables 规则
adb -s %DEVICE_ID% shell su -c "iptables-save > /data/local/tmp/iptables_backup.txt"

if "%COMMAND%"=="set" (
    echo Backing up current iptables configuration...
    :: 设置透明代理
    adb -s %DEVICE_ID% shell su -c "iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination %PROXY_HOST%:%PROXY_PORT%"
    adb -s %DEVICE_ID% shell su -c "iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination %PROXY_HOST%:%PROXY_PORT%"
    echo Transparent proxy set to %PROXY_HOST%:%PROXY_PORT% on device %DEVICE_ID%.
) else if "%COMMAND%"=="reset" (
    :: 恢复之前的 iptables 配置
    adb -s %DEVICE_ID% shell su -c "iptables-restore < /data/local/tmp/iptables_backup.txt"
    echo Proxy settings reset to previous configuration on device %DEVICE_ID%.
) else (
    echo Invalid command. Use 'set' or 'reset'.
    exit /b 1
)

endlocal
