@echo off
setlocal EnableDelayedExpansion

:: Check for admin privileges
fsutil dirty query %systemdrive% >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges.
    echo Attempting to relaunch as administrator...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Log file setup
set "logfile=%temp%\dns_set_log.txt"
echo DNS Set Log - %date% %time% > "%logfile%"

echo Setting DNS for all connected network adapters...
echo Setting DNS for all connected network adapters... >> "%logfile%"

:: Get list of connected adapters
for /f "tokens=*" %%i in ('netsh interface show interface ^| findstr /C:"Connected"') do (
    for /f "tokens=3,*" %%a in ("%%i") do (
        set "adapter=%%b"
        call :SetDNS "%%b"
    )
)

:: Flush DNS cache
echo Flushing DNS cache...
echo Flushing DNS cache... >> "%logfile%"
ipconfig /flushdns >nul 2>&1
if %errorlevel% equ 0 (
    echo DNS cache flushed successfully.
    echo DNS cache flushed successfully. >> "%logfile%"
) else (
    echo Failed to flush DNS cache.
    echo Failed to flush DNS cache. >> "%logfile%"
)

echo Done
echo DNS setting completed. Check log at %logfile% for details. >> "%logfile%"
timeout /t 2 /nobreak >nul
exit /b

:SetDNS
set "adapter=%~1"
echo Setting DNS for adapter: %adapter%
echo Setting DNS for adapter: %adapter% >> "%logfile%"

:: Set IPv4 DNS (Primary: 8.8.8.8, Secondary: 8.8.4.4)
netsh interface ip set dns name="%adapter%" source=static addr=78.157.42.100 >nul 2>&1
if %errorlevel% equ 0 (
    echo IPv4 DNS set to 78.157.42.100 for %adapter%.
    echo IPv4 DNS set to 185.51.200.2 for %adapter%. >> "%logfile%"
) else (
    echo Failed to set IPv4 DNS for %adapter%.
    echo Failed to set IPv4 DNS for %adapter%. >> "%logfile%"
)
netsh interface ip add dns name="%adapter%" addr=185.51.200.2 index=2 >nul 2>&1
if %errorlevel% equ 0 (
    echo IPv4 Secondary DNS set to 78.157.42.100 for %adapter%.
    echo IPv4 Secondary DNS set to 185.51.200.2 for %adapter%. >> "%logfile%"
) else (
    echo Failed to set IPv4 Secondary DNS for %adapter%.
    echo Failed to set IPv4 Secondary DNS for %adapter%. >> "%logfile%"
)

exit /b