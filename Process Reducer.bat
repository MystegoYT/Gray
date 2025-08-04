@echo off
:: ─────────────────────────────────────────────────────────────────────────────
:: MODIFIED Windows Services Reducer - Safe Defaults
:: PRESERVES Windows Update & WiFi Services
:: Run as Administrator. Disables many non-essential Windows services.
:: Customize to your needs before using!
:: ─────────────────────────────────────────────────────────────────────────────

echo.
echo === Stopping and Disabling Non-Essential Windows Services ===
echo [PRESERVING Windows Update & WiFi Services]
echo.

:: === SERVICE STOP & DISABLE LIST ===
:: REMOVED: DoSvc (Delivery Optimization) and PolicyAgent (IPsec) for updates
set SVCLIST=^
    DiagTrack^
    WMPNetworkSvc^
    XblAuthManager^
    XboxGipSvc^
    PrintSpooler^
    Fax^
    MapsBroker^
    RemoteRegistry^
    RetailDemo^
    SysMain^
    TabletInputService^
    RemoteDesktopServices^
    RemoteDesktopServicesUserMode^
    TouchKeyboardService^
    XblGameSave^
    dvsvc^
    WerSvc^
    PcaSvc^
    BcastDVRUserService^
    dmwappushservice^
    WSearch^
    DiagnosticsHub.StandardCollector.Service^
    lfsvc

for %%S in (%SVCLIST%) do (
    echo [*] Attempting to stop %%S...
    sc stop "%%S" >nul 2>&1
    echo [*] Disabling %%S...
    sc config "%%S" start=disabled >nul 2>&1
)

echo.
echo === Critical Update Services PRESERVED ===
echo   [wuauserv] - Windows Update Service
echo   [cryptSvc] - Cryptographic Services
echo   [bits]     - Background Intelligent Transfer
echo   [msiserver] - Windows Installer Service
echo   [PolicyAgent] - IPsec Services
echo   [DoSvc]    - Delivery Optimization
echo.
echo === All services processed. ===
echo Press any key to exit...
pause >nul