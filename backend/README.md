# FruitLens AI Backend Service

REST API Backend berbasis **FastAPI** untuk inferensi klasifikasi kematangan buah (khususnya Pisang 3-kelas: *Mentah*, *Matang*, *Busuk*) menggunakan arsitektur hybrid **MobileNetV3Small (576 fitur)** + **HSV (30 fitur)** -> **PCA** + **SVM**.

---

## 1. Prasyarat Sistem

- Python 3.10 atau 3.11
- Virtual Environment (`venv` atau `conda`)
- Model terbaru `baca/svm_pisang_3kelasNew.pkl` (otomatis dimuat sebagai prioritas utama)

---

## 2. Cara Menjalankan Server (Lokal)

### Langkah 1: Buka Terminal di folder backend
```bash
cd backend
```

### Langkah 2: Buat & Aktifkan Virtual Environment
```bash
# Windows
python -m venv venv
.\venv\Scripts\activate

# Linux / macOS
python3 -m venv venv
source venv/bin/activate
```

### Langkah 3: Install Dependencies
```bash
pip install -r requirements.txt
```

### Langkah 4: Jalankan Server FastAPI
```bash
# Untuk testing lokal (localhost):
uvicorn main:app --reload --port 8000

# Untuk demo ke HP fisik / Emulator (agar bisa diakses dari jaringan Wi-Fi):
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

## 3. Pengujian Endpoint

### A. Health Check via Browser / curl
Buka browser dan akses:
`http://localhost:8000/`

Respons:
```json
{
  "status": "Server Aktif",
  "service": "FruitLens AI Backend",
  "model_file": "svm_pisang_3kelasNew.pkl",
  "split_ratio": "80% Train : 20% Test",
  "architecture": "MobileNetV3 (576 -> PCA 100) + Masked HSV (30) -> SVM (130 Fitur Input)",
  "hsv_weight": 2.5,
  "classes": ["ripe", "rotten", "unripe"]
}
```

### B. Dokumentasi Interaktif (Swagger UI)
Buka di browser:
`http://localhost:8000/docs`

Anda dapat mencoba langsung unggah foto pisang melalui fitur **"Try it out"** pada endpoint `POST /predict`.

### C. Pengujian via curl
```bash
curl -X POST "http://localhost:8000/predict" \
     -H "accept: application/json" \
     -H "Content-Type: multipart/form-data" \
     -F "file=@../baca/foto_uji/01_hijau_terpal_biru_2252_busuk.jpg"
```

---

## 4. Menghubungkan ke Aplikasi Flutter

1. Jalankan server FastAPI dengan `--host 0.0.0.0 --port 8000`.
2. Cari tahu IP lokal laptop Anda (di Windows jalankan `ipconfig`, cari *IPv4 Address*, misal: `192.168.1.15`).
3. Pastikan HP dan Laptop terhubung ke Wi-Fi / Hotspot yang sama.
4. Di aplikasi FruitLens:
   - Masuk ke tab **Scan** atau **Profil**.
   - Buka menu **Pengaturan IP Server**.
   - Masukkan alamat IP: `http://192.168.1.15:8000` (atau `http://10.0.2.2:8000` jika memakai Android Emulator).
   - Klik **Tes Koneksi**. Jika muncul badge hijau **Online**, aplikasi siap memindai!

