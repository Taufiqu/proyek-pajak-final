@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [START] Pajak Tools - Setup dan Jalankan Localhost 
echo ================================================
echo [INFO] Script otomatis untuk setup dan menjalankan aplikasi
echo.

REM ========== CHECK PYTHON ==========
echo [CHECK] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python tidak ditemukan! Silahkan install Python terlebih dahulu.
    echo Download dari: https://www.python.org/downloads/
    pause
    exit /b 1
) else (
    for /f "tokens=2" %%v in ('python --version 2^>^&1') do set PYTHON_VERSION=%%v
    echo [SUCCESS] Python !PYTHON_VERSION! ditemukan
)

REM ========== CHECK NODE.JS ==========
echo [CHECK] Checking Node.js installation...

where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('node --version 2^>^&1') do set NODE_VERSION=%%v
    echo [SUCCESS] Node.js !NODE_VERSION! ditemukan dan berfungsi
    goto :node_ready
)

node --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('node --version 2^>^&1') do set NODE_VERSION=%%v
    echo [SUCCESS] Node.js !NODE_VERSION! ditemukan
    goto :node_ready
)

echo [ERROR] Node.js tidak ditemukan di PATH
echo [INFO] Checking common installation locations...

if exist "C:\Program Files\nodejs\node.exe" (
    echo [FOUND] Node.js ada di: C:\Program Files\nodejs\
    echo [INFO] Silahkan tambahkan ke PATH secara manual atau restart komputer
) else if exist "C:\Program Files (x86)\nodejs\node.exe" (
    echo [FOUND] Node.js ada di: C:\Program Files (x86)\nodejs\
    echo [INFO] Silahkan tambahkan ke PATH secara manual atau restart komputer  
) else (
    echo [ERROR] Node.js tidak ditemukan
    echo [INFO] Silahkan install Node.js dari: https://nodejs.org/
)

echo.
echo [MANUAL ACTION REQUIRED]
echo 1. Install Node.js jika belum ada
echo 2. Restart komputer setelah instalasi
echo 3. Jalankan script ini lagi
echo.
pause
exit /b 1

:node_ready
echo [INFO] Node.js sudah siap

REM ========== SETUP BACKEND ==========
echo.
echo ================================================
echo [BACKEND] Setting up Backend (Python Flask)
echo ================================================

cd /d "%~dp0backend"
if %errorlevel% neq 0 (
    echo [ERROR] Folder backend tidak ditemukan!
    pause
    exit /b 1
)

echo [INFO] Membuat virtual environment...
if exist venv (
    echo [INFO] Virtual environment sudah ada, menggunakan yang ada...
) else (
    python -m venv venv
    if %errorlevel% neq 0 (
        echo [ERROR] Gagal membuat virtual environment
        pause
        exit /b 1
    )
)

echo [INFO] Mengaktifkan virtual environment...
call venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo [ERROR] Gagal mengaktifkan virtual environment
    pause
    exit /b 1
)

echo [INFO] Upgrading pip...
python -m pip install --upgrade pip

echo [INFO] Installing dependencies dari requirements.txt...
if exist requirements.txt (
    echo [INFO] Installing basic packages first...
    pip install Flask Flask-Cors Flask-SQLAlchemy Flask-Migrate SQLAlchemy python-dotenv
    pip install Flask-RESTful pytesseract Pillow pdf2image openpyxl thefuzz pandas psycopg2-binary
    pip install pyspellchecker textdistance
    
    echo [INFO] Installing remaining packages (some may fail on devices without build tools)...
    pip install -r requirements.txt --timeout 300 || (
        echo [WARNING] Some packages failed to install - aplikasi tetap bisa berjalan untuk fitur dasar
    )
    echo [INFO] Dependency installation completed
) else (
    echo [ERROR] File requirements.txt tidak ditemukan!
    pause
    exit /b 1
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
    pause
    exit /b 1
)

echo [INFO] Installing dependencies dengan npm...
npm install
if %errorlevel% neq 0 (
    echo [ERROR] Gagal install dependencies frontend
    pause
    exit /b 1
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
timeout /t 5 /nobreak >nul

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
echo [INFO] Untuk stop aplikasi, tutup kedua window terminal yang terbuka
echo.
echo [NOTICE] Jika ada error dengan numpy/opencv, aplikasi tetap bisa berjalan
echo [NOTICE] untuk fitur dasar. Install Visual Studio Build Tools jika diperlukan.
echo.
echo [DONE] Script selesai. Tekan tombol apapun untuk keluar...
pause >nul
