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
set "logfile=%temp%\dns_reset_log.txt"
echo DNS Reset Log - %date% %time% > "%logfile%"

echo Resetting DNS for all connected network adapters...
echo Resetting DNS for all connected network adapters... >> "%logfile%"

:: Get list of connected adapters
for /f "tokens=*" %%i in ('netsh interface show interface ^| findstr /C:"Connected"') do (
    for /f "tokens=3,*" %%a in ("%%i") do (
        set "adapter=%%b"
        call :ResetDNS "%%b"
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
echo DNS reset completed. Check log at %logfile% for details. >> "%logfile%"
timeout /t 2 /nobreak >nul
exit /b

:ResetDNS
set "adapter=%~1"
echo Resetting DNS for adapter: %adapter%
echo Resetting DNS for adapter: %adapter% >> "%logfile%"

:: Reset IPv4 DNS
netsh interface ip set dns name="%adapter%" source=dhcp >nul 2>&1
if %errorlevel% equ 0 (
    echo IPv4 DNS reset to DHCP for %adapter%.
    echo IPv4 DNS reset to DHCP for %adapter%. >> "%logfile%"
) else (
    echo Failed to reset IPv4 DNS for %adapter%.
    echo Failed to reset IPv4 DNS for %adapter%. >> "%logfile%"
)

:: Reset IPv6 DNS
netsh interface ipv6 set dnsservers name="%adapter%" source=dhcp >nul 2>&1
if %errorlevel% equ 0 (
    echo IPv6 DNS reset to DHCP for %adapter%.
    echo IPv6 DNS reset to DHCP for %adapter%. >> "%logfile%"
) else (
    echo Failed to reset IPv6 DNS for %adapter%.
    echo Failed to reset IPv6 DNS for %adapter%. >> "%logfile%"
)

exit /b