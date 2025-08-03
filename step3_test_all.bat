@echo off
setlocal enabledelayedexpansion

echo ================================================
echo [STEP 3] Test All Dependencies
echo ================================================
echo [INFO] Script untuk test semua dependencies sudah install dengan benar
echo.

REM ========== TEST BACKEND ==========
echo ================================================
echo [TEST BACKEND] Testing Backend Dependencies
echo ================================================

cd /d "%~dp0backend"
if %errorlevel% neq 0 (
    echo [ERROR] Folder backend tidak ditemukan!
    pause
    exit /b 1
)

if exist venv\Scripts\activate.bat (
    call venv\Scripts\activate.bat
    echo [SUCCESS] Virtual environment aktif
) else (
    echo [ERROR] Virtual environment tidak ditemukan!
    echo [SOLUTION] Jalankan step1_backend.bat terlebih dahulu
    pause
    exit /b 1
)

echo [TEST] Testing critical imports...
set BACKEND_ERROR=0

echo [TEST 1/7] Testing PIL (Pillow)...
python -c "from PIL import Image; print('[PASS] PIL working')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] PIL tidak bisa diimport
    set BACKEND_ERROR=1
)

echo [TEST 2/7] Testing Flask...
python -c "import flask; print('[PASS] Flask working')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] Flask tidak bisa diimport
    set BACKEND_ERROR=1
)

echo [TEST 3/7] Testing SQLAlchemy...
python -c "import sqlalchemy; print('[PASS] SQLAlchemy working')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] SQLAlchemy tidak bisa diimport
    set BACKEND_ERROR=1
)

echo [TEST 4/7] Testing pandas...
python -c "import pandas; print('[PASS] pandas working')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] pandas tidak bisa diimport
    set BACKEND_ERROR=1
)

echo [TEST 5/7] Testing shared_utils...
python -c "from shared_utils.file_utils import allowed_file; print('[PASS] shared_utils working')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] shared_utils import error
    echo [DEBUG] Trying to diagnose shared_utils error...
    python -c "import sys; print('[DEBUG] Python path:'); [print(p) for p in sys.path]"
    echo [DEBUG] Checking shared_utils folder...
    if exist shared_utils (
        echo [DEBUG] shared_utils folder exists
        dir shared_utils
    ) else (
        echo [DEBUG] shared_utils folder MISSING!
    )
    set BACKEND_ERROR=1
)

echo [TEST 6/7] Testing bukti_setor utils...
python -c "from bukti_setor.utils import allowed_file; print('[PASS] bukti_setor utils working')" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] bukti_setor utils import error
    set BACKEND_ERROR=1
)

echo [TEST 7/7] Testing app module (without starting server)...
python -c "
import sys
import os
sys.path.insert(0, os.getcwd())
try:
    import app
    print('[PASS] app module can be imported')
except Exception as e:
    print(f'[FAIL] app module error: {e}')
    sys.exit(1)
" 2>nul
if !errorlevel! neq 0 (
    echo [FAIL] app module import error
    set BACKEND_ERROR=1
)

REM ========== TEST FRONTEND ==========
echo.
echo ================================================
echo [TEST FRONTEND] Testing Frontend Dependencies
echo ================================================

echo [INFO] Changing to frontend directory...
cd /d "%~dp0frontend"
if %errorlevel% neq 0 (
    echo [ERROR] Folder frontend tidak ditemukan!
    pause
    exit /b 1
)

echo [INFO] Current directory: %CD%
set FRONTEND_ERROR=0

echo [TEST 1/3] Checking node_modules...
if exist node_modules (
    echo [PASS] node_modules folder exists
    
    echo [INFO] Counting packages in node_modules...
    dir node_modules /ad /b >temp_count.txt 2>nul
    for /f %%i in ('type temp_count.txt 2^>nul ^| find /c /v ""') do set MODULE_COUNT=%%i
    del temp_count.txt 2>nul
    
    echo [INFO] Found !MODULE_COUNT! packages in node_modules
    
    if !MODULE_COUNT! gtr 10 (
        echo [PASS] node_modules has sufficient packages
    ) else (
        echo [WARNING] node_modules may be incomplete (!MODULE_COUNT! packages)
        set FRONTEND_ERROR=1
    )
) else (
    echo [FAIL] node_modules tidak ditemukan
    echo [SOLUTION] Jalankan step2_manual.bat untuk install frontend
    set FRONTEND_ERROR=1
)

echo [TEST 2/3] Checking package.json...
if exist package.json (
    echo [PASS] package.json exists
) else (
    echo [FAIL] package.json tidak ditemukan
    set FRONTEND_ERROR=1
)

echo [TEST 3/3] Testing npm packages...
if !FRONTEND_ERROR! equ 0 (
    echo [INFO] Testing npm list...
    npm list --depth=0 >nul 2>&1
    if !errorlevel! equ 0 (
        echo [PASS] npm packages installed correctly
    ) else (
        echo [WARNING] npm packages may have issues
        echo [INFO] This might still work for basic functionality
    )
) else (
    echo [SKIP] npm test skipped due to previous errors
)

REM ========== FINAL RESULT ==========
echo.
echo ================================================
echo [FINAL RESULT] Dependency Check Results
echo ================================================

if %BACKEND_ERROR% equ 0 (
    echo [✅] BACKEND: All dependencies OK
) else (
    echo [❌] BACKEND: Some dependencies missing
    echo [SOLUTION] Run step1_backend.bat to fix backend
)

if %FRONTEND_ERROR% equ 0 (
    echo [✅] FRONTEND: All dependencies OK
) else (
    echo [❌] FRONTEND: Some dependencies missing
    echo [SOLUTION] Run step2_frontend.bat to fix frontend
)

if %BACKEND_ERROR% equ 0 if %FRONTEND_ERROR% equ 0 (
    echo.
    echo ================================================
    echo [🎉] ALL SYSTEMS READY!
    echo ================================================
    echo [NEXT] Run start_only.bat untuk start aplikasi
    echo.
) else (
    echo.
    echo ================================================
    echo [⚠️] DEPENDENCIES INCOMPLETE
    echo ================================================
    echo [ACTION] Fix the failed components first
    echo.
)

pause
