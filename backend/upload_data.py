import firebase_admin
from firebase_admin import credentials, firestore
import json
import os

# --- KONFIGURASI ---
# Pastikan file kunci ada di sebelah file ini
if not os.path.exists("serviceAccountKey.json"):
    print("❌ ERROR: File 'serviceAccountKey.json' ga ketemu!")
    print("   Pastikan file kunci dari Grace ada di folder ini.")
    exit()

# Login ke Firebase
cred = credentials.Certificate("serviceAccountKey.json")
try:
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("✅ Berhasil Login ke Firebase RangerViz!")
except ValueError:
    # Kalau app sudah jalan, skip inisialisasi
    db = firestore.client()

# --- FUNGSI UPLOAD ---
def start_upload():
    # 1. UPLOAD DASHBOARD (Data Grafik)
    if os.path.exists('summary.json'):
        try:
            with open('summary.json', 'r') as f:
                data = json.load(f)
                # Simpan ke collection 'dashboard_stats' dokumen 'summary'
                db.collection('dashboard_stats').document('summary').set(data)
                print("🚀 Data Dashboard (summary.json) TERKIRIM!")
        except Exception as e:
            print(f"❌ Gagal upload dashboard: {e}")
    else:
        print("⚠️ File 'summary.json' belum ada. (Bikin dummy dulu kalau mau tes)")

    # 2. UPLOAD PRODUK (Data Barang)
    if os.path.exists('products.json'):
        try:
            with open('products.json', 'r') as f:
                products = json.load(f)
                batch = db.batch()
                count = 0
                total = 0
                
                print(f"📦 Sedang memproses {len(products)} produk...")
                for item in products:
                    # Bikin ID otomatis
                    doc_ref = db.collection('products').document() 
                    batch.set(doc_ref, item)
                    count += 1
                    total += 1
                    
                    # Firebase cuma bisa upload 400-500 data sekali tembak
                    if count == 400: 
                        batch.commit()
                        batch = db.batch() # Reset batch
                        count = 0
                        print(f"   ... {total} data terupload ...")
                
                # Upload sisa data terakhir
                if count > 0:
                    batch.commit()
                print("🚀 SUKSES! Semua Data Produk TERKIRIM!")
        except Exception as e:
             print(f"❌ Gagal upload produk: {e}")
    else:
        print("⚠️ File 'products.json' belum ada. (Bikin dummy dulu kalau mau tes)")

if __name__ == "__main__":
    print("--- ALAT UPLOAD DATA RANGERVIZ ---")
    start_upload()
    # input("\nTekan Enter untuk keluar...")