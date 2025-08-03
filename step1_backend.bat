@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [STEP 1] Backend Dependencies Only
echo ================================================
echo [INFO] Script khusus untuk install backend dependencies
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

REM ========== SETUP BACKEND ==========
echo.
echo ================================================
echo [BACKEND] Installing Backend Dependencies
echo ================================================

cd /d "%~dp0backend"
if %errorlevel% neq 0 (
    echo [ERROR] Folder backend tidak ditemukan!
    echo [CURRENT] Current directory: %CD%
    pause
    exit /b 1
)

echo [INFO] Current directory: %CD%

echo [INFO] Setting up virtual environment...
if exist venv (
    echo [INFO] Virtual environment sudah ada
) else (
    echo [INFO] Creating virtual environment...
    python -m venv venv
    if !errorlevel! neq 0 (
        echo [ERROR] Gagal membuat virtual environment
        pause
        exit /b 1
    )
)

echo [INFO] Activating virtual environment...
if exist venv\Scripts\activate.bat (
    call venv\Scripts\activate.bat
    echo [SUCCESS] Virtual environment aktif
) else (
    echo [ERROR] activate.bat tidak ditemukan
    pause
    exit /b 1
)

echo [INFO] Upgrading pip...
python -m pip install --upgrade pip

echo [INFO] Installing Flask packages...
pip install Flask Flask-Cors Flask-SQLAlchemy Flask-Migrate SQLAlchemy python-dotenv
if !errorlevel! neq 0 (
    echo [ERROR] Flask packages gagal install
    pause
    exit /b 1
)

echo [INFO] Installing Pillow...
pip install Pillow
if !errorlevel! neq 0 (
    echo [ERROR] Pillow gagal install
    pause
    exit /b 1
)

echo [INFO] Installing utility packages...
pip install Flask-RESTful openpyxl thefuzz pandas psycopg2-binary pyspellchecker textdistance

echo [INFO] Testing imports...
python -c "from PIL import Image; print('[TEST] PIL OK')"
python -c "import flask; print('[TEST] Flask OK')"

echo.
echo ================================================
echo [SUCCESS] Backend Dependencies Installed!
echo ================================================
echo [NEXT] Run step2_frontend.bat untuk install frontend
echo.
pause
