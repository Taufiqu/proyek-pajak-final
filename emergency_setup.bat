@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [EMERGENCY] Pajak Tools - Setup Minimal
echo ================================================
echo [INFO] Script minimal untuk install dependencies yang gagal
echo.

REM ========== CHECK PYTHON ==========
echo [CHECK] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python tidak ditemukan!
    echo [ERROR] Install Python terlebih dahulu dari: https://www.python.org/downloads/
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
    echo [ERROR] Install Node.js terlebih dahulu dari: https://nodejs.org/
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%v in ('node --version 2^>^&1') do set NODE_VERSION=%%v
    echo [SUCCESS] Node.js !NODE_VERSION! ditemukan
)

REM ========== SETUP BACKEND ==========
echo.
echo ================================================
echo [BACKEND] Installing Missing Dependencies
echo ================================================

cd /d "%~dp0backend"
if %errorlevel% neq 0 (
    echo [ERROR] Folder backend tidak ditemukan!
    pause
    exit /b 1
)

echo [INFO] Mengaktifkan virtual environment...
if exist venv\Scripts\activate.bat (
    call venv\Scripts\activate.bat
    echo [SUCCESS] Virtual environment aktif
) else (
    echo [INFO] Membuat virtual environment baru...
    python -m venv venv
    call venv\Scripts\activate.bat
    echo [SUCCESS] Virtual environment dibuat dan aktif
)

echo [INFO] Upgrading pip...
python -m pip install --upgrade pip

echo [INFO] Installing PILLOW (Critical for image processing)...
pip install Pillow
if !errorlevel! neq 0 (
    echo [ERROR] Gagal install Pillow!
    echo [SOLUTION] Install Microsoft Visual C++ Build Tools:
    echo   https://visualstudio.microsoft.com/visual-cpp-build-tools/
    echo [SOLUTION] Atau coba: pip install --upgrade --force-reinstall Pillow
    pause
    exit /b 1
) else (
    echo [SUCCESS] Pillow berhasil diinstall
)

echo [INFO] Installing critical Flask packages...
pip install Flask Flask-Cors Flask-SQLAlchemy Flask-Migrate SQLAlchemy python-dotenv
echo [SUCCESS] Flask packages installed

echo [INFO] Installing essential utility packages...
pip install Flask-RESTful openpyxl thefuzz pandas psycopg2-binary pyspellchecker textdistance
echo [SUCCESS] Utility packages installed

echo [INFO] Testing Pillow import...
python -c "from PIL import Image; print('✓ Pillow working correctly')"
if !errorlevel! neq 0 (
    echo [ERROR] Pillow masih bermasalah!
    pause
    exit /b 1
)

echo [SUCCESS] Backend dependencies fixed!

REM ========== SETUP FRONTEND ==========
echo.
echo ================================================
echo [FRONTEND] Installing Frontend Dependencies
echo ================================================

cd /d "%~dp0frontend"
if %errorlevel% neq 0 (
    echo [ERROR] Folder frontend tidak ditemukan!
    pause
    exit /b 1
)

echo [INFO] Installing npm dependencies...
npm install
if !errorlevel! neq 0 (
    echo [ERROR] NPM install gagal!
    echo [SOLUTION] Coba hapus node_modules dan package-lock.json, lalu run lagi
    pause
    exit /b 1
)

echo [SUCCESS] Frontend dependencies installed!

REM ========== TEST INSTALLATION ==========
echo.
echo ================================================
echo [TEST] Testing Installation
echo ================================================

echo [TEST] Testing backend imports...
cd /d "%~dp0backend"
call venv\Scripts\activate.bat
python -c "from bukti_setor.utils import allowed_file; print('✓ Backend imports working')"
if !errorlevel! neq 0 (
    echo [ERROR] Backend imports masih error!
    pause
    exit /b 1
)

echo [SUCCESS] Installation test passed!

echo.
echo ================================================
echo [SUCCESS] Emergency Setup Completed!
echo ================================================
echo.
echo [INFO] Sekarang coba jalankan start_only.bat untuk mulai aplikasi
echo.
pause
