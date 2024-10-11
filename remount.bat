@echo off
setlocal enabledelayedexpansion

rem 初始化变量，控制是否执行 disable-verity
set disable_verity=false

rem 检查参数
:parse_args
if "%1"=="-d" (
    if "%2"=="" (
        echo 请提供设备 ID.
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
    echo 未找到 adb，请确保 adb 工具已安装并添加到系统的环境变量中。
    goto :eof
)

rem 检查设备是否连接
adb -s %deviceid% get-state >nul 2>&1
if errorlevel 1 (
    echo 设备 %deviceid% 未连接，请检查设备是否正常连接并启用调试模式。
    goto :eof
)

rem 尝试获取 root 权限
echo 正在尝试获取设备 %deviceid% 的 root 权限...
adb -s %deviceid% root

rem 检查 root 权限是否成功
adb -s %deviceid% shell "id | grep 'uid=0'" >nul 2>&1
if errorlevel 1 (
    echo 设备 %deviceid% 获取 root 权限失败。
    goto :eof
) else (
    echo 设备 %deviceid% 获取 root 权限成功！
)

rem 检查是否执行 disable-verity
if "%disable_verity%"=="true" (
    rem 尝试禁用 Android Verified Boot (disable-verity)
    echo 正在禁用设备 %deviceid% 的 verified boot...
    adb -s %deviceid% disable-verity

    rem 提示用户重启设备
    echo 设备 %deviceid% 的 verified boot 已禁用。请重启设备以使更改生效。
    adb -s %deviceid% reboot

    rem 等待设备重启
    echo 等待设备重启完成...
    adb -s %deviceid% wait-for-device

    rem 再次获取 root 权限以继续操作
    echo 获取 root 权限以继续 remount 操作...
    adb -s %deviceid% root
)

rem 尝试重新挂载系统分区为读写模式
echo 正在重新挂载设备 %deviceid% 的系统分区为读写模式...
adb -s %deviceid% remount

rem 检查是否成功 remount
adb -s %deviceid% shell "mount | grep '/system.*rw'" >nul 2>&1
if errorlevel 1 (
    echo adb remount 失败，尝试使用 shell mount 进行挂载...

    rem 使用 shell mount 尝试重新挂载为读写模式
    adb -s %deviceid% shell "mount -o rw,remount /system"

    rem 再次检查是否成功挂载
    adb -s %deviceid% shell "mount | grep '/system.*rw'" >nul 2>&1
    if errorlevel 1 (
        echo 系统分区重新挂载为读写模式失败。
        goto :eof
    ) else (
        echo 系统分区重新挂载为读写模式成功！
    )
) else (
    echo 系统分区通过 adb remount 成功挂载为读写模式！
)

:end
endlocal
