================================================
PAJAK TOOLS - PANDUAN INSTALASI MANUAL
================================================

Aplikasi web untuk pemrosesan dokumen pajak dengan Flask (backend) dan React (frontend).

================================================
PERSYARATAN SISTEM
================================================

- Windows 10/11
- Akses internet untuk download dependencies
- Minimal 2GB ruang kosong hard drive

================================================
STEP 1: INSTALL PYTHON
================================================

1. Download Python dari: https://www.python.org/downloads/
   - Pilih versi Python 3.13 (terbaru)
   - Download installer untuk Windows

2. Install Python:
   - Jalankan installer yang sudah didownload
   - PENTING: Centang "Add Python to PATH" 
   - Pilih "Install Now"
   - Tunggu sampai selesai

3. Verifikasi instalasi:
   - Buka Command Prompt (cmd)
   - Ketik: python --version
   - Harus muncul versi Python yang terinstall

================================================
STEP 2: INSTALL NODE.JS
================================================

1. Download Node.js dari: https://nodejs.org/
   - Pilih versi LTS (Long Term Support)
   - Download installer untuk Windows

2. Install Node.js:
   - Jalankan installer yang sudah didownload
   - Pilih "Next" untuk semua opsi default
   - Tunggu sampai selesai

3. Verifikasi instalasi:
   - Buka Command Prompt (cmd)
   - Ketik: node --version
   - Ketik: npm --version
   - Kedua command harus menampilkan versi

================================================
STEP 3: SETUP BACKEND (PYTHON/FLASK)
================================================

1. Buka Command Prompt dan navigasi ke folder project:
   cd /d "path\ke\proyek-pajak-final"

2. Masuk ke folder backend:
   cd backend

3. Buat virtual environment:
   python -m venv venv

4. Aktifkan virtual environment:
   venv\Scripts\activate

   (Prompt akan berubah dengan prefix "(venv)")

5. Upgrade pip:
   python -m pip install --upgrade pip

6. Install dependencies backend:
   pip install Flask Flask-Cors Flask-SQLAlchemy Flask-Migrate SQLAlchemy python-dotenv

7. Install dependencies tambahan:
   pip install Pillow Flask-RESTful openpyxl thefuzz pandas psycopg2-binary pyspellchecker textdistance

8. Install semua requirements (optional, beberapa mungkin gagal):
   pip install -r requirements.txt

9. Copy file environment:
   copy .env.example .env

10. Edit file .env sesuai kebutuhan:
    - Buka .env dengan text editor
    - Update DATABASE_URL jika menggunakan database
    - Update POPPLER_PATH jika perlu PDF processing

================================================
STEP 4: SETUP FRONTEND (NODE.JS/REACT)
================================================

1. Buka Command Prompt baru dan navigasi ke folder project:
   cd /d "path\ke\proyek-pajak-final"

2. Masuk ke folder frontend:
   cd frontend

3. Install dependencies frontend:
   npm install

   (Proses ini akan memakan waktu beberapa menit)

4. Tunggu sampai muncul pesan selesai tanpa error fatal

================================================
STEP 5: MENJALANKAN APLIKASI
================================================

CARA 1: Menggunakan script otomatis
------------------------
Double-click file: start_only.bat

CARA 2: Manual (jika script tidak bekerja)
------------------------

A. Start Backend:
   1. Buka Command Prompt
   2. cd /d "path\ke\proyek-pajak-final\backend"
   3. venv\Scripts\activate
   4. python app.py

B. Start Frontend (di Command Prompt terpisah):
   1. Buka Command Prompt baru
   2. cd /d "path\ke\proyek-pajak-final\frontend"
   3. npm start

================================================
AKSES APLIKASI
================================================

Setelah kedua service berjalan:
- Backend API: http://localhost:5000
- Frontend Web: http://localhost:3000

Browser akan otomatis terbuka ke frontend.

================================================
TROUBLESHOOTING
================================================

MASALAH: Python command not found
SOLUSI: 
- Reinstall Python dengan centang "Add to PATH"
- Restart komputer setelah install

MASALAH: npm command not found  
SOLUSI:
- Reinstall Node.js
- Restart komputer setelah install

MASALAH: pip install gagal dengan error "Microsoft Visual C++"
SOLUSI:
- Install Microsoft Visual C++ Build Tools
- Download dari: https://visualstudio.microsoft.com/visual-cpp-build-tools/

MASALAH: Backend error "ModuleNotFoundError"
SOLUSI:
- Pastikan virtual environment aktif (ada prefix "(venv)")
- Install ulang dependencies: pip install -r requirements.txt

MASALAH: Frontend error saat npm install
SOLUSI:
- Hapus folder node_modules: rmdir /s node_modules
- Hapus package-lock.json: del package-lock.json  
- Install ulang: npm install

MASALAH: Port already in use
SOLUSI:
- Tutup aplikasi lain yang menggunakan port 3000 atau 5000
- Atau restart komputer

MASALAH: Database connection error
SOLUSI:
- Edit file backend\.env
- Update DATABASE_URL dengan kredensial database yang benar
- Atau comment DATABASE_URL untuk mode tanpa database

================================================
FITUR OPSIONAL
================================================

PDF PROCESSING (Poppler):
1. Download Poppler untuk Windows:
   https://github.com/oschwartz10612/poppler-windows/releases
   
2. Extract ke folder seperti: C:\poppler\

3. Update POPPLER_PATH di file backend\.env:
   POPPLER_PATH="C:\\poppler\\poppler-24.08.0\\Library\\bin"

DATABASE (Supabase):
1. Buat akun di: https://supabase.com
2. Buat project baru
3. Copy database URL dari Supabase dashboard
4. Update DATABASE_URL di file backend\.env

================================================
STRUKTUR PROJECT
================================================

proyek-pajak-final/
├── backend/               # Flask API server
│   ├── venv/             # Python virtual environment  
│   ├── app.py            # Main Flask application
│   ├── requirements.txt  # Python dependencies
│   └── .env              # Environment configuration
├── frontend/             # React web application
│   ├── node_modules/     # NPM dependencies
│   ├── package.json      # NPM configuration
│   └── src/              # React source code
└── start_only.bat        # Script untuk start aplikasi

================================================
PERINTAH BERGUNA
================================================

Untuk Backend:
- Aktifkan venv: venv\Scripts\activate
- Install package: pip install nama_package
- Lihat packages: pip list
- Jalankan app: python app.py

Untuk Frontend:  
- Install package: npm install nama_package
- Lihat packages: npm list
- Jalankan dev server: npm start
- Build production: npm run build

================================================
INFORMASI TAMBAHAN
================================================

- Project ini menggunakan Flask untuk backend REST API
- Frontend menggunakan React untuk antarmuka web
- Database opsional menggunakan PostgreSQL (Supabase)
- Fitur OCR menggunakan Tesseract (opsional)
- Pemrosesan PDF menggunakan Poppler (opsional)

Untuk bantuan lebih lanjut, periksa:
- File README.md untuk dokumentasi teknis
- Folder docs/ untuk panduan advanced
- GitHub Issues untuk melaporkan bug

================================================