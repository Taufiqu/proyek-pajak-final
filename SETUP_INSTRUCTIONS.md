# 🚀 Pajak Tools - Setup Instructions

## 📋 Prerequisites

Sebelum menjalankan aplikasi, pastikan sudah terinstall:

### ✅ Required Software
1. **Python 3.8+** 
   - Download: https://www.python.org/downloads/
   - ⚠️ **PENTING**: Centang "Add Python to PATH" saat instalasi

2. **Node.js 14+**
   - Download: https://nodejs.org/
   - Akan otomatis install npm

### ⚙️ Optional (untuk fitur OCR advanced)
- **Visual Studio Build Tools** (jika ingin install numpy/opencv dari source)
- **Tesseract OCR** (untuk fitur OCR text recognition)

## 🎯 Quick Start

### Method 1: Automatic Setup (Recommended)
```bash
# Clone repository
git clone https://github.com/Taufiqu/proyek-pajak-final.git
cd proyek-pajak-final

# Jalankan script otomatis
setup_and_start_localhost_FINAL.bat
```

### Method 2: Manual Setup

#### Backend Setup
```bash
cd backend

# Buat virtual environment
python -m venv venv

# Aktifkan virtual environment
# Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Jalankan backend
python app.py
```

#### Frontend Setup (Terminal baru)
```bash
cd frontend

# Install dependencies
npm install

# Jalankan frontend
npm start
```

## 🌐 Access Application

Setelah setup selesai:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000

## 🔧 Troubleshooting

### ❌ Error: "ModuleNotFoundError"
**Solusi**: Pastikan virtual environment aktif
```bash
cd backend
venv\Scripts\activate
pip install [nama-module]
```

### ❌ Error: "numpy compilation failed"
**Solusi**: Install pre-compiled version
```bash
pip install numpy --only-binary=all
```

### ❌ Error: "Node.js not found"
**Solusi**: 
1. Install Node.js dari https://nodejs.org/
2. Restart komputer
3. Jalankan script lagi

### ❌ Error: "Permission denied"
**Solusi**: Jalankan Command Prompt sebagai Administrator

## 📁 Project Structure

```
proyek-pajak-final/
├── backend/                 # Python Flask API
│   ├── venv/               # Virtual environment (auto-created)
│   ├── app.py              # Main Flask application
│   ├── requirements.txt    # Python dependencies
│   └── ...
├── frontend/               # React Application
│   ├── src/               # Source code
│   ├── package.json       # Node.js dependencies
│   └── ...
└── setup_and_start_localhost_FINAL.bat  # Auto setup script
```

## 🔒 Environment Variables

Buat file `.env` di folder `backend/` jika diperlukan:
```env
DATABASE_URL=your_database_url
FLASK_ENV=development
SECRET_KEY=your_secret_key
```

## 📱 Deployment Ready

Script ini sudah siap untuk:
- ✅ Development environment
- ✅ Fresh Windows installations  
- ✅ Devices tanpa VS Code
- ✅ Automatic dependency installation
- ✅ Error handling dan fallbacks

## 💡 Tips

1. **Virtual Environment**: Selalu gunakan venv untuk isolasi dependencies
2. **Clean Install**: Hapus folder `venv` dan `node_modules` jika ada masalah
3. **Updates**: Jalankan `pip install --upgrade pip` secara berkala
4. **Portabilitas**: Copy seluruh folder project ke device lain

## 🆘 Support

Jika masih ada masalah:
1. Check error message di terminal
2. Pastikan Python dan Node.js terinstall dengan benar
3. Restart komputer setelah install software baru
4. Jalankan script sebagai Administrator jika perlu

---
**📝 Note**: Virtual environment otomatis dibuat dan tidak perlu VS Code untuk berjalan!
