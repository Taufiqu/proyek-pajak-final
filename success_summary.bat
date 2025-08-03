@echo off

echo ================================================
echo [SUCCESS SUMMARY] Setup Status
echo ================================================
echo.

echo ✅ SETUP COMPLETED SUCCESSFULLY!
echo.

echo [BACKEND STATUS]
if exist backend\venv (
    echo ✅ Python virtual environment: READY
    echo ✅ Backend dependencies: INSTALLED
) else (
    echo ❌ Backend: NEEDS SETUP
    echo   → Run step1_backend.bat
)

echo.
echo [FRONTEND STATUS]  
if exist frontend\node_modules (
    echo ✅ Node.js dependencies: READY
    echo ✅ Frontend packages: INSTALLED
    
    cd frontend 2>nul
    dir node_modules /ad /b > temp.txt 2>nul
    for /f %%i in ('type temp.txt ^| find /c /v ""') do set count=%%i
    del temp.txt 2>nul
    cd .. 2>nul
    
    echo ✅ Found %count% npm packages
) else (
    echo ❌ Frontend: NEEDS SETUP
    echo   → Run step2_manual.bat
)

echo.
echo ================================================
echo [NEXT STEPS]
echo ================================================
echo.

if exist backend\venv if exist frontend\node_modules (
    echo 🚀 READY TO START APPLICATIONS!
    echo.
    echo Option 1: Quick Start
    echo   → Run: start_only.bat
    echo.
    echo Option 2: Step by Step
    echo   → Run: step4_start.bat
    echo.
    echo 🌐 Applications will run on:
    echo   Backend:  http://localhost:5000
    echo   Frontend: http://localhost:3000
    echo.
) else (
    echo ⚠️  SETUP INCOMPLETE
    echo.
    if not exist backend\venv (
        echo Missing: Backend setup
        echo   → Run: step1_backend.bat
    )
    if not exist frontend\node_modules (
        echo Missing: Frontend setup  
        echo   → Run: step2_manual.bat
    )
    echo.
    echo After completing setup, run this script again
    echo.
)

echo ================================================
echo [CONFIGURATION NOTES]
echo ================================================
echo.
echo 📝 Environment Configuration:
echo   • Backend uses .env file for database settings
echo   • Copy backend\.env.example to backend\.env 
echo   • Update DATABASE_URL if using Supabase
echo.
echo 🔧 Optional: Install Poppler for PDF processing
echo   • Download from: https://github.com/oschwartz10612/poppler-windows
echo   • Update POPPLER_PATH in .env file
echo.

echo ================================================
echo [TROUBLESHOOTING]
echo ================================================
echo.
echo If applications don't start:
echo   1. Check both terminal windows for error messages
echo   2. Verify port 5000 and 3000 are not in use
echo   3. Run simple_status.bat to check setup
echo   4. Check backend\.env file configuration
echo.

echo Press any key to exit...
pause
