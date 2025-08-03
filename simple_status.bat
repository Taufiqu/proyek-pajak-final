@echo off

echo ================================================
echo [STATUS CHECK] Simple Project Status
echo ================================================

echo Checking project components...
echo.

echo [BACKEND CHECK]
if exist backend\venv (
    echo ✓ Backend virtual environment: EXISTS
) else (
    echo ✗ Backend virtual environment: MISSING
    echo   → Run step1_backend.bat
)

echo.
echo [FRONTEND CHECK] 
if exist frontend\node_modules (
    echo ✓ Frontend node_modules: EXISTS
    
    cd frontend
    dir node_modules /ad /b > temp.txt 2>nul
    for /f %%i in ('type temp.txt ^| find /c /v ""') do set count=%%i
    del temp.txt 2>nul
    cd ..
    
    echo   → Found %count% packages
) else (
    echo ✗ Frontend node_modules: MISSING
    echo   → Run manual npm install in frontend folder
)

echo.
echo [FILES CHECK]
if exist frontend\package.json (
    echo ✓ Frontend package.json: EXISTS
) else (
    echo ✗ Frontend package.json: MISSING
)

if exist backend\requirements.txt (
    echo ✓ Backend requirements.txt: EXISTS  
) else (
    echo ✗ Backend requirements.txt: MISSING
)

echo.
echo [MANUAL FRONTEND SETUP]
echo If frontend setup keeps force closing, do this manually:
echo.
echo 1. Open Command Prompt
echo 2. cd /d "%~dp0frontend"
echo 3. npm install
echo 4. Wait for it to complete
echo 5. Run this status check again
echo.

echo Press any key to exit...
pause
