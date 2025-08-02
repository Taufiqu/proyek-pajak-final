@echo off
echo =================================
echo 🚀 Proyek Pajak - Local Development
echo =================================
echo.

echo 📍 Starting Backend (Port 5000 - Flask Default)...
start "Backend Server" cmd /k "cd /d %~dp0backend && call venv\Scripts\activate.bat && python app.py"

echo.
echo ⏳ Waiting 20 seconds for backend to initialize (Poppler, Database, etc.)...
timeout /t 20 /nobreak > nul

echo.
echo 📍 Starting Frontend (Port 3000 - React Default)...
start "Frontend Server" cmd /k "cd /d %~dp0frontend && npm start"

echo.
echo ✅ Both services are starting!
echo.
echo 📊 Access Points:
echo   Backend API: http://localhost:5000
echo   Frontend:    http://localhost:3000
echo.
echo Press any key to exit...
pause > nul
