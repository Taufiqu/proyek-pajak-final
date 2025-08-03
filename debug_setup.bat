@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [DEBUG] Pajak Tools - Debug Mode
echo ================================================
echo [DEBUG] Current directory: %CD%
echo [DEBUG] Script location: %~dp0
echo.

REM ========== CHECK PYTHON ==========
echo [CHECK] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python tidak ditemukan!
    pause
    exit /b 1
) else (
    for /f "tokens=2" %%v in ('python --version 2^>^&1') do set PYTHON_VERSION=%%v
    echo [SUCCESS] Python !PYTHON_VERSION! ditemukan
)

REM ========== SETUP BACKEND ONLY ==========
echo.
echo ================================================
echo [BACKEND] Setting up Backend (Python Flask)
echo ================================================

cd /d "%~dp0backend"
if %errorlevel% neq 0 (
    echo [ERROR] Folder backend tidak ditemukan!
    echo [DEBUG] Looking for backend folder...
    dir /b | findstr backend
    pause
    exit /b 1
)

echo [DEBUG] Now in backend directory: %CD%

echo [INFO] Membuat virtual environment...
if exist venv (
    echo [INFO] Virtual environment sudah ada, menggunakan yang ada...
) else (
    echo [INFO] Creating new virtual environment...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo [ERROR] Gagal membuat virtual environment
        pause
        exit /b 1
    )
)

echo [INFO] Mengaktifkan virtual environment...
if exist "venv\Scripts\activate.bat" (
    echo [DEBUG] Found activate.bat, activating...
    call venv\Scripts\activate.bat
    if %errorlevel% neq 0 (
        echo [ERROR] Gagal mengaktifkan virtual environment
        pause
        exit /b 1
    )
    echo [SUCCESS] Virtual environment activated
) else (
    echo [ERROR] venv\Scripts\activate.bat not found!
    echo [DEBUG] Contents of venv\Scripts:
    dir venv\Scripts
    pause
    exit /b 1
)

echo [INFO] Testing Python in venv...
python --version
if %errorlevel% neq 0 (
    echo [ERROR] Python not working in venv
    pause
    exit /b 1
)

echo [INFO] Testing pip in venv...
pip --version
if %errorlevel% neq 0 (
    echo [ERROR] Pip not working in venv
    pause
    exit /b 1
)

echo [INFO] Installing Flask only (for testing)...
pip install Flask
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install Flask
    echo [DEBUG] Trying with --user flag...
    pip install --user Flask
    if %errorlevel% neq 0 (
        echo [ERROR] Flask installation completely failed
        pause
        exit /b 1
    )
)

echo [SUCCESS] Flask installed successfully!
echo [INFO] Testing if app.py exists...
if exist app.py (
    echo [SUCCESS] app.py found
    echo [INFO] Testing app.py import (this might show errors)...
    python -c "import app" 2>error.txt
    if %errorlevel% neq 0 (
        echo [WARNING] app.py has import errors, showing first few:
        type error.txt | head -5
    ) else (
        echo [SUCCESS] app.py imports successfully!
    )
) else (
    echo [ERROR] app.py not found in backend folder!
    echo [DEBUG] Contents of backend folder:
    dir /b
)

echo.
echo ================================================
echo [DEBUG] Debug completed successfully!
echo ================================================
echo [INFO] Jika sampai sini tanpa error, berarti setup dasar OK
echo [INFO] Silahkan jalankan script utama atau laporkan error yang muncul
echo.
pause
