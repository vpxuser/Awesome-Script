@echo off
setlocal enabledelayedexpansion

rem 初始化变量，控制是否执行 disable-verity
set disable_verity=false

rem 检查参数
:parse_args
if "%1"=="-d" (
    if "%2"=="" (
        echo Please provide the device ID.
        goto :eof
    )
    set deviceid=%2
    shift
    shift
    goto :parse_args
) else if "%1"=="-f" (
    set disable_verity=true
    shift
    goto :parse_args
)

rem 检查 adb 工具是否在环境变量中
adb devices >nul 2>&1
if errorlevel 1 (
    echo adb not found. Please ensure adb is installed and added to your system's environment variables.
    goto :eof
)

rem 检查设备是否连接
adb -s %deviceid% get-state >nul 2>&1
if errorlevel 1 (
    echo Device %deviceid% is not connected. Please check if the device is properly connected and debugging is enabled.
    goto :eof
)

rem 尝试获取 root 权限
echo Attempting to gain root access for device %deviceid%...
adb -s %deviceid% root

rem 检查 root 权限是否成功
adb -s %deviceid% shell "id | grep 'uid=0'" >nul 2>&1
if errorlevel 1 (
    echo Failed to gain root access for device %deviceid%.
    goto :eof
) else (
    echo Successfully gained root access for device %deviceid%!
)

rem 检查是否执行 disable-verity
if "%disable_verity%"=="true" (
    rem 尝试禁用 Android Verified Boot (disable-verity)
    echo Disabling verified boot for device %deviceid%...
    adb -s %deviceid% disable-verity

    rem 提示用户重启设备
    echo Verified boot for device %deviceid% has been disabled. Please restart the device for the changes to take effect.
    adb -s %deviceid% reboot

    rem 等待设备重启
    echo Waiting for the device to reboot...
    adb -s %deviceid% wait-for-device

    rem 再次获取 root 权限以继续操作
    echo Gaining root access to continue with remount operation...
    adb -s %deviceid% root
)

rem 尝试重新挂载系统分区为读写模式
echo Remounting the system partition of device %deviceid% as read-write...
adb -s %deviceid% remount

rem 检查是否成功 remount
adb -s %deviceid% shell "mount | grep '/system.*rw'" >nul 2>&1
if errorlevel 1 (
    echo adb remount failed, trying shell mount to remount...

    rem 使用 shell mount 尝试重新挂载为读写模式
    adb -s %deviceid% shell "mount -o rw,remount /system"

    rem 再次检查是否成功挂载
    adb -s %deviceid% shell "mount | grep '/system.*rw'" >nul 2>&1
    if errorlevel 1 (
        echo Failed to remount the system partition as read-write.
        goto :eof
    ) else (
        echo Successfully remounted the system partition as read-write!
    )
) else (
    echo System partition successfully remounted as read-write using adb remount!
)

:end
endlocal
