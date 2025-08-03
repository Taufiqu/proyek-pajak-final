@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [START] Pajak Tools - Setup dan Jalankan Localhost 
echo ================================================
echo [INFO] Script otomatis untuk setup dan menjalankan aplikasi
echo.

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
    echo [ERROR] Python tidak ditemukan, mencoba instalasi otomatis...
    
    if defined USE_CHOCO (
        echo [1/3] Mencoba install Python dengan Chocolatey...
        choco install python -y --force
        if !errorlevel! equ 0 (
            echo [SUCCESS] Python berhasil diinstall dengan Chocolatey
            goto :check_python_success
        )
        
        echo [1/3] Chocolatey python gagal, mencoba python3...
        choco install python3 -y --force
        if !errorlevel! equ 0 (
            echo [SUCCESS] Python3 berhasil diinstall dengan Chocolatey
            goto :check_python_success
        )
    )
    
    if defined USE_WINGET (
        echo [2/3] Mencoba install Python dengan Winget...
        winget install Python.Python.3 --silent
        if !errorlevel! equ 0 (
            echo [SUCCESS] Python berhasil diinstall dengan Winget
            goto :check_python_success
        )
        
        winget install Python.Python.3.11 --silent
        if !errorlevel! equ 0 (
            echo [SUCCESS] Python 3.11 berhasil diinstall dengan Winget
            goto :check_python_success
        )
    )
    
    echo [ERROR] Semua metode instalasi otomatis Python gagal
    echo.
    echo [MANUAL] Instalasi manual Python diperlukan!
    echo Silahkan download dan install Python dari: https://www.python.org/downloads/
    echo [PENTING] Centang "Add Python to PATH" saat instalasi
    echo.
    echo Setelah install Python, silahkan RESTART komputer dan jalankan script ini lagi.
    echo.
    echo [PAUSE] Tekan tombol apapun untuk keluar...
    pause
    exit /b 1
    
) else (
    :check_python_success
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

echo [ERROR] Node.js tidak ditemukan, mencoba instalasi otomatis...

if defined USE_CHOCO (
    echo [1/3] Mencoba install Node.js dengan Chocolatey...
    choco install nodejs -y --force
    if !errorlevel! equ 0 (
        echo [SUCCESS] Node.js berhasil diinstall dengan Chocolatey
        goto :node_ready
    )
    
    echo [1/3] Chocolatey nodejs gagal, mencoba nodejs-lts...
    choco install nodejs-lts -y --force
    if !errorlevel! equ 0 (
        echo [SUCCESS] Node.js LTS berhasil diinstall dengan Chocolatey
        goto :node_ready
    )
)

if defined USE_WINGET (
    echo [2/3] Mencoba install Node.js dengan Winget...
    winget install OpenJS.NodeJS --silent
    if !errorlevel! equ 0 (
        echo [SUCCESS] Node.js berhasil diinstall dengan Winget
        goto :node_ready
    )
    
    winget install OpenJS.NodeJS.LTS --silent
    if !errorlevel! equ 0 (
        echo [SUCCESS] Node.js LTS berhasil diinstall dengan Winget
        goto :node_ready
    )
)

echo [ERROR] Semua metode instalasi otomatis Node.js gagal
echo.
echo [MANUAL] Instalasi manual Node.js diperlukan!
echo Silahkan download dan install Node.js dari: https://nodejs.org/
echo.
echo Setelah install Node.js, silahkan RESTART komputer dan jalankan script ini lagi.
echo.
echo [PAUSE] Tekan tombol apapun untuk keluar...
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
    echo [ERROR] Pastikan script dijalankan dari root folder project
    echo [PAUSE] Tekan tombol apapun untuk keluar...
    pause
    exit /b 1
)

echo [INFO] Membuat virtual environment...
if exist venv (
    echo [INFO] Virtual environment sudah ada, menggunakan yang ada...
) else (
    echo [INFO] Membuat virtual environment baru...
    python -m venv venv
    if !errorlevel! neq 0 (
        echo [ERROR] Gagal membuat virtual environment
        echo [ERROR] Pastikan Python terinstall dengan benar
        echo [PAUSE] Tekan tombol apapun untuk keluar...
        pause
        exit /b 1
    )
    echo [SUCCESS] Virtual environment berhasil dibuat
)

echo [INFO] Mengaktifkan virtual environment...
if exist venv\Scripts\activate.bat (
    call venv\Scripts\activate.bat
    if !errorlevel! neq 0 (
        echo [ERROR] Gagal mengaktifkan virtual environment
        echo [ERROR] Coba hapus folder venv dan jalankan script lagi
        echo [PAUSE] Tekan tombol apapun untuk keluar...
        pause
        exit /b 1
    )
    echo [SUCCESS] Virtual environment berhasil diaktifkan
) else (
    echo [ERROR] File venv\Scripts\activate.bat tidak ditemukan
    echo [ERROR] Virtual environment mungkin corrupt, hapus folder venv dan coba lagi
    echo [PAUSE] Tekan tombol apapun untuk keluar...
    pause
    exit /b 1
)

echo [INFO] Upgrading pip...
python -m pip install --upgrade pip
if !errorlevel! neq 0 (
    echo [WARNING] Pip upgrade gagal, melanjutkan dengan versi lama...
)

echo [INFO] Installing dependencies...
if exist requirements.txt (
    echo [STEP 1/3] Installing critical Flask packages...
    pip install Flask Flask-Cors Flask-SQLAlchemy Flask-Migrate SQLAlchemy python-dotenv
    if !errorlevel! neq 0 (
        echo [ERROR] Gagal install Flask packages
        echo [ERROR] Periksa koneksi internet dan coba lagi
        echo [PAUSE] Tekan tombol apapun untuk keluar...
        pause
        exit /b 1
    )
    
    echo [STEP 2/3] Installing utility packages...
    pip install Flask-RESTful pytesseract Pillow pdf2image openpyxl thefuzz pandas psycopg2-binary pyspellchecker textdistance
    if !errorlevel! neq 0 (
        echo [WARNING] Beberapa utility packages gagal install, melanjutkan...
    )
    
    echo [STEP 3/3] Installing remaining packages...
    pip install -r requirements.txt --timeout 300
    if !errorlevel! neq 0 (
        echo [WARNING] Beberapa packages gagal install - aplikasi mungkin masih bisa berjalan untuk fitur dasar
        echo [WARNING] Error packages biasanya: numpy, opencv, torch (butuh build tools)
    )
    
    echo [SUCCESS] Dependency installation completed
) else (
    echo [ERROR] File requirements.txt tidak ditemukan!
    echo [ERROR] Pastikan script dijalankan dari root folder project
    echo [PAUSE] Tekan tombol apapun untuk keluar...
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
    echo [ERROR] Pastikan script dijalankan dari root folder project
    echo [PAUSE] Tekan tombol apapun untuk keluar...
    pause
    exit /b 1
)

echo [INFO] Installing dependencies dengan npm...
npm install
if !errorlevel! neq 0 (
    echo [ERROR] Gagal install dependencies frontend
    echo [ERROR] Periksa koneksi internet dan Node.js installation
    echo [PAUSE] Tekan tombol apapun untuk keluar...
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
pause
