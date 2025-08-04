@echo off
:: =============================================================================
:: Ultimate HP Laptop Gaming Tweaker v7.3 (WiFi-Safe Edition)
:: MODIFIED VERSION - Preserves WiFi & Windows Update services
:: Run as Administrator.
:: =============================================================================

:: ---- Elevation ----
openfiles >nul 2>&1 || (
    echo [*] Requesting administrative privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb runAs"
    exit /b
)

echo ==============================================
echo    MODIFIED Ultimate Gaming Tweaks v7.3 - START
echo    (WiFi & Windows Update Services PRESERVED)
echo ==============================================

:: ---- Power & Sleep ----
echo [*] Setting High-Performance power plan and disabling sleep/hibernate...
powercfg /setactive SCHEME_MIN
powercfg -change -monitor-timeout-ac 0
powercfg -change -standby-timeout-ac 0
powercfg /hibernate off
powercfg -setacvalueindex SCHEME_CURRENT SUB_USB USBSELECTSUSPEND 0 >nul

:: ---- CPU & Timer Tweaks ----
echo [*] Disabling dynamic tick ^& core parking...
bcdedit /set disabledynamictick yes >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" /v MaxPoolThreads /t REG_DWORD /d 0x400 /f >nul
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100 >nul
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMAXCORES 100 >nul

:: ---- Page File ----
echo [*] Setting fixed page file (1.5× RAM)...
for /f "tokens=2 delims==" %%M in ('wmic os get TotalVisibleMemorySize /value') do set MemKB=%%M
set /a MemMB=%MemKB%/1024
set /a PFSize=%MemMB%*3/2
wmic computersystem where name="%%COMPUTERNAME%%" set AutomaticManagedPagefile=False >nul
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=%PFSize%,MaximumSize=%PFSize% >nul

:: ---- DNS Flush ----
echo [*] Flushing DNS resolver cache...
ipconfig /flushdns >nul

:: ---- Clean Temp & Recycle Bin ----
echo [*] Cleaning user Temp ^& Windows Temp ^& Recycle Bin...
rd /s /q "%TEMP%" 2>nul & md "%TEMP%"
rd /s /q "C:\Windows\Temp" 2>nul & md "C:\Windows\Temp"
rd /s /q "%SystemDrive%\$Recycle.Bin" 2>nul

:: ---- Clean Prefetch ----
echo [*] Cleaning Prefetch folder...
del /f /s /q "C:\Windows\Prefetch\*." >nul 2>&1

:: ---- Clear Event Logs ----
echo [*] Clearing Windows Event Logs...
for /f "tokens=" %%G in ('wevtutil el') do wevtutil cl "%%G"

:: ---- Basic Services ----
echo [*] Disabling ^& stopping basic low-value services (preserving Windows Update)...
:: REMOVED wuauserv from services list
set BASIC_SERVICES=SysMain WSearch Spooler bthserv WerSvc
for %%S in (%BASIC_SERVICES%) do (
    sc config "%%S" start=disabled >nul 2>&1
    net stop "%%S" >nul 2>&1
)

:: ---- SAFE Advanced Services (WiFi-Preserved) ----
echo [*] Applying WiFi-safe services reducer (preserving network services)...
:: REMOVED network-related services from disable list
set ADV_SERVICES=^
    DiagTrack^
    WMPNetworkSvc^
    XblAuthManager^
    XboxGipSvc^
    Fax^
    MapsBroker^
    RemoteRegistry^
    RetailDemo^
    TabletInputService^
    RemoteDesktopServices^
    RemoteDesktopServicesUserMode^
    TouchKeyboardService^
    XblGameSave^
    dvsvc^
    PcaSvc^
    BcastDVRUserService^
    dmwappushservice^
    wisvc^
    WpcMonSvc
    :: REMOVED DoSvc (Delivery Optimization) to preserve updates

:: ---- Error Reporting & Tips ----
echo [*] Disabling Windows Error Reporting ^& Tips...
sc config "WerSvc" start=disabled >nul 2>&1 & net stop "WerSvc" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul

:: ---- TCP/IP Tuning (Safe for WiFi) ----
echo [*] Tuning TCP/IP stack for latency (WiFi-safe)...
netsh int tcp set global autotuninglevel=disabled >nul
netsh int tcp set global chimney=disabled >nul
netsh int tcp set global ecncapability=disabled >nul
netsh int tcp set global rss=enabled >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpAckFrequency /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TCPNoDelay /t REG_DWORD /d 1 /f >nul

:: ---- GPU Scheduling ----
echo [*] Enabling hardware-accelerated GPU scheduling...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul

:: ---- Telemetry & Cortana ----
echo [*] Disabling telemetry tasks & Cortana tips...
schtasks /Disable /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" >nul 2>&1
schtasks /Disable /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" >nul 2>&1
schtasks /Disable /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul

:: ---- Visual Effects & Notifications ----
echo [*] Disabling visual effects ^& notifications...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v EnableBalloonTips /t REG_DWORD /d 0 /f >nul

:: ---- Game Mode & Boot ----
echo [*] Enabling Game Mode & low-latency boot...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GameConfigStore" /v GameMode /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrLevel /t REG_DWORD /d 0 /f >nul

:: ---- Final Cleanup ----
echo [*] Final cleanup & cache flush...
del /q/f/s "%TEMP%\*.*" >nul 2>&1
del /s /q "%SYSTEMROOT%\Prefetch\*.*" >nul 2>&1
powershell -NoProfile -Command "Clear-RecycleBin -Force" >nul
ipconfig /flushdns >nul
netsh interface ipv4 delete arpcache >nul

:: ---- Done ----
echo.
echo ==============================================
echo    MODIFIED v7.3 Tweaks Applied
echo    (WiFi & Windows Update PRESERVED)
echo    REBOOT RECOMMENDED!
echo ==============================================
pause
exit /b