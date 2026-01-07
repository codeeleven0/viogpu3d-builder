@echo off
REM ============================================================================
REM Mesa-only Build Script
REM ============================================================================
REM This script builds only Mesa virgl (useful for testing/updates)
REM Run from "Developer Command Prompt for VS" or "x64 Native Tools Command Prompt"
REM ============================================================================

setlocal EnableDelayedExpansion

echo ============================================================================
echo Mesa virgl Build Script
echo ============================================================================
echo.

REM Configuration
set "MESA_REPO=https://gitlab.freedesktop.org/max8rr8/mesa"
set "MESA_BRANCH=viogpu_win"

REM Set working directory
if "%WORK_DIR%"=="" set "WORK_DIR=%CD%\viogpu3d-build"

echo Working directory: %WORK_DIR%
echo.

REM Check for required tools
where cl >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: MSVC compiler not found.
    echo Please run from Developer Command Prompt for VS
    pause
    exit /b 1
)

where meson >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: meson not found. Run setup-environment.bat first.
    pause
    exit /b 1
)

REM Find Windows SDK headers for d3d10umddi.h and d3dkmddi.h
echo Searching for Windows SDK headers...
set "SDK_FOUND=0"
set "SDK_BASE=C:\Program Files (x86)\Windows Kits\10\Include"

if exist "%SDK_BASE%" (
    for /f "tokens=*" %%d in ('dir /b /ad /o-n "%SDK_BASE%" 2^>nul') do (
        if "!SDK_FOUND!"=="0" (
            set "UM_PATH=%SDK_BASE%\%%d\um"
            set "SHARED_PATH=%SDK_BASE%\%%d\shared"
            if exist "!UM_PATH!\d3d10umddi.h" (
                if exist "!SHARED_PATH!\d3dkmddi.h" (
                    echo Found d3d10umddi.h in: !UM_PATH!
                    echo Found d3dkmddi.h in: !SHARED_PATH!
                    set "INCLUDE=!UM_PATH!;!SHARED_PATH!;%INCLUDE%"
                    set "SDK_FOUND=1"
                )
            )
        )
    )
)

if "!SDK_FOUND!"=="0" (
    echo WARNING: Could not find Windows SDK headers (d3d10umddi.h, d3dkmddi.h)
    echo Mesa D3D10 UMD build may fail. Install Windows SDK or WDK.
)
echo.

REM Create working directory
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

REM Create mesa prefix directory
echo [Step 1/4] Creating mesa prefix directory...
if not exist "mesa_prefix" mkdir mesa_prefix
set "MESA_PREFIX=%WORK_DIR%\mesa_prefix"
echo MESA_PREFIX=%MESA_PREFIX%
echo.

REM Clone or update Mesa
echo [Step 2/4] Getting Mesa source code...
if exist "mesa" (
    echo Mesa directory exists, pulling latest changes...
    cd mesa
    git pull
    cd ..
) else (
    git clone --depth 10 --branch %MESA_BRANCH% %MESA_REPO% mesa
    if %errorLevel% neq 0 (
        echo ERROR: Failed to clone Mesa repository
        pause
        exit /b 1
    )
)
echo.

REM Configure Mesa
echo [Step 3/4] Configuring Mesa build...
cd mesa
if exist "build" (
    echo Cleaning previous build...
    rmdir /s /q build
)
mkdir build
cd build

meson .. --prefix="%MESA_PREFIX%" ^
    -Dgallium-drivers=virgl ^
    -Dgallium-d3d10umd=true ^
    -Dgallium-wgl-dll-name=viogpu_wgl ^
    -Dgallium-d3d10-dll-name=viogpu_d3d10

if %errorLevel% neq 0 (
    echo ERROR: Mesa configuration failed
    pause
    exit /b 1
)
echo.

REM Build and install Mesa
echo [Step 4/4] Building and installing Mesa...
ninja install
if %errorLevel% neq 0 (
    echo ERROR: Mesa build failed
    pause
    exit /b 1
)
cd "%WORK_DIR%"
echo.

echo ============================================================================
echo Mesa Build Complete!
echo ============================================================================
echo.
echo Output location: %MESA_PREFIX%\bin\
echo.
dir /b "%MESA_PREFIX%\bin\*.dll" 2>nul
echo.
echo ============================================================================

pause
