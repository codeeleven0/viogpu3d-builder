@echo off
REM ============================================================================
REM viogpu3d Build Environment Setup
REM ============================================================================
REM This script installs all required dependencies for building viogpu3d
REM Run this script as Administrator
REM ============================================================================

setlocal EnableDelayedExpansion

echo ============================================================================
echo viogpu3d Build Environment Setup
echo ============================================================================
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script requires Administrator privileges.
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

REM Check if Chocolatey is installed
where choco >nul 2>&1
if %errorLevel% neq 0 (
    echo Installing Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

    if %errorLevel% neq 0 (
        echo ERROR: Failed to install Chocolatey
        pause
        exit /b 1
    )

    REM Refresh environment
    call refreshenv
)

echo.
echo [1/6] Installing Python...
choco install python311 -y
if %errorLevel% neq 0 (
    echo WARNING: Python installation may have issues
)

echo.
echo [2/6] Installing Git...
choco install git -y
if %errorLevel% neq 0 (
    echo WARNING: Git installation may have issues
)

echo.
echo [3/6] Installing winflexbison...
choco install winflexbison3 -y
if %errorLevel% neq 0 (
    echo WARNING: winflexbison installation may have issues
)

echo.
echo [4/6] Installing Windows Driver Kit (WDK)...
echo This is required for d3d10umddi.h header used by Mesa D3D10 UMD
choco install windowsdriverkit11 -y
if %errorLevel% neq 0 (
    echo WARNING: WDK installation may have issues
    echo You may need to install WDK manually from:
    echo   https://learn.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk
)

echo.
echo [5/6] Refreshing environment...
call refreshenv

echo.
echo [6/6] Installing Python packages (meson, ninja, mako, pyyaml)...
pip install meson ninja mako pyyaml
if %errorLevel% neq 0 (
    echo ERROR: Failed to install Python packages
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo Environment setup complete!
echo ============================================================================
echo.
echo IMPORTANT: You also need Visual Studio with C++ build tools installed.
echo If not installed, download from:
echo   https://visualstudio.microsoft.com/downloads/
echo.
echo Select "Desktop development with C++" workload during installation.
echo.
echo After installation, run build.bat from a "Developer Command Prompt for VS"
echo or "x64 Native Tools Command Prompt for VS"
echo ============================================================================
pause
