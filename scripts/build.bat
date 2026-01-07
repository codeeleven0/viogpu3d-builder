@echo off
REM ============================================================================
REM viogpu3d Full Build Script
REM ============================================================================
REM This script builds Mesa virgl and viogpu3d driver
REM Run from "Developer Command Prompt for VS" or "x64 Native Tools Command Prompt"
REM ============================================================================

setlocal EnableDelayedExpansion

echo ============================================================================
echo viogpu3d Full Build Script
echo ============================================================================
echo.

REM Configuration
set "MESA_REPO=https://gitlab.freedesktop.org/max8rr8/mesa"
set "MESA_BRANCH=viogpu_win"
set "DRIVER_REPO=https://github.com/max8rr8/kvm-guest-drivers-windows"
set "DRIVER_BRANCH=viogpu_win"

REM Set working directory
if "%WORK_DIR%"=="" set "WORK_DIR=%CD%\viogpu3d-build"

echo Working directory: %WORK_DIR%
echo.

REM Check for required tools
echo Checking prerequisites...

where cl >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: MSVC compiler (cl.exe) not found.
    echo Please run this script from "Developer Command Prompt for VS"
    echo or "x64 Native Tools Command Prompt for VS"
    pause
    exit /b 1
)

where meson >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: meson not found. Run setup-environment.bat first.
    pause
    exit /b 1
)

where ninja >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: ninja not found. Run setup-environment.bat first.
    pause
    exit /b 1
)

where git >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: git not found. Run setup-environment.bat first.
    pause
    exit /b 1
)

where win_flex >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: win_flex not found. Run setup-environment.bat first.
    pause
    exit /b 1
)

echo All prerequisites found.
echo.

REM Create working directory
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

REM Create mesa prefix directory
echo [Step 1/6] Creating mesa prefix directory...
if not exist "mesa_prefix" mkdir mesa_prefix
set "MESA_PREFIX=%WORK_DIR%\mesa_prefix"
echo MESA_PREFIX=%MESA_PREFIX%
echo.

REM Clone Mesa
echo [Step 2/6] Cloning Mesa source code...
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
echo [Step 3/6] Configuring Mesa build...
cd mesa
if not exist "build" mkdir build
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
echo [Step 4/6] Building and installing Mesa...
ninja install
if %errorLevel% neq 0 (
    echo ERROR: Mesa build failed
    pause
    exit /b 1
)
cd "%WORK_DIR%"
echo.

REM Clone driver repository
echo [Step 5/6] Cloning KVM guest drivers...
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
echo [Step 6/6] Building viogpu3d driver...
cd kvm-guest-drivers-windows\viogpu
call build_AllNoSdv.bat
if %errorLevel% neq 0 (
    echo WARNING: Driver build may have issues, check output above
)
cd "%WORK_DIR%"
echo.

REM Collect outputs
echo ============================================================================
echo Build Complete!
echo ============================================================================
echo.
echo Mesa DLLs location:
echo   %MESA_PREFIX%\bin\
echo.
echo Driver files location:
echo   %WORK_DIR%\kvm-guest-drivers-windows\viogpu\
echo.
echo Key files:
if exist "%MESA_PREFIX%\bin\viogpu_wgl.dll" (
    echo   [OK] viogpu_wgl.dll (OpenGL driver)
) else (
    echo   [MISSING] viogpu_wgl.dll
)
if exist "%MESA_PREFIX%\bin\viogpu_d3d10.dll" (
    echo   [OK] viogpu_d3d10.dll (D3D10 driver)
) else (
    echo   [MISSING] viogpu_d3d10.dll
)
echo.
echo ============================================================================

pause
