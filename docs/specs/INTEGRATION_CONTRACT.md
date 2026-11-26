# INTEGRATION_CONTRACT.md — Kontrak Jalur A (Aplikasi) ↔ Jalur B (Viskom & AI)

> Dokumen ini mencatat kesepakatan kontrak integrasi antara aplikasi Flutter (**Jalur A**) dan model Visi Komputer & AI (**Jalur B**).
> Status: **DISETUJUI USER — Menggunakan Opsi A (Integrasi Hybrid MobileNetV3Small + SVM `.pkl` via Backend Python FastAPI)**.

---

## 1. Keputusan Arsitektur Model (ADR: Opsi A — Hybrid FastAPI)

Berdasarkan artefak model yang telah dilatih di Google Colab (`baca/svm_pisang_hybrid.pkl` dan `baca/model.md`), sistem deteksi menggunakan arsitektur **Hybrid Deep Learning + Machine Learning** yang dijalankan melalui **Local REST API Server (FastAPI)** di laptop:

1. **Alasan Pemilihan Opsi A (Client–Server via FastAPI)**:
   - Mempertahankan **100% akurasi dan probabilitas asli** dari model Scikit-Learn SVM (`svm_pisang_hybrid.pkl`) dan ekstraktor fitur Keras `MobileNetV3Small` tanpa distorsi konversi.
   - Mendukung ekstraksi probabilitas 4 kelas kematangan secara presisi (`predict_proba`) untuk divisualisasikan di UI **FruitLens**.
   - Memudahkan demonstrasi akademik pada mata kuliah AI (arsitektur *RESTful Microservice* + *Mobile Client*).
2. **Cakupan Buah & Kelas Kematangan**:
   - Fokus model aktif: **Buah Pisang (`banana`)**.
   - 4 Kelas Kematangan (`class_names` di dalam `.pkl`):
     - `unripe` → **Mentah**
     - `ripe` → **Matang**
     - `overripe` → **Terlalu Matang**
     - `rotten` → **Busuk**

---

## 2. Spesifikasi Teknis Model & Endpoint FastAPI

| Komponen | Spesifikasi |
|---|---|
| **Artefak Model** | `baca/svm_pisang_hybrid.pkl` (berisi dictionary `{'svm_model': ..., 'class_names': ['overripe', 'ripe', 'rotten', 'unripe']}`) |
| **Feature Extractor** | `tf.keras.applications.MobileNetV3Small(input_shape=(224, 224, 3), include_top=False, weights='imagenet', pooling='avg')` → menghasilkan vektor **576 fitur** |
| **Preprocessing** | Resize `224×224` RGB → `float32` → `tf.keras.applications.mobilenet_v3.preprocess_input` |
| **Server Host & Port** | `0.0.0.0:8000` (Emulator Android mengakses via `http://10.0.2.2:8000`, perangkat fisik via `http://<IP_LAPTOP>:8000`) |
| **Ambang Keyakinan** | `confidence < 0.60` (60%) → dikategorikan sebagai `ScanUncertain` ("Tidak Yakin") |

### Kontrak Endpoint HTTP

1. **Health Check (`GET /`)**
   - **Response 200 OK**:
     ```json
     {
       "status": "Server Aktif",
       "model": "Hybrid MobileNetV3Small + SVM",
       "classes": ["overripe", "ripe", "rotten", "unripe"]
     }
     ```

2. **Prediksi Gambar (`POST /predict`)**
   - **Request**: `multipart/form-data` dengan field `file` (berkas gambar JPEG/PNG).
   - **Response 200 OK (Sukses)**:
     ```json
     {
       "status": "success",
       "fruit_label": "banana",
       "prediction": "Matang (Ripe)",
       "raw_class": "ripe",
       "confidence": 94.52,
       "details": {
         "overripe": 2.10,
         "ripe": 94.52,
         "rotten": 0.48,
         "unripe": 2.90
       }
     }
     ```
   - **Response Error**:
     ```json
     {
       "status": "error",
       "message": "Deskripsi kesalahan"
     }
     ```

---

## 3. Antarmuka Dart di Aplikasi FruitLens

Kontrak `ScanOutcome` dan `ScanService` tetap menjaga *clean architecture* yang sudah ada, dengan penambahan opsional `classProbabilities` pada `ScanSuccess` untuk menampilkan grafik bar 4 kelas SVM:

```dart
sealed class ScanOutcome {
  const ScanOutcome();
}

final class ScanSuccess extends ScanOutcome {
  const ScanSuccess({
    required this.fruitLabel,
    required this.ripenessLabel,
    required this.fruitConfidence,
    required this.ripenessConfidence,
    this.classProbabilities,
  });

  final String fruitLabel;          // e.g. 'banana'
  final String ripenessLabel;       // 'unripe' | 'ripe' | 'overripe' | 'rotten'
  final double fruitConfidence;     // 0.0 - 1.0
  final double ripenessConfidence;  // 0.0 - 1.0 (dari confidence SVM / 100)
  /// Rincian probabilitas (0.0 - 1.0) untuk 4 kelas SVM:
  /// {'unripe': 0.029, 'ripe': 0.945, 'overripe': 0.021, 'rotten': 0.005}
  final Map<String, double>? classProbabilities;
}

final class ScanUncertain extends ScanOutcome {
  const ScanUncertain();
}

final class ScanFailure extends ScanOutcome {
  const ScanFailure(this.message);
  final String message;
}

abstract class ScanService {
  /// Mengirim gambar ke server FastAPI (atau fallback). Tidak boleh melempar exception
  /// yang tidak tertangani ke UI; kegagalan jaringan dikembalikan sebagai [ScanFailure].
  Future<ScanOutcome> scan(String imagePath);
}
```

---

## 4. Aturan Konfigurasi IP Server & Keamanan Jaringan

1. **Penyimpanan IP Dinamis (`SharedPreferences`)**:
   - Aplikasi menyediakan pengaturan **Alamat IP Server (`ip:port`)** yang bisa diubah langsung dari UI (Layar Scan / Layar Profil) tanpa *build* ulang APK.
   - Nilai bawaan (*default*): `10.0.2.2:8000` (otomatis terhubung ke `localhost:8000` laptop jika dijalankan di Emulator Android).
2. **Fitur Tes Koneksi Server (`GET /`)**:
   - Tombol **"Tes Koneksi"** di pengaturan server untuk mengecek apakah server FastAPI di laptop sudah aktif sebelum memindai.
3. **Izin Android (`AndroidManifest.xml`)**:
   - Wajib menyertakan `<uses-permission android:name="android.permission.INTERNET"/>`.
   - Wajib menyertakan `android:usesCleartextTraffic="true"` pada tag `<application>` agar Android mengizinkan koneksi `http://` ke IP lokal laptop.
4. **Mode Cadangan (Fallback Demo)**:
   - Pengguna dapat memilih mode sumber pemindaian di pengaturan server: **Server FastAPI (Utama)** atau **Simulasi Offline (Cadangan)** untuk antisipasi darurat bila jaringan Wi-Fi terganggu saat presentasi.

---

## 5. ChatService / Gemini (Jalur B)

- Bahasa Indonesia, singkat, ramah, hanya topik buah/nutrisi/penyimpanan/resep, tanpa diagnosis medis.
- API key dari `.env` (`GEMINI_API_KEY`), **tidak boleh di-commit**.
- Timeout dan error jaringan dilempar sebagai exception bertipe / hasil error agar UI menampilkan opsi coba lagi.


