@echo off
setlocal enabledelayedexpansion

echo ================================================
echo 🚀 PROYEK PAJAK - ADVANCED SETUP AND STARTUP
echo ================================================
echo.
echo This script will:
echo 1. Check if Python and Node.js are installed
echo 2. Auto-install them if missing (using Chocolatey/winget)
echo 3. Create virtual environment
echo 4. Install Python dependencies
echo 5. Install Node.js dependencies
echo 6. Start both backend and frontend servers
echo.

REM ========== CONFIGURATION ==========
set PYTHON_MIN_VERSION=3.10
set NODE_MIN_VERSION=18
set PROJECT_ROOT=%~dp0
set BACKEND_PATH=%PROJECT_ROOT%backend
set FRONTEND_PATH=%PROJECT_ROOT%frontend
set VENV_PATH=%BACKEND_PATH%\venv

echo 📁 Project Root: %PROJECT_ROOT%
echo 📁 Backend Path: %BACKEND_PATH%
echo 📁 Frontend Path: %FRONTEND_PATH%
echo.

REM ========== CHECK CHOCOLATEY ==========
echo 🔍 Checking package managers...
choco --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 📦 Chocolatey not found. Checking winget...
    winget --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo ❌ Neither Chocolatey nor winget found
        echo 📥 Installing Chocolatey for automatic package management...
        echo This requires Administrator privileges.
        echo.
        powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        if %errorlevel% neq 0 (
            echo ❌ Failed to install Chocolatey
            set USE_MANUAL=1
        ) else (
            echo ✅ Chocolatey installed successfully
            set USE_CHOCO=1
        )
    ) else (
        echo ✅ winget found
        set USE_WINGET=1
    )
) else (
    echo ✅ Chocolatey found
    set USE_CHOCO=1
)

REM ========== CHECK PYTHON ==========
echo 🔍 Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python is not installed
    echo 📥 Installing Python automatically...
    
    if defined USE_CHOCO (
        echo Using Chocolatey to install Python...
        choco install python -y
        if %errorlevel% neq 0 (
            echo ❌ Failed to install Python via Chocolatey
            goto :manual_python
        )
    ) else if defined USE_WINGET (
        echo Using winget to install Python...
        winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements
        if %errorlevel% neq 0 (
            echo ❌ Failed to install Python via winget
            goto :manual_python
        )
    ) else (
        goto :manual_python
    )
    
    echo ✅ Python installed! Refreshing environment...
    call refreshenv >nul 2>&1
    timeout /t 5 /nobreak >nul
    
    python --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo ⚠️ Python installed but not in PATH yet
        echo 🔄 Please RESTART your computer and run this script again
        pause
        exit /b 1
    )
    
    goto :check_python_success
    
    :manual_python
    echo ❌ Automatic installation failed
    echo.
    echo 📥 Manual Python installation required!
    echo Please download and install Python from: https://www.python.org/downloads/
    echo ⚠️  IMPORTANT: Check "Add Python to PATH" during installation
    echo.
    echo After installing Python, please RESTART your computer and run this script again.
    echo.
    pause
    exit /b 1
    
) else (
    :check_python_success
    for /f "tokens=2" %%v in ('python --version 2^>^&1') do set PYTHON_VERSION=%%v
    echo ✅ Python !PYTHON_VERSION! found
)

REM ========== CHECK NODE.JS ==========
echo 🔍 Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed
    echo 📥 Installing Node.js automatically...
    
    if defined USE_CHOCO (
        echo Using Chocolatey to install Node.js...
        choco install nodejs -y
        if %errorlevel% neq 0 (
            echo ❌ Failed to install Node.js via Chocolatey
            goto :manual_node
        )
    ) else if defined USE_WINGET (
        echo Using winget to install Node.js...
        winget install OpenJS.NodeJS --accept-source-agreements --accept-package-agreements
        if %errorlevel% neq 0 (
            echo ❌ Failed to install Node.js via winget
            goto :manual_node
        )
    ) else (
        goto :manual_node
    )
    
    echo ✅ Node.js installed! Refreshing environment...
    call refreshenv >nul 2>&1
    timeout /t 5 /nobreak >nul
    
    node --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo ⚠️ Node.js installed but not in PATH yet
        echo 🔄 Please RESTART your computer and run this script again
        pause
        exit /b 1
    )
    
    goto :check_node_success
    
    :manual_node
    echo ❌ Automatic installation failed
    echo.
    echo 📥 Manual Node.js installation required!
    echo Please download and install Node.js from: https://nodejs.org/
    echo ⚠️  IMPORTANT: Choose "Add to PATH" during installation
    echo.
    echo After installing Node.js, please RESTART your computer and run this script again.
    echo.
    pause
    exit /b 1
    
) else (
    :check_node_success
    for /f "tokens=1" %%v in ('node --version 2^>^&1') do set NODE_VERSION=%%v
    echo ✅ Node.js !NODE_VERSION! found
)

