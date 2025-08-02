# # File: backend/app.py

# ==============================================================================
# 1. Pustaka Standar Python
# ==============================================================================
import os
from datetime import datetime, date

# ==============================================================================
# 2. Pustaka Pihak Ketiga (Third-Party)
# ==============================================================================
from flask import Flask, request, jsonify, send_file, make_response, send_from_directory
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy

# ==============================================================================
# 3. Impor Lokal Aplikasi Anda
# ==============================================================================
from config import Config
from models import db
from bukti_setor.utils import allowed_file
from faktur.services import (
    process_invoice_file,
    save_invoice_data,
    generate_excel_export,
    get_history,
)
from faktur.services.delete import delete_faktur
from bukti_setor.services.delete import delete_bukti_setor

from bukti_setor.routes import bukti_setor_bp
from bukti_setor.routes import laporan_bp  # pastikan ini diimpor untuk digunakan

# ==============================================================================
# INISIALISASI FLASK APP
# ==============================================================================
app = Flask(__name__)
app.config.from_object(Config)

# CORS Configuration - simplified to avoid duplicates
CORS(app, 
     origins=["*"],  # Temporary untuk debug, nanti kita restrict lagi
     methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
     allow_headers=["Content-Type", "Authorization", "Accept"],
     supports_credentials=False)  # Set False untuk avoid credential issues

print("🧪 Loaded DB URL:", os.getenv("DATABASE_URL"))
# ==============================================================================
# INISIALISASI DATABASE

db.init_app(app)
app.register_blueprint(bukti_setor_bp)
app.register_blueprint(laporan_bp)
from flask_migrate import Migrate  # ⬅️ import ini di bagian atas
migrate = Migrate(app, db)        # ⬅️ ini setelah db.init_app(app)

# ==============================================================================
# ROUTES
# ==============================================================================

# ========== ENDPOINT: SERVE UPLOADS (untuk preview gambar) ==========
@app.route("/uploads/<path:filename>")
def serve_uploads(filename):
    """Serve static files dari folder uploads untuk preview gambar"""
    upload_folder = app.config.get('UPLOAD_FOLDER', 'uploads')
    return send_from_directory(upload_folder, filename)

@app.route("/api/process", methods=["POST"])
def process_file():
    return process_invoice_file(request, app.config)

@app.route("/api/save", methods=["POST"])
def save_data():
    if not request.is_json:
        return jsonify(error="Request harus berupa JSON."), 400

    data = request.get_json()

    try:
        if isinstance(data, list):
            saved_count = 0
            for item in data:
                save_invoice_data(item, db)
                saved_count += 1
            db.session.commit()
            return jsonify(message=f"{saved_count} faktur berhasil disimpan."), 201

        else:
            save_invoice_data(data, db)
            db.session.commit()
            return jsonify(message="Faktur berhasil disimpan."), 201

    except ValueError as ve:
        db.session.rollback()
        return jsonify(error=str(ve)), 400

    except Exception as e:
        db.session.rollback()
        print(f"[❌ ERROR /api/save] {e}")
        return jsonify(error=f"Terjadi kesalahan di server: {e}"), 500

# ========== ENDPOINT: SAVE FAKTUR ==========
@app.route("/api/save-faktur", methods=["POST"])
def save_faktur_data():
    """Save faktur data to database"""
    if not request.is_json:
        return jsonify(error="Request harus berupa JSON."), 400

    data = request.get_json()

    try:
        if isinstance(data, list):
            saved_count = 0
            for item in data:
                save_invoice_data(item, db)
                saved_count += 1
            db.session.commit()
            return jsonify({'success': True, 'message': f"{saved_count} faktur berhasil disimpan."}), 201
        else:
            save_invoice_data(data, db)
            db.session.commit()
            return jsonify({'success': True, 'message': "Faktur berhasil disimpan."}), 201

    except Exception as err:
        db.session.rollback()
        return jsonify({'success': False, 'error': str(err)}), 500

