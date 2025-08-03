@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [STEP 2 MINIMAL] Frontend Setup - Minimal Version
echo ================================================
echo [INFO] Version minimal untuk menghindari force close
echo.

echo [CHECK] Testing Node.js...
node --version
if !errorlevel! neq 0 (
    echo [ERROR] Node.js tidak tersedia
    pause
    exit /b 1
)

echo [CHECK] Testing npm...
npm --version
if !errorlevel! neq 0 (
    echo [ERROR] npm tidak tersedia
    pause
    exit /b 1
)

echo [INFO] Node.js dan npm OK, melanjutkan ke frontend setup...

echo [INFO] Changing to frontend directory...
cd /d "%~dp0frontend"
echo [INFO] Current directory: %CD%

if not exist package.json (
    echo [ERROR] package.json tidak ditemukan di: %CD%
    echo [ERROR] Pastikan script dijalankan dari root folder project
    pause
    exit /b 1
)

echo [SUCCESS] package.json ditemukan

echo [INFO] Cleaning old installation...
if exist node_modules (
    echo [INFO] Menghapus node_modules lama...
    rmdir /s /q node_modules
    echo [SUCCESS] node_modules lama dihapus
)

if exist package-lock.json (
    echo [INFO] Menghapus package-lock.json...
    del package-lock.json
    echo [SUCCESS] package-lock.json dihapus
)

echo.
echo [INFO] Memulai npm install...
echo [INFO] Proses ini mungkin memakan waktu beberapa menit
echo [INFO] Jangan tutup window ini sampai selesai
echo.

REM Use basic npm install without complex options
npm install

echo.
echo [INFO] npm install selesai dengan exit code: !errorlevel!

if !errorlevel! neq 0 (
    echo [ERROR] npm install gagal!
    echo [DEBUG] Mencoba npm install alternatif...
    npm install --no-optional --no-audit
    
    if !errorlevel! neq 0 (
        echo [ERROR] npm install alternatif juga gagal
        echo [MANUAL] Coba jalankan manual:
        echo   cd frontend
        echo   npm cache clean --force
        echo   npm install
        pause
        exit /b 1
    ) else (
        echo [SUCCESS] npm install alternatif berhasil
    )
) else (
    echo [SUCCESS] npm install berhasil
)

echo [CHECK] Verifying installation...
if exist node_modules (
    echo [SUCCESS] node_modules folder terbuat
    
    REM Count some folders to verify
    for /f %%i in ('dir node_modules /ad /b 2^>nul ^| find /c /v ""') do set MODULE_COUNT=%%i
    echo [INFO] Ditemukan !MODULE_COUNT! packages di node_modules
    
    if !MODULE_COUNT! gtr 10 (
        echo [SUCCESS] Frontend dependencies berhasil diinstall
    ) else (
        echo [WARNING] node_modules terlihat kosong atau tidak lengkap
        echo [WARNING] Mungkin perlu install ulang
    )
) else (
    echo [ERROR] node_modules tidak terbuat
    echo [ERROR] npm install mungkin gagal
    pause
    exit /b 1
)

echo.
echo ================================================
echo [SUCCESS] Frontend Setup Completed!
echo ================================================
echo [NEXT] Jalankan step3_test_all.bat untuk test dependencies
echo.
pause
