@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [TEST] Pajak Tools - Test Dependencies
echo ================================================
echo [INFO] Script untuk test apakah semua dependencies terinstall
echo.

cd /d "%~dp0backend"
if exist venv\Scripts\activate.bat (
    call venv\Scripts\activate.bat
    echo [SUCCESS] Virtual environment aktif
) else (
    echo [ERROR] Virtual environment tidak ditemukan!
    echo [ERROR] Jalankan emergency_setup.bat terlebih dahulu
    pause
    exit /b 1
)

echo.
echo [TEST] Testing critical imports...

echo [TEST 1/6] Testing PIL (Pillow)...
python -c "from PIL import Image; print('✓ PIL/Pillow OK')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] PIL/Pillow tidak tersedia
    set HAS_ERROR=1
) else (
    echo [PASS] PIL/Pillow working
)

echo [TEST 2/6] Testing Flask...
python -c "import flask; print('✓ Flask OK')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] Flask tidak tersedia
    set HAS_ERROR=1
) else (
    echo [PASS] Flask working
)

echo [TEST 3/6] Testing SQLAlchemy...
python -c "import sqlalchemy; print('✓ SQLAlchemy OK')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] SQLAlchemy tidak tersedia
    set HAS_ERROR=1
) else (
    echo [PASS] SQLAlchemy working
)

echo [TEST 4/6] Testing pandas...
python -c "import pandas; print('✓ pandas OK')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] pandas tidak tersedia
    set HAS_ERROR=1
) else (
    echo [PASS] pandas working
)

echo [TEST 5/6] Testing project imports...
python -c "from shared_utils.file_utils import allowed_file; print('✓ Project imports OK')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] Project imports error
    set HAS_ERROR=1
) else (
    echo [PASS] Project imports working
)

echo [TEST 6/6] Testing app startup...
python -c "import app; print('✓ App module OK')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] App module error
    set HAS_ERROR=1
) else (
    echo [PASS] App module working
)

echo.
if defined HAS_ERROR (
    echo ================================================
    echo [RESULT] ❌ BEBERAPA DEPENDENCIES MASIH ERROR
    echo ================================================
    echo [SOLUTION] Jalankan emergency_setup.bat untuk fix dependencies
    echo.
) else (
    echo ================================================
    echo [RESULT] ✅ SEMUA DEPENDENCIES OK!
    echo ================================================
    echo [INFO] Aplikasi siap dijalankan dengan start_only.bat
    echo.
)

pause
