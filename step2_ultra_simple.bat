@echo off

echo ================================================
echo [ULTRA SIMPLE] Frontend npm install only
echo ================================================

cd /d "%~dp0frontend"

echo Current directory: %CD%

if not exist package.json (
    echo ERROR: package.json not found
    pause
    exit /b 1
)

echo Starting npm install...
npm install

echo npm install finished
echo Check if node_modules folder exists:

if exist node_modules (
    echo SUCCESS: node_modules folder created
) else (
    echo ERROR: node_modules folder not created
)

echo.
echo Done. Press any key to exit...
pause
