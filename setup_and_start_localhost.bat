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
    echo ❌ Python command not found, trying alternative paths...
    
    REM Check common Python installation paths
    if exist "C:\Python*\python.exe" (
        echo 🔍 Found Python in C:\Python* directory, adding to PATH...
        for /d %%i in ("C:\Python*") do set "PATH=%%i;%%i\Scripts;%PATH%"
        goto :check_python_again
    )
    
    if exist "C:\Program Files\Python*\python.exe" (
        echo 🔍 Found Python in Program Files, adding to PATH...
        for /d %%i in ("C:\Program Files\Python*") do set "PATH=%%i;%%i\Scripts;%PATH%"
        goto :check_python_again
    )
    
    if exist "%LOCALAPPDATA%\Programs\Python\Python*\python.exe" (
        echo 🔍 Found Python in LocalAppData, adding to PATH...
        for /d %%i in ("%LOCALAPPDATA%\Programs\Python\Python*") do set "PATH=%%i;%%i\Scripts;%PATH%"
        goto :check_python_again
    )
    
    :check_python_again
    python --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo 📥 Installing Python automatically...
        
        if defined USE_CHOCO (
            echo [1/3] Trying Chocolatey to install Python...
            choco install python -y --force
            if %errorlevel% equ 0 goto :python_install_success
            
            echo [1/3] Chocolatey failed, trying alternative package...
            choco install python3 -y --force
            if %errorlevel% equ 0 goto :python_install_success
        )
        
        if defined USE_WINGET (
            echo [2/3] Trying winget to install Python...
            winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements --force
            if %errorlevel% equ 0 goto :python_install_success
            
            echo [2/3] Trying alternative winget package...
            winget install Python.Python.3.11 --accept-source-agreements --accept-package-agreements --force
            if %errorlevel% equ 0 goto :python_install_success
        )
        
        echo [3/3] Trying direct download and install...
        echo Downloading Python installer...
        powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe' -OutFile 'python-installer.exe'"
        if exist "python-installer.exe" (
            echo Installing Python silently...
            python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
            timeout /t 30 /nobreak >nul
            del python-installer.exe
            goto :python_install_success
        )
        
        goto :manual_python
        
        :python_install_success
        echo ✅ Python installation completed! Refreshing environment...
        call refreshenv >nul 2>&1
        timeout /t 10 /nobreak >nul
        
        REM Re-check with updated PATH
        python --version >nul 2>&1
        if %errorlevel% neq 0 (
            echo ⚠️ Python installed but not accessible yet
            echo 🔄 Please RESTART your computer and run this script again
            echo 💡 Or manually add Python to your PATH environment variable
            pause
            exit /b 1
        )
    )
    
    goto :check_python_success
    
    :manual_python
    echo ❌ All automatic installation methods failed
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
    echo ❌ Node.js command not found, trying alternative paths...
    
    REM Check common Node.js installation paths
    if exist "C:\Program Files\nodejs\node.exe" (
        echo 🔍 Found Node.js in Program Files, adding to PATH...
        set "PATH=C:\Program Files\nodejs;%PATH%"
        goto :check_node_again
    )
    
    if exist "C:\Program Files (x86)\nodejs\node.exe" (
        echo 🔍 Found Node.js in Program Files (x86), adding to PATH...
        set "PATH=C:\Program Files (x86)\nodejs;%PATH%"
        goto :check_node_again
    )
    
    if exist "%LOCALAPPDATA%\Programs\NodeJS\node.exe" (
        echo 🔍 Found Node.js in LocalAppData, adding to PATH...
        set "PATH=%LOCALAPPDATA%\Programs\NodeJS;%PATH%"
        goto :check_node_again
    )
    
    if exist "%APPDATA%\npm\node.exe" (
        echo � Found Node.js in AppData, adding to PATH...
        set "PATH=%APPDATA%\npm;%PATH%"
        goto :check_node_again
    )
    
    :check_node_again
    node --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo �📥 Installing Node.js automatically...
        
        if defined USE_CHOCO (
            echo [1/3] Trying Chocolatey to install Node.js...
            choco install nodejs -y --force
            if %errorlevel% equ 0 goto :node_install_success
            
            echo [1/3] Chocolatey nodejs failed, trying nodejs-lts...
            choco install nodejs-lts -y --force
            if %errorlevel% equ 0 goto :node_install_success
        )
        
        if defined USE_WINGET (
            echo [2/3] Trying winget to install Node.js...
            winget install OpenJS.NodeJS --accept-source-agreements --accept-package-agreements --force
            if %errorlevel% equ 0 goto :node_install_success
            
            echo [2/3] Trying alternative winget package...
            winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --force
            if %errorlevel% equ 0 goto :node_install_success
        )
        
        echo [3/3] Trying direct download and install...
        echo Downloading Node.js installer...
        powershell -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi' -OutFile 'nodejs-installer.msi'"
        if exist "nodejs-installer.msi" (
            echo Installing Node.js silently...
            msiexec /i nodejs-installer.msi /quiet /norestart
            timeout /t 30 /nobreak >nul
            del nodejs-installer.msi
            goto :node_install_success
        )
        
        goto :manual_node
        
        :node_install_success
        echo ✅ Node.js installation completed! Refreshing environment...
        call refreshenv >nul 2>&1
        timeout /t 10 /nobreak >nul
        
        REM Re-check with updated PATH
        node --version >nul 2>&1
        if %errorlevel% neq 0 (
            echo ⚠️ Node.js installed but not accessible yet
            echo 🔄 Please RESTART your computer and run this script again
            echo 💡 Or manually add Node.js to your PATH environment variable
            pause
            exit /b 1
        )
    )
    
    goto :check_node_success
    
    :manual_node
    echo ❌ All automatic installation methods failed
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
    echo ❌ npm command not found, trying to locate and fix...
    
    REM Try to find npm in Node.js installation directory
    for /f "delims=" %%i in ('where node 2^>nul') do (
        set "NODE_DIR=%%~dpi"
        if exist "!NODE_DIR!npm.cmd" (
            echo 🔍 Found npm.cmd in Node.js directory
            set "PATH=!NODE_DIR!;%PATH%"
            goto :check_npm_again
        )
        if exist "!NODE_DIR!npm" (
            echo 🔍 Found npm in Node.js directory
            set "PATH=!NODE_DIR!;%PATH%"
            goto :check_npm_again
        )
    )
    
    REM Check common npm locations
    if exist "C:\Program Files\nodejs\npm.cmd" (
        echo 🔍 Found npm in Program Files nodejs directory
        set "PATH=C:\Program Files\nodejs;%PATH%"
        goto :check_npm_again
    )
    
    if exist "%APPDATA%\npm\npm.cmd" (
        echo 🔍 Found npm in AppData directory
        set "PATH=%APPDATA%\npm;%PATH%"
        goto :check_npm_again
    )
    
    :check_npm_again
    npm --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo ❌ npm still not accessible
        echo 💡 Trying to reinstall npm using Node.js...
        
        REM Try to install npm using Node.js
        node -e "console.log('Node.js is working')" >nul 2>&1
        if %errorlevel% equ 0 (
            echo Installing npm via Node.js package manager...
            powershell -Command "& {npm install -g npm@latest}" 2>nul
            timeout /t 5 /nobreak >nul
            npm --version >nul 2>&1
            if %errorlevel% equ 0 goto :npm_success
        )
        
        echo ❌ Unable to fix npm automatically
        echo 💡 Please reinstall Node.js to include npm
        echo 💡 Or run: npm install -g npm@latest manually
        pause
        exit /b 1
    )
    
    :npm_success
    echo ✅ npm is now accessible
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