# ========== ENDPOINT: SAVE BUKTI SETOR ==========
@app.route("/api/save-bukti-setor", methods=["POST"])
def save_bukti_setor_data():
    """Save bukti setor data to database"""
    if not request.is_json:
        return jsonify(error="Request harus berupa JSON."), 400

    data = request.get_json()

    try:
        # Import BuktiSetor model
        from models import BuktiSetor
        
        if isinstance(data, list):
            saved_count = 0
            for item in data:
                # Parse tanggal jika dalam format string
                tanggal_val = item.get('tanggal')
                if isinstance(tanggal_val, str):
                    tanggal_val = datetime.strptime(tanggal_val, '%Y-%m-%d').date()
                
                bukti_setor = BuktiSetor(
                    tanggal=tanggal_val,
                    kode_setor=item.get('kode_setor'),
                    jumlah=item.get('jumlah')
                )
                db.session.add(bukti_setor)
                saved_count += 1
            db.session.commit()
            return jsonify({'success': True, 'message': f"{saved_count} bukti setor berhasil disimpan."}), 201
        else:
            # Parse tanggal jika dalam format string
            tanggal_val = data.get('tanggal')
            if isinstance(tanggal_val, str):
                tanggal_val = datetime.strptime(tanggal_val, '%Y-%m-%d').date()
            
            bukti_setor = BuktiSetor(
                tanggal=tanggal_val,
                kode_setor=data.get('kode_setor'),
                jumlah=data.get('jumlah')
            )
            db.session.add(bukti_setor)
            db.session.commit()
            return jsonify({'success': True, 'message': "Bukti setor berhasil disimpan."}), 201

    except Exception as err:
        db.session.rollback()
        return jsonify({'success': False, 'error': str(err)}), 500

@app.route("/api/export", methods=["GET"])
def export_excel():
    return generate_excel_export(db)

@app.route("/api/history", methods=["GET"])
def route_get_history():
    return get_history()

