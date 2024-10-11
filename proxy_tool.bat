@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul

REM 初始化参数变量
set "deviceId="
set "host="
set "port="
set "mode="

REM 检查是否有参数
if "%~1"=="" (
    echo 用法: %0 -d deviceId [-h host] [-p port] [set | reset | show]
    exit /b 1
)

REM 解析命令行参数
:parse_args
if "%~1"=="" goto after_parse

if "%~1"=="-d" (
    set "deviceId=%~2"
    shift
    shift
    goto parse_args
)

if "%~1"=="-h" (
    set "host=%~2"
    shift
    shift
    goto parse_args
)

if "%~1"=="-p" (
    set "port=%~2"
    shift
    shift
    goto parse_args
)

if "%~1"=="set" (
    set "mode=set"
    shift
    goto parse_args
)

if "%~1"=="reset" (
    set "mode=reset"
    shift
    goto parse_args
)

if "%~1"=="show" (
    set "mode=show"
    shift
    goto parse_args
)

REM 未识别的参数
echo 未识别的参数: %~1
exit /b 1

:after_parse

REM 检查deviceId是否提供
if "%deviceId%"=="" (
    echo 错误: 必须提供 -d deviceId 参数。
    exit /b 1
)

REM 处理 set 模式
if /I "%mode%"=="set" (
    REM 检查是否提供host和port
    if "%host%"=="" (
        echo 错误: 在 set 模式下，必须提供 -h host 参数。
        exit /b 1
    )
    if "%port%"=="" (
        echo 错误: 在 set 模式下，必须提供 -p port 参数。
        exit /b 1
    )
    echo 模式: 设置设备的HTTP代理
    adb -s %deviceId% shell settings put global http_proxy %host%:%port%
    if %ERRORLEVEL% EQU 0 (
        echo 设置设备 %deviceId% 的全局HTTP代理为 %host%:%port% 成功。
    ) else (
        echo 设置设备 %deviceId% 的全局HTTP代理为 %host%:%port% 失败。
    )
    exit /b 0
)

REM 处理 reset 模式
if /I "%mode%"=="reset" (
    echo 模式: 重置设备的HTTP代理
    adb -s %deviceId% shell settings put global http_proxy :0
    if %ERRORLEVEL% EQU 0 (
        echo 重置设备 %deviceId% 的全局HTTP代理成功。
    ) else (
        echo 重置设备 %deviceId% 的全局HTTP代理失败。
    )
    exit /b 0
)

REM 处理 show 模式
if /I "%mode%"=="show" (
    echo 模式: 显示设备的HTTP代理设置
    adb -s %deviceId% shell settings get global http_proxy
    if %ERRORLEVEL% EQU 0 (
        echo 显示设备 %deviceId% 的当前HTTP代理设置成功。
    ) else (
        echo 显示设备 %deviceId% 的HTTP代理设置失败。
    )
    exit /b 0
)

REM 如果没有设置模式，提示错误
echo 错误: 必须指定 set、reset 或 show 模式。
exit /b 1
