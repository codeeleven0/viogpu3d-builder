@echo off
REM ============================================================================
REM Driver-only Build Script
REM ============================================================================
REM This script builds only the viogpu3d driver (requires Mesa already built)
REM Run from "Developer Command Prompt for VS" or "x64 Native Tools Command Prompt"
REM ============================================================================

setlocal EnableDelayedExpansion

echo ============================================================================
echo viogpu3d Driver Build Script
echo ============================================================================
echo.

REM Configuration
set "DRIVER_REPO=https://github.com/max8rr8/kvm-guest-drivers-windows"
set "DRIVER_BRANCH=viogpu_win"

REM Set working directory
if "%WORK_DIR%"=="" set "WORK_DIR=%CD%\viogpu3d-build"

echo Working directory: %WORK_DIR%
echo.

REM Check for MESA_PREFIX
if "%MESA_PREFIX%"=="" (
    if exist "%WORK_DIR%\mesa_prefix" (
        set "MESA_PREFIX=%WORK_DIR%\mesa_prefix"
    ) else (
        echo WARNING: MESA_PREFIX not set and mesa_prefix directory not found
        echo The INF generation may be skipped
        echo.
        echo To build Mesa first, run: build-mesa-only.bat
        echo.
    )
)

if not "%MESA_PREFIX%"=="" (
    echo MESA_PREFIX=%MESA_PREFIX%
    echo.
)

REM Check for required tools
where cl >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: MSVC compiler not found.
    echo Please run from Developer Command Prompt for VS
    pause
    exit /b 1
)

REM Create working directory
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

REM Clone or update driver repository
echo [Step 1/2] Getting KVM guest drivers source code...
if exist "kvm-guest-drivers-windows" (
    echo Driver directory exists, pulling latest changes...
    cd kvm-guest-drivers-windows
    git pull
    cd ..
) else (
    git clone --branch %DRIVER_BRANCH% %DRIVER_REPO% kvm-guest-drivers-windows
    if %errorLevel% neq 0 (
        echo ERROR: Failed to clone driver repository
        pause
        exit /b 1
    )
)
echo.

REM Build driver
echo [Step 2/2] Building viogpu3d driver...
cd kvm-guest-drivers-windows\viogpu
call build_AllNoSdv.bat
if %errorLevel% neq 0 (
    echo WARNING: Driver build may have issues, check output above
)
cd "%WORK_DIR%"
echo.

echo ============================================================================
echo Driver Build Complete!
echo ============================================================================
echo.
echo Output location: %WORK_DIR%\kvm-guest-drivers-windows\viogpu\
echo.
echo ============================================================================

pause