# ========== ENDPOINT: FAKTUR HISTORY ==========
@app.route("/api/faktur-history", methods=["GET"])
def get_faktur_history():
    """Get faktur history with pagination from both PpnMasukan and PpnKeluaran"""
    try:
        page = int(request.args.get('page', 1))
        per_page = int(request.args.get('per_page', 50))
        
        # Import both models
        from models import PpnMasukan, PpnKeluaran
        
        # Get data from both tables
        masukan_data = PpnMasukan.query.all()
        keluaran_data = PpnKeluaran.query.all()
        
        # Combine data with jenis field
        faktur_list = []
        
        # Add PPN Masukan data
        for faktur in masukan_data:
            faktur_list.append({
                'id': faktur.id,
                'jenis': 'masukan',  # Add jenis field
                'no_faktur': faktur.no_faktur,
                'tanggal': faktur.tanggal.strftime('%Y-%m-%d') if faktur.tanggal else '',
                'nama_lawan_transaksi': faktur.nama_lawan_transaksi,
                'npwp_lawan_transaksi': faktur.npwp_lawan_transaksi,
                'dpp': str(faktur.dpp),
                'ppn': str(faktur.ppn),
                'keterangan': faktur.keterangan,
                'created_at': faktur.created_at.strftime('%Y-%m-%d %H:%M:%S') if faktur.created_at else ''
            })
        
        # Add PPN Keluaran data
        for faktur in keluaran_data:
            faktur_list.append({
                'id': faktur.id,
                'jenis': 'keluaran',  # Add jenis field
                'no_faktur': faktur.no_faktur,
                'tanggal': faktur.tanggal.strftime('%Y-%m-%d') if faktur.tanggal else '',
                'nama_lawan_transaksi': faktur.nama_lawan_transaksi,
                'npwp_lawan_transaksi': faktur.npwp_lawan_transaksi,
                'dpp': str(faktur.dpp),
                'ppn': str(faktur.ppn),
                'keterangan': faktur.keterangan,
                'created_at': faktur.created_at.strftime('%Y-%m-%d %H:%M:%S') if faktur.created_at else ''
            })
        
        # Sort by created_at descending
        faktur_list.sort(key=lambda x: x['created_at'], reverse=True)
        
        # Manual pagination
        total = len(faktur_list)
        start = (page - 1) * per_page
        end = start + per_page
        paginated_data = faktur_list[start:end]
        
        return jsonify({
            'success': True,
            'data': paginated_data,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total': total,
                'pages': (total + per_page - 1) // per_page,  # Calculate total pages
                'has_next': end < total,
                'has_prev': page > 1
            }
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ========== ENDPOINT: BUKTI SETOR HISTORY ==========
@app.route("/api/bukti-setor-history", methods=["GET"])
def get_bukti_setor_history():
    """Get bukti setor history with pagination"""
    try:
        page = int(request.args.get('page', 1))
        per_page = int(request.args.get('per_page', 50))
        
        # Import model BuktiSetor
        from models import BuktiSetor
        
        # Query dengan pagination
        pagination = BuktiSetor.query.paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
        
        # Format response
        bukti_setor_list = []
        for bukti in pagination.items:
            bukti_setor_list.append({
                'id': bukti.id,
                'tanggal': bukti.tanggal.strftime('%Y-%m-%d') if bukti.tanggal else '',
                'kode_setor': bukti.kode_setor,
                'jumlah': bukti.jumlah,
                'created_at': bukti.created_at.strftime('%Y-%m-%d %H:%M:%S') if bukti.created_at else ''
            })
        
        return jsonify({
            'success': True,
            'data': bukti_setor_list,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total': pagination.total,
                'pages': pagination.pages,
                'has_next': pagination.has_next,
                'has_prev': pagination.has_prev
            }
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route("/api/delete/<string:jenis>/<int:id>", methods=["DELETE"])
def route_delete_faktur(jenis, id):
    return delete_faktur(jenis, id)

# ========== ENDPOINT: DELETE FAKTUR BY JENIS ==========
@app.route("/api/faktur/<string:jenis>/<int:id>", methods=["DELETE"])
def delete_faktur_by_jenis(jenis, id):
    """Delete faktur by jenis and ID"""
    try:
        from models import PpnMasukan, PpnKeluaran
        
        print(f"🗑️ Delete request: jenis={jenis}, id={id}")  # Debug log
        
        # Choose the right model based on jenis
        if jenis == "masukan":
            model = PpnMasukan
        elif jenis == "keluaran":
            model = PpnKeluaran
        else:
            print(f"❌ Invalid jenis: {jenis}")
            return jsonify({'success': False, 'error': 'Jenis faktur tidak valid'}), 400
        
        # Use SQLAlchemy 2.0+ syntax instead of deprecated query.get()
        faktur = db.session.get(model, id)
        if not faktur:
            print(f"❌ Faktur not found: jenis={jenis}, id={id}")
            return jsonify({'success': False, 'error': 'Faktur tidak ditemukan'}), 404
        
        print(f"✅ Found faktur: {faktur.no_faktur}")
        db.session.delete(faktur)
        db.session.commit()
        print(f"✅ Delete successful: jenis={jenis}, id={id}")
        return jsonify({'success': True, 'message': 'Faktur berhasil dihapus'}), 200
    except Exception as e:
        db.session.rollback()
        print(f"❌ Delete error: {str(e)}")  # Add logging
        return jsonify({'success': False, 'error': str(e)}), 500
        return jsonify({'success': False, 'error': str(e)}), 500

# ========== ENDPOINT: DELETE FAKTUR (Legacy) ==========
@app.route("/api/faktur/<int:id>", methods=["DELETE"])
def delete_faktur_endpoint(id):
    """Delete faktur by ID"""
    try:
        from models import PpnMasukan
        faktur = PpnMasukan.query.get(id)
        if not faktur:
            return jsonify({'success': False, 'error': 'Faktur tidak ditemukan'}), 404
        
        db.session.delete(faktur)
        db.session.commit()
        return jsonify({'success': True, 'message': 'Faktur berhasil dihapus'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route("/api/bukti_setor/delete/<int:id>", methods=["DELETE"])
def delete_bukti_setor_endpoint(id):
    return delete_bukti_setor(id)

# ========== ENDPOINT: DELETE BUKTI SETOR ==========
@app.route("/api/bukti-setor/<int:id>", methods=["DELETE"])
def delete_bukti_setor_by_id(id):
    """Delete bukti setor by ID"""
    try:
        from models import BuktiSetor
        bukti_setor = BuktiSetor.query.get(id)
        if not bukti_setor:
            return jsonify({'success': False, 'error': 'Bukti setor tidak ditemukan'}), 404
        
        db.session.delete(bukti_setor)
        db.session.commit()
        return jsonify({'success': True, 'message': 'Bukti setor berhasil dihapus'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route("/preview/<filename>")
def serve_preview(filename):
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    response = make_response(send_file(filepath, mimetype="image/jpeg"))
    response.headers['Cache-Control'] = 'no-cache'
    return response

# ==============================================================================
# MAIN ENTRY POINT
# ==============================================================================
if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    
    # Ambil port dari FLASK_PORT di .env, jika tidak ada gunakan PORT, default 5000 (Flask default)
    port = int(os.environ.get("FLASK_PORT", os.environ.get("PORT", 5000)))
    print(f"🚀 Starting server on port {port}")
    
    app.run(
        host="0.0.0.0",
        port=port,
        debug=True
    )
