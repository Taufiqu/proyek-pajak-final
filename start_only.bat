@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [START ONLY] Pajak Tools - Jalankan Aplikasi
echo ================================================
echo [INFO] Script untuk menjalankan aplikasi yang sudah di-setup
echo.

REM ========== CHECK PYTHON ==========
echo [CHECK] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python tidak ditemukan!
    echo [INFO] Jalankan step1_backend.bat atau setup_wizard.bat untuk setup Python
    echo [PAUSE] Tekan tombol apapun untuk keluar...
    pause
    exit /b 1
) else (
    for /f "tokens=2" %%v in ('python --version 2^>^&1') do set PYTHON_VERSION=%%v
    echo [SUCCESS] Python !PYTHON_VERSION! ditemukan
)

REM ========== CHECK NODE.JS ==========
echo [CHECK] Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js tidak ditemukan!
    echo [INFO] Jalankan step2_manual.bat atau setup_wizard.bat untuk setup Node.js
    echo [PAUSE] Tekan tombol apapun untuk keluar...
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%v in ('node --version 2^>^&1') do set NODE_VERSION=%%v
    echo [SUCCESS] Node.js !NODE_VERSION! ditemukan
)

REM ========== CHECK BACKEND SETUP ==========
echo [CHECK] Checking backend setup...
if not exist "%~dp0backend\venv" (
    echo [ERROR] Virtual environment tidak ditemukan!
    echo [INFO] Jalankan step1_backend.bat atau setup_wizard.bat untuk setup backend
    echo [PAUSE] Tekan tombol apapun untuk keluar...
    pause
    exit /b 1
) else (
    echo [SUCCESS] Virtual environment ditemukan
)

REM ========== CHECK FRONTEND SETUP ==========
echo [CHECK] Checking frontend setup...
if not exist "%~dp0frontend\node_modules" (
    echo [ERROR] Node modules tidak ditemukan!
    echo [INFO] Jalankan step2_manual.bat atau setup_wizard.bat untuk setup frontend
    echo [PAUSE] Tekan tombol apapun untuk keluar...
    pause
    exit /b 1
) else (
    echo [SUCCESS] Node modules ditemukan
)

REM ========== START SERVICES ==========
echo.
echo ================================================
echo [START] Starting Applications
echo ================================================

echo [INFO] Starting Backend (Flask) di port 5000...
cd /d "%~dp0backend"
start "Backend-Flask" cmd /k "call venv\Scripts\activate.bat && python app.py"

echo [INFO] Menunggu backend start...
timeout /t 20 /nobreak >nul

echo [INFO] Starting Frontend (React) di port 3000...
cd /d "%~dp0frontend"
start "Frontend-React" cmd /k "npm start"

echo.
echo ================================================
echo [SUCCESS] Applications Started!
echo ================================================
echo.
echo [INFO] Aplikasi sedang berjalan di:
echo   - Backend (API): http://localhost:5000
echo   - Frontend (Web): http://localhost:3000
echo.
echo [INFO] Browser akan terbuka otomatis untuk frontend
echo [INFO] Untuk stop aplikasi, tutup kedua window terminal yang terbuka
echo.
echo [DONE] Script selesai. Tekan tombol apapun untuk keluar...
pause
