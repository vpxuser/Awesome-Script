@echo off

echo 正在列出所有设备...
adb devices

set DEVICE_ID=%1
set WAIT_PARAM=%2
set SUCCESS=1

if "%DEVICE_ID%"=="" (
    echo 未提供设备 ID 参数。
    set ADB_COMMAND=adb
) else (
    set ADB_COMMAND=adb -s %DEVICE_ID%
)

%ADB_COMMAND% root
if errorlevel 1 (
    echo 获取 ROOT 权限失败。
    set SUCCESS=0
) else (
    echo 获取ROOT权限成功。
)

%ADB_COMMAND% disable-verity
if errorlevel 1 (
    echo 禁用 Android 验证机制失败。
    set SUCCESS=0
) else (
    echo 禁用 Android 验证机制成功。
)

if "%WAIT_PARAM%"=="wait" (
    %ADB_COMMAND% reboot
    if errorlevel 1 (
        echo 设备重启失败。
        set SUCCESS=0
    ) else (
        echo 设备重启成功。
    )

    echo 等待设备重启...
    timeout /t 10 > nul

    echo 等待设备启动完成...
    %ADB_COMMAND% wait-for-device
    if errorlevel 1 (
        echo 等待设备失败。
        set SUCCESS=0
    ) else (
        echo 设备启动完成。
    )

    :CHECK_BOOT_COMPLETED
    %ADB_COMMAND% shell getprop sys.boot_completed | findstr /c:"1" > nul
    if errorlevel 1 (
        echo 设备尚未启动完成，等待中...
        timeout /t 5 > nul
        goto CHECK_BOOT_COMPLETED
    ) else (
        echo 设备已经启动完成。
    )

    %ADB_COMMAND% root
    if errorlevel 1 (
        echo 获取 ROOT 权限失败。
        set SUCCESS=0
    ) else (
        echo 获取 ROOT 权限成功。
    )
)

%ADB_COMMAND% remount
if errorlevel 1 (
    echo remount 挂载失败，尝试 mount 重新挂载 /system 分区...
    %ADB_COMMAND% shell mount -o rw,remount /system
    if errorlevel 1 (
        echo mount 挂载失败。
        set SUCCESS=0
    ) else (
        echo mount 挂载成功。
    )
) else (
    echo remount 挂载成功。
)

if "%SUCCESS%"=="1" (
    echo 成功挂载系统盘。
) else (
    echo 挂载系统盘失败。
)
