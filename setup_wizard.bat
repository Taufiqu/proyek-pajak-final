@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [SETUP WIZARD] Pajak Tools - Setup Terbagi
echo ================================================
echo [INFO] Setup dibagi menjadi beberapa step untuk mudah debug
echo.

echo ================================================
echo [WORKFLOW] Cara Setup:
echo ================================================
echo.
echo [STEP 1] step1_backend.bat
echo   - Install Python dependencies
echo   - Setup virtual environment  
echo   - Install Flask, Pillow, dll
echo   - Test backend imports
echo.
echo [STEP 2] step2_frontend.bat
echo   - Install Node.js dependencies
echo   - Setup npm packages
echo   - Test frontend setup
echo.
echo [STEP 3] step3_test_all.bat
echo   - Test semua dependencies
echo   - Verify backend imports
echo   - Verify frontend packages
echo   - Check project imports
echo.
echo [STEP 4] step4_start.bat
echo   - Start Flask backend
echo   - Start React frontend
echo   - Launch applications
echo.

echo ================================================
echo [CURRENT STATUS] Checking current setup...
echo ================================================

REM Check backend
if exist backend\venv (
    echo [✅] Backend: Virtual environment exists
) else (
    echo [❌] Backend: Virtual environment missing
    echo     → Run step1_backend.bat
)

REM Check frontend  
if exist frontend\node_modules (
    echo [✅] Frontend: Node modules exist
) else (
    echo [❌] Frontend: Node modules missing
    echo     → Run step2_frontend.bat
)

echo.
echo ================================================
echo [QUICK START] Recommended Actions:
echo ================================================

if not exist backend\venv (
    echo [1] Jalankan step1_backend.bat untuk setup backend
    echo [2] Jalankan step2_frontend.bat untuk setup frontend  
    echo [3] Jalankan step3_test_all.bat untuk test semua
    echo [4] Jalankan step4_start.bat untuk start aplikasi
) else if not exist frontend\node_modules (
    echo [1] Jalankan step2_frontend.bat untuk setup frontend
    echo [2] Jalankan step3_test_all.bat untuk test semua
    echo [3] Jalankan step4_start.bat untuk start aplikasi
) else (
    echo [1] Jalankan step3_test_all.bat untuk test dependencies
    echo [2] Jika test OK, jalankan step4_start.bat untuk start
    echo [3] Jika test gagal, jalankan step yang bermasalah
)

echo.
echo ================================================
echo [TROUBLESHOOTING] Jika ada masalah:
echo ================================================
echo.
echo [BACKEND ERROR]
echo   - Jalankan step1_backend.bat lagi
echo   - Check error di terminal output
echo   - Install Visual C++ Build Tools jika Pillow gagal
echo.
echo [FRONTEND ERROR] 
echo   - Jalankan step2_frontend.bat lagi
echo   - Hapus node_modules dan package-lock.json
echo   - Check koneksi internet
echo.
echo [IMPORT ERROR]
echo   - Jalankan step3_test_all.bat untuk lihat detail error
echo   - Check missing files di project
echo.

echo.
echo [INFO] Pilih step yang ingin dijalankan:
echo   [1] Step 1 - Backend Setup
echo   [2] Step 2 - Frontend Setup  
echo   [3] Step 3 - Test All
echo   [4] Step 4 - Start Apps
echo   [5] Exit
echo.

set /p choice="Masukkan pilihan (1-5): "

if "%choice%"=="1" (
    call step1_backend.bat
) else if "%choice%"=="2" (
    call step2_frontend.bat
) else if "%choice%"=="3" (
    call step3_test_all.bat
) else if "%choice%"=="4" (
    call step4_start.bat
) else if "%choice%"=="5" (
    echo [INFO] Keluar dari setup wizard
) else (
    echo [ERROR] Pilihan tidak valid
    pause
)

echo.
echo [DONE] Setup wizard selesai
pause
