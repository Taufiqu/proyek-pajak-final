@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [STEP 2] Frontend Dependencies Only
echo ================================================
echo [INFO] Script khusus untuk install frontend dependencies
echo.

REM ========== CHECK NODE.JS ==========
echo [CHECK] Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js tidak ditemukan!
    echo [MANUAL] Install dari: https://nodejs.org/
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%v in ('node --version 2^>^&1') do set NODE_VERSION=%%v
    echo [SUCCESS] Node.js !NODE_VERSION! ditemukan
)

echo [CHECK] Checking npm...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm tidak ditemukan!
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%v in ('npm --version 2^>^&1') do set NPM_VERSION=%%v
    echo [SUCCESS] npm !NPM_VERSION! ditemukan
)

REM ========== SETUP FRONTEND ==========
echo.
echo ================================================
echo [FRONTEND] Installing Frontend Dependencies
echo ================================================

cd /d "%~dp0frontend"
if %errorlevel% neq 0 (
    echo [ERROR] Folder frontend tidak ditemukan!
    echo [CURRENT] Current directory: %CD%
    echo [ERROR] Pastikan script dijalankan dari root folder
    pause
    exit /b 1
)

echo [INFO] Current directory: %CD%

echo [INFO] Checking package.json...
if exist package.json (
    echo [SUCCESS] package.json ditemukan
) else (
    echo [ERROR] package.json tidak ditemukan!
    pause
    exit /b 1
)

echo [INFO] Cleaning previous installation...
if exist node_modules (
    echo [INFO] Removing old node_modules...
    rmdir /s /q node_modules
)
if exist package-lock.json (
    echo [INFO] Removing package-lock.json...
    del package-lock.json
)

echo [INFO] Setting npm cache and timeout...
npm config set cache-min 9999999
npm config set fetch-retry-maxtimeout 600000
npm config set fetch-retry-mintimeout 10000

echo [INFO] Installing npm dependencies...
echo [INFO] This may take several minutes, please wait...
npm install --verbose --no-optional
set NPM_EXIT_CODE=!errorlevel!

echo.
if !NPM_EXIT_CODE! neq 0 (
    echo [ERROR] npm install gagal!
    echo [ERROR] Exit code: !NPM_EXIT_CODE!
    echo [DEBUG] Trying alternative installation...
    
    echo [ALT] Trying npm install without optional dependencies...
    npm install --production --no-optional
    
    if !errorlevel! neq 0 (
        echo [ERROR] Alternative npm install juga gagal
        echo [SOLUTION] Coba manual:
        echo   1. cd frontend
        echo   2. npm cache clean --force
        echo   3. npm install
        pause
        exit /b 1
    )
)

echo [SUCCESS] npm install completed!

echo [INFO] Testing npm packages...
if exist node_modules (
    echo [SUCCESS] node_modules folder created
) else (
    echo [ERROR] node_modules tidak terbuat
    pause
    exit /b 1
)

echo.
echo ================================================
echo [SUCCESS] Frontend Dependencies Installed!
echo ================================================
echo [NEXT] Run step3_test_all.bat untuk test semua dependencies
echo.
pause