REM ========== CHECK NPM ==========
echo 🔍 Checking npm installation...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm is not installed or not in PATH
    echo Please reinstall Node.js to include npm
    pause
    exit /b 1
) else (
    for /f "tokens=1" %%v in ('npm --version 2^>^&1') do set NPM_VERSION=%%v
    echo ✅ npm !NPM_VERSION! found
)

echo.
echo ========================================
echo 🛠️  SETTING UP DEVELOPMENT ENVIRONMENT
echo ========================================
echo.

REM ========== CREATE VIRTUAL ENVIRONMENT ==========
if not exist "%VENV_PATH%" (
    echo 📦 Creating Python virtual environment...
    cd /d "%BACKEND_PATH%"
    python -m venv venv
    if %errorlevel% neq 0 (
        echo ❌ Failed to create virtual environment
        pause
        exit /b 1
    )
    echo ✅ Virtual environment created successfully
) else (
    echo ✅ Virtual environment already exists
)

REM ========== INSTALL PYTHON DEPENDENCIES ==========
echo 📦 Installing Python dependencies...
cd /d "%BACKEND_PATH%"
call venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo ❌ Failed to activate virtual environment
    pause
    exit /b 1
)

echo Installing/updating pip...
python -m pip install --upgrade pip

echo Installing requirements...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ❌ Failed to install Python dependencies
    echo 💡 Try running: pip install -r requirements.txt manually
    pause
    exit /b 1
)
echo ✅ Python dependencies installed successfully

REM ========== INSTALL NODE.JS DEPENDENCIES ==========
echo 📦 Installing Node.js dependencies...
cd /d "%FRONTEND_PATH%"
if not exist "node_modules" (
    echo Installing npm packages...
    npm install
    if %errorlevel% neq 0 (
        echo ❌ Failed to install Node.js dependencies
        echo 💡 Try running: npm install manually in frontend folder
        pause
        exit /b 1
    )
    echo ✅ Node.js dependencies installed successfully
) else (
    echo ✅ Node.js dependencies already installed
    echo 🔄 Checking for updates...
    npm update
)

echo.
echo ========================================
echo 🚀 STARTING DEVELOPMENT SERVERS
echo ========================================
echo.

REM ========== START BACKEND ==========
echo 📍 Starting Backend (Port 5000 - Flask Default)...
cd /d "%BACKEND_PATH%"
start "Backend Server" cmd /k "call venv\Scripts\activate.bat && python app.py"

echo.
echo ⏳ Waiting 20 seconds for backend to initialize (Poppler, Database, etc.)...
timeout /t 20 /nobreak > nul

REM ========== START FRONTEND ==========
echo 📍 Starting Frontend (Port 3000 - React Default)...
cd /d "%FRONTEND_PATH%"
start "Frontend Server" cmd /k "npm start"

echo.
echo ========================================
echo ✅ SETUP AND STARTUP COMPLETE!
echo ========================================
echo.
echo 📊 Access Points:
echo   Backend API: http://localhost:5000
echo   Frontend:    http://localhost:3000
echo.
echo 💡 Both servers are running in separate windows
echo 💡 Close those windows to stop the servers
echo.
echo If you encounter any issues:
echo 1. Make sure Python and Node.js are in your PATH
echo 2. Restart your computer after installing Python/Node.js
echo 3. Run this script as Administrator if needed
echo.
echo Press any key to exit this setup window...
pause > nul

cd /d "%PROJECT_ROOT%"
