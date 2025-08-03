@echo off

echo ================================================
echo [MANUAL NPM] Frontend Setup - Manual Approach
echo ================================================

echo Current working directory: %CD%
echo Target directory: %~dp0frontend

cd /d "%~dp0frontend"

echo After cd: %CD%

if not exist package.json (
    echo ERROR: package.json not found in %CD%
    echo Please run this script from the project root folder
    echo.
    echo Press any key to exit...
    pause
    exit /b 1
)

echo SUCCESS: package.json found

echo.
echo Please run these commands manually in a separate command prompt:
echo.
echo 1. cd /d "%CD%"
echo 2. npm install
echo.
echo After npm install completes successfully, come back and run:
echo    step3_test_all.bat
echo.
echo Or if you want to try automatic install again, close this window
echo and run the command manually:
echo.
echo    cd frontend
echo    npm install
echo.

echo Press any key when you understand these instructions...
pause

echo.
echo Do you want to try automatic npm install one more time? (Y/N)
set /p retry="Enter Y to retry, N to exit: "

if /i "%retry%"=="Y" (
    echo.
    echo Attempting npm install...
    echo If this force closes, follow the manual instructions above.
    echo.
    timeout /t 3
    
    call npm install
    
    echo.
    echo npm install completed with exit code: %errorlevel%
    
    if exist node_modules (
        echo SUCCESS: node_modules folder exists
        echo Frontend setup complete!
    ) else (
        echo WARNING: node_modules folder not found
        echo Try the manual approach above
    )
) else (
    echo.
    echo Manual setup recommended:
    echo 1. Open new command prompt
    echo 2. cd /d "%CD%"
    echo 3. npm install
    echo 4. Run step3_test_all.bat when done
)

echo.
echo Press any key to exit...
pause
