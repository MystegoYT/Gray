@echo off
setlocal enabledelayedexpansion

:: =================================================================
:: Ultimate PC Junk Cleaner (Combined & Enhanced)
:: Must run as Administrator
:: =================================================================

:: Elevate to admin and maximize window
NET FILE >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
if "%1" NEQ "max" (
    start /MAX cmd /c "%~f0" max
    exit /b
)

echo.
echo [1/7] Cleaning Windows Prefetch...
del /f /q "%windir%\Prefetch\*" >nul 2>&1

echo [2/7] Cleaning Temporary Files...
:: System Temp
rd /s /q "%windir%\Temp" 2>nul
md "%windir%\Temp" 2>nul
:: User Temp
for /d %%I in ("%temp%\*") do rd /s /q "%%I" 2>nul
del /f /q "%temp%\*" >nul 2>&1
:: Old-style Temp locations
rd /s /q "%userprofile%\Local Settings\Temp" 2>nul
rd /s /q "%userprofile%\AppData\Local\Temp" 2>nul >nul 2>&1
:: Legacy temporary locations
rd /s /q "%windir%\tempor~1" 2>nul
rd /s /q "%windir%\tmp" 2>nul

echo [3/7] Cleaning System Junk Files...
:: Generic junk files
del /f /s /q "%systemdrive%\*.tmp" >nul 2>&1
del /f /s /q "%systemdrive%\*._mp" >nul 2>&1
del /f /s /q "%systemdrive%\*.log" >nul 2>&1
del /f /s /q "%systemdrive%\*.gid" >nul 2>&1
del /f /s /q "%systemdrive%\*.chk" >nul 2>&1
del /f /s /q "%systemdrive%\*.old" >nul 2>&1
del /f /s /q "%windir%\*.bak" >nul 2>&1
:: Specific Windows junk
del /f /q "%windir%\ff*.tmp" >nul 2>&1
rd /s /q "%windir%\history" 2>nul
rd /s /q "%windir%\recent" 2>nul
:: Print spool cleanup
del /f /q "%windir%\System32\spool\printers\*" >nul 2>&1
:: Legacy swap file
del /f /q "%systemdrive%\WIN386.SWP" >nul 2>&1

echo [4/7] Emptying Recycle Bin...
rd /s /q "%systemdrive%\$Recycle.bin" 2>nul
del /f /s /q "%systemdrive%\recycled\*" >nul 2>&1
del /f /s /q "%systemdrive%\RECYCLER\*" >nul 2>&1

echo [5/7] Cleaning Browser and Recent Items...
:: Cookies
del /f /q "%userprofile%\cookies\*" >nul 2>&1
del /f /q "%userprofile%\AppData\Roaming\Microsoft\Windows\Cookies\*" >nul 2>&1
:: Recent Items
del /f /q "%userprofile%\recent\*" >nul 2>&1
del /f /q "%userprofile%\AppData\Roaming\Microsoft\Windows\Recent\*" >nul 2>&1
:: Temporary Internet Files
rd /s /q "%userprofile%\Local Settings\Temporary Internet Files" 2>nul
rd /s /q "%userprofile%\AppData\Local\Microsoft\Windows\Temporary Internet Files" 2>nul

echo [6/7] Removing Empty Directories...
for /f "delims=" %%D in ('dir /ad/b/s "%userprofile%" 2^>nul') do (
    rd "%%D" 2>nul
)

echo [7/7] Finalizing Cleanup...
:: Refresh system environment
set COMSPEC=%windir%\system32\cmd.exe

echo.
echo ========================================
echo 🎉 ULTIMATE SYSTEM CLEANUP COMPLETED SUCCESSFULLY!
echo ========================================
echo.
timeout /t 3 >nul
endlocal