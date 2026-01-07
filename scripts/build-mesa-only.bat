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
    -Dgallium-d3d10-dll-name=viogpu_d3d10 ^
    -Db_vscrt=mt

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
