@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [STEP 4] Start Applications
echo ================================================
echo [INFO] Script untuk start aplikasi setelah semua dependencies OK
echo.

REM ========== QUICK CHECKS ==========
echo [QUICK CHECK] Verifying setup...

cd /d "%~dp0backend"
if not exist venv (
    echo [ERROR] Backend virtual environment tidak ditemukan!
    echo [SOLUTION] Jalankan step1_backend.bat terlebih dahulu
    pause
    exit /b 1
)

cd /d "%~dp0frontend"
if not exist node_modules (
    echo [ERROR] Frontend node_modules tidak ditemukan!
    echo [SOLUTION] Jalankan step2_frontend.bat terlebih dahulu
    pause
    exit /b 1
)

echo [SUCCESS] Quick checks passed

REM ========== START BACKEND ==========
echo.
echo ================================================
echo [START BACKEND] Starting Flask Backend
echo ================================================

cd /d "%~dp0backend"
echo [INFO] Starting Backend (Flask) di port 5000...
start "Backend-Flask" cmd /k "echo [BACKEND] Starting Flask server... && call venv\Scripts\activate.bat && python app.py"

echo [INFO] Menunggu backend untuk start...
echo [INFO] Backend sedang loading dependencies...
timeout /t 20 /nobreak >nul

REM ========== START FRONTEND ==========
echo.
echo ================================================
echo [START FRONTEND] Starting React Frontend
echo ================================================

cd /d "%~dp0frontend"
echo [INFO] Starting Frontend (React) di port 3000...
start "Frontend-React" cmd /k "echo [FRONTEND] Starting React server... && npm start"

echo.
echo ================================================
echo [SUCCESS] Applications Started!
echo ================================================
echo.
echo [INFO] Aplikasi sedang berjalan di:
echo   - Backend (API): http://localhost:5000
echo   - Frontend (Web): http://localhost:3000
echo.
echo [INFO] Jika ada error:
echo   1. Cek window "Backend-Flask" untuk error backend
echo   2. Cek window "Frontend-React" untuk error frontend
echo   3. Tunggu beberapa saat untuk aplikasi fully load
echo.
echo [INFO] Browser akan terbuka otomatis untuk frontend
echo [INFO] Untuk stop aplikasi, tutup kedua window terminal
echo.
echo [DONE] Script selesai. Tekan tombol apapun untuk keluar...
pause
