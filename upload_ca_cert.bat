@echo off
setlocal

:: 初始化参数
set certFile=
set deviceID=

:: 解析参数
:parse_args
if "%~1"=="" goto :args_parsed
if "%~1"=="-c" (
    set certFile=%~2
    shift
    shift
) else if "%~1"=="-d" (
    set deviceID=%~2
    shift
    shift
) else (
    echo Unknown option: %~1
    goto :show_usage
)
goto parse_args

:args_parsed

:: 如果未提供任何参数，显示 usage
if "%certFile%"=="" if "%deviceID%"=="" goto :show_usage

:: 检查是否提供了证书文件和设备 ID
if "%certFile%"=="" (
    echo Certificate file not specified. Use -c [path_to_certificate_file].
    goto :end
)

if "%deviceID%"=="" (
    echo Device ID not specified. Use -d [device_id].
    goto :end
)

:: 检查证书文件是否存在
if not exist "%certFile%" (
    echo Certificate file not found: %certFile%
    goto :end
)

:: 检查是否安装了 OpenSSL
where openssl >nul 2>nul
if %errorlevel% neq 0 (
    echo OpenSSL is not installed.
    goto :end
)

:: 获取证书文件的 hash 值
for /f "tokens=*" %%i in ('openssl x509 -noout -subject_hash_old -in "%certFile%" 2^>nul') do (
    set certHash=%%i
)

:: 检查是否成功获取到 hash
if "%certHash%"=="" (
    echo Failed to get hash of the certificate.
    goto :end
)

:: 检查是否安装了 adb
where adb >nul 2>nul
if %errorlevel% neq 0 (
    echo ADB is not installed.
    goto :end
)

:: 将证书直接上传到 /system/etc/security/cacerts 目录，并重命名为 hash.0
adb -s %deviceID% push "%certFile%" /system/etc/security/cacerts/%certHash%.0
if %errorlevel% neq 0 (
    echo Failed to upload the certificate to the device.
) else (
    echo Successfully uploaded the certificate as %certHash%.0.
)

:: 设置正确的文件权限
adb -s %deviceID% shell "chmod +x /system/etc/security/cacerts/%certHash%.0"
if %errorlevel% neq 0 (
    echo Failed to set file permissions.
) else (
    echo Successfully set permissions for %certHash%.0.
)

goto :end

:show_usage
echo Usage: %0 -c [path_to_certificate_file] -d [device_id]

:end
