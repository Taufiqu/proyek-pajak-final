@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [ROBUST] Pajak Tools - Setup Robust Version
echo ================================================
echo [INFO] Script versi robust dengan error handling extra
echo.

REM Trap any errors and prevent sudden exit
set "SCRIPT_ERROR=0"

REM ========== ADMIN CHECK ==========
echo [CHECK] Checking administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Script tidak berjalan sebagai Administrator
    echo [WARNING] Beberapa instalasi otomatis mungkin gagal
    echo [CONTINUE] Melanjutkan tanpa hak Administrator...
    echo.
) else (
    echo [SUCCESS] Running with Administrator privileges
)

REM ========== CHECK CHOCOLATEY ==========
echo [CHECK] Checking Chocolatey installation...
choco --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Chocolatey found
    set USE_CHOCO=1
) else (
    echo [INFO] Chocolatey not found, using alternative methods
    set USE_CHOCO=
)

REM ========== CHECK WINGET ==========
echo [CHECK] Checking Winget installation...
winget --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Winget found
    set USE_WINGET=1
) else (
    echo [INFO] Winget not found
    set USE_WINGET=
)

REM ========== CHECK PYTHON ==========
echo [CHECK] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python tidak ditemukan
    echo [MANUAL] Silahkan install Python dari: https://www.python.org/downloads/
    echo [MANUAL] Pastikan centang "Add Python to PATH"
    set SCRIPT_ERROR=1
    goto :error_exit
) else (
    for /f "tokens=2" %%v in ('python --version 2^>^&1') do set PYTHON_VERSION=%%v
    echo [SUCCESS] Python !PYTHON_VERSION! ditemukan
)

REM ========== CHECK NODE.JS ==========
echo [CHECK] Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js tidak ditemukan
    echo [MANUAL] Silahkan install Node.js dari: https://nodejs.org/
    set SCRIPT_ERROR=1
    goto :error_exit
) else (
    for /f "tokens=*" %%v in ('node --version 2^>^&1') do set NODE_VERSION=%%v
    echo [SUCCESS] Node.js !NODE_VERSION! ditemukan
)

REM ========== SETUP BACKEND ==========
echo.
echo ================================================
echo [BACKEND] Setting up Backend (Python Flask)
echo ================================================

cd /d "%~dp0backend"
if %errorlevel% neq 0 (
    echo [ERROR] Folder backend tidak ditemukan!
    set SCRIPT_ERROR=1
    goto :error_exit
)

echo [INFO] Membuat virtual environment...
if exist venv (
    echo [INFO] Virtual environment sudah ada, menggunakan yang ada...
) else (
    echo [INFO] Membuat virtual environment baru...
    python -m venv venv
    if !errorlevel! neq 0 (
        echo [ERROR] Gagal membuat virtual environment
        set SCRIPT_ERROR=1
        goto :error_exit
    )
    echo [SUCCESS] Virtual environment berhasil dibuat
)

echo [INFO] Mengaktifkan virtual environment...
if exist venv\Scripts\activate.bat (
    call venv\Scripts\activate.bat
    if !errorlevel! neq 0 (
        echo [ERROR] Gagal mengaktifkan virtual environment
        set SCRIPT_ERROR=1
        goto :error_exit
    )
    echo [SUCCESS] Virtual environment berhasil diaktifkan
) else (
    echo [ERROR] File venv\Scripts\activate.bat tidak ditemukan
    set SCRIPT_ERROR=1
    goto :error_exit
)

echo [INFO] Upgrading pip...
python -m pip install --upgrade pip >nul 2>&1
if !errorlevel! neq 0 (
    echo [WARNING] Pip upgrade gagal, melanjutkan dengan versi lama...
) else (
    echo [SUCCESS] Pip berhasil diupgrade
)

echo [INFO] Installing critical packages...
pip install Flask Flask-Cors Flask-SQLAlchemy Flask-Migrate SQLAlchemy python-dotenv
if !errorlevel! neq 0 (
    echo [ERROR] Gagal install Flask packages
    set SCRIPT_ERROR=1
    goto :error_exit
)
echo [SUCCESS] Critical packages installed

echo [INFO] Installing additional packages...
if exist requirements.txt (
    pip install -r requirements.txt --timeout 300 >nul 2>&1
    if !errorlevel! neq 0 (
        echo [WARNING] Beberapa packages gagal install - melanjutkan...
    ) else (
        echo [SUCCESS] All requirements installed
    )
) else (
    echo [WARNING] requirements.txt tidak ditemukan, menggunakan packages minimal
)

echo [SUCCESS] Backend setup selesai

REM ========== SETUP FRONTEND ==========
echo.
echo ================================================
echo [FRONTEND] Setting up Frontend (React)
echo ================================================

cd /d "%~dp0frontend"
if %errorlevel% neq 0 (
    echo [ERROR] Folder frontend tidak ditemukan!
    set SCRIPT_ERROR=1
    goto :error_exit
)

echo [INFO] Installing dependencies dengan npm...
npm install
if !errorlevel! neq 0 (
    echo [ERROR] Gagal install dependencies frontend
    set SCRIPT_ERROR=1
    goto :error_exit
)

echo [SUCCESS] Frontend setup selesai

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
echo [SUCCESS] Setup dan Start Completed!
echo ================================================
echo.
echo [INFO] Aplikasi sedang berjalan di:
echo   - Backend (API): http://localhost:5000
echo   - Frontend (Web): http://localhost:3000
echo.
echo [INFO] Browser akan terbuka otomatis untuk frontend
echo [DONE] Script selesai. Tekan tombol apapun untuk keluar...
pause
exit /b 0

:error_exit
echo.
echo ================================================
echo [ERROR] Script dihentikan karena error
echo ================================================
echo [INFO] Error yang terjadi:
if %SCRIPT_ERROR% equ 1 (
    echo   - Ada masalah dengan setup environment
    echo   - Periksa instalasi Python dan Node.js
    echo   - Pastikan script dijalankan dari folder yang benar
)
echo.
echo [MANUAL] Langkah manual yang bisa dilakukan:
echo 1. Install Python dari: https://www.python.org/downloads/
echo 2. Install Node.js dari: https://nodejs.org/
echo 3. Restart komputer setelah instalasi
echo 4. Jalankan script ini lagi
echo.
echo [PAUSE] Tekan tombol apapun untuk keluar...
pause
exit /b %SCRIPT_ERROR%
