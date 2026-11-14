# Laporan Analisis Anomali Uji Model 3 Kelas (`svm_pisang_3kelas(96%).pkl`)

Dokumen ini merangkum temuan teknis atas **Anomali 1 (Klasifikasi AI)** dan **Anomali 2 (Akurasi Pindai 98% di Riwayat)** dari 8 skenario uji citra nyata di emulator Android pada 11 November 2026 (`22:52`–`22:54 WIB`).

---

## Ringkasan 8 Sampel Uji

| No | Waktu Uji | Kondisi Visual Foto | Prediksi di App | Akurasi Terlihat | Evaluasi |
|---:|---|---|---|---|---|
| 1 | `22:52 WIB` | Pisang hijau 1 sisir (latar terpal biru) | `Busuk` | `98%` | **Keliru** (seharusnya `Mentah`) |
| 2 | `22:53 WIB` | Pisang hijau 1 sisir (latar putih polos) | `Matang` | `98%` | **Keliru** (seharusnya `Mentah`) |
| 3 | `22:53 WIB` | Pisang hijau 1 sisir (latar kayu) | `Busuk` | `98%` | **Keliru** (seharusnya `Mentah`) |
| 4 | `22:53 WIB` | Pisang kuning mulus (latar putih polos) | `Matang` | `98%` | **Benar** |
| 5 | `22:54 WIB` | Pisang hitam/cokelat tua (latar putih polos) | `Busuk` | `98%` | **Benar** |
| 6 | `22:54 WIB` | Pisang kuning berbintik cokelat (latar putih) | `Busuk` | `98%` | Wajar di skema 3 kelas (tanpa `overripe`) |
| 7 | `22:54 WIB` | Pisang cokelat/gelap (latar lantai batu) | `Busuk` | `98%` | **Benar** |
| 8 | `22:54 WIB` | Pisang hijau 1 sisir (latar terpal biru, foto ulang #1) | `Busuk` | `98%` | **Keliru** (seharusnya `Mentah`) |

---

## Anomali 1: Model AI Gagal Mengenali Pisang Hijau (`Mentah` / `unripe`)

### Gejala
Dari **4 kali pengujian foto pisang hijau mentah** (sampel #1, #2, #3, #8), **tidak ada satu pun** yang terdeteksi sebagai `Mentah` (`unripe`):
- Foto pisang hijau berlatar non-putih (terpal biru dan meja kayu) seluruhnya terklasifikasi **`Busuk`** (`rotten`).
- Foto pisang hijau berlatar putih polos (#2) justru terklasifikasi **`Matang`** (`ripe`).

### Akar Masalah Teknis (Terverifikasi)

#### 1. Ketimpangan Data & Support Vectors pada `.pkl`
Hasil inspeksi langsung terhadap bundel `baca/svm_pisang_3kelas(96%).pkl` (`Pipeline`: `standardscaler -> pca (100 komponen) -> svc`):
- `class_names`: `['ripe', 'rotten', 'unripe']`
- Parameter `SVC`: `kernel='rbf'`, `C=0.03`, `gamma='scale'`
- Jumlah support vector per kelas (`n_support_`):
  - **`ripe` (Matang)**: `1.835` support vectors
  - **`rotten` (Busuk)**: `1.947` support vectors
  - **`unripe` (Mentah)**: **`670` support vectors** *(hanya sekitar 1/3 dari kelas `rotten` dan `ripe`)*

**Dampak:** Kelas `unripe` memiliki representasi paling sedikit dibanding dua kelas lainnya. Dengan nilai regularisasi `C=0.03` (margin sangat lunak), area keputusan (*decision boundary*) kelas `unripe` menyempit dan mudah kalah oleh `rotten` atau `ripe` ketika fitur gambar sedikit menyimpang dari data latih. Pola ketimpangan serupa juga pernah ditemukan pada evaluasi model 4 kelas sebelumnya di `baca/laporan_evaluasi_model.md`.

#### 2. Background Bias pada Ekstraksi Fitur Global (Tanpa Segmentasi)
Di `backend/main.py` (sudah identik dengan pipeline referensi di `baca/modul penggunaan model.md`):
- Gambar di-resize menjadi `224x224` lalu diekstrak menjadi `576` fitur `MobileNetV3Small` (`pooling='avg'`) + `30` fitur histogram/momen HSV (`12` bin Hue, `6` bin Saturation, `6` bin Value, `mean`, `std`).
- Fitur tersebut diambil dari **keseluruhan frame gambar**, bukan hanya area buah pisangnya.
- Akibatnya, latar terpal biru atau kayu kecokelatan ikut mendominasi histogram HSV dan aktivasi global `MobileNetV3Small`, mendorong fitur ke wilayah `rotten`. Bahkan pada latar putih polos, bobot kelas `ripe` tetap menarik pisang hijau ke `Matang`.

#### 3. Bukan Bug Preprocessing Backend
Pemeriksaan terhadap `backend/main.py` memastikan preprocessing sudah sesuai dengan panduan model:
- Koreksi orientasi EXIF (`ImageOps.exif_transpose`) dan konversi ke `RGB`.
- Resize `BILINEAR` ke `224x224`.
- Ekstraksi `cv2.cvtColor(img_uint8, cv2.COLOR_RGB2HSV)` dan `tf.keras.applications.mobilenet_v3.preprocess_input`.

Artinya, kegagalan membaca kelas `unripe` murni berasal dari **distribusi dataset & bobot model SVM** pada `svm_pisang_3kelas(96%).pkl`.

### Rekomendasi Perbaikan Model (Jalur B / ML)
1. **Seimbangkan jumlah sampel `unripe` (Mentah):** tambah foto pisang hijau hingga setara dengan `ripe` dan `rotten`, atau terapkan `class_weight='balanced'` saat melatih `SVC`.
2. **Perbanyak variasi latar belakang alami saat training:** sertakan foto pisang hijau dengan latar kayu, plastik/terpal berwarna, lantai, dan pencahayaan luar ruangan—atau lakukan *augmentasi* crop/warna/background agar model tidak hanya menghafal foto studio berlatar putih.
3. **Evaluasi ulang nilai `C` & validasi silang per kelas:** periksa *confusion matrix* dan *recall* khusus kelas `unripe` pada uji citra nyata (bukan hanya akurasi rata-rata `96%`), karena akurasi total tinggi bisa menutupi *recall* kelas minoritas yang rendah.

---

## Anomali 2: Semua 8 Foto Menampilkan `"98% Akurasi Pindai"` di Detail Riwayat

### Gejala
Di seluruh 8 screenshot `Detail Riwayat Pindai`—baik yang berstatus `Matang` maupun `Busuk`, di latar putih, kayu, maupun biru—angka keyakinan di kanan atas **selalu identik `98%`**. Padahal probabilitas SVM untuk tiap gambar seharusnya berbeda.

### Akar Masalah Teknis (Terverifikasi)
Alur penyimpanan data hasil pindai di Flutter salah mengambil field confidence:

1. **`lib/services/fastapi_scan_service.dart` (baris 64–65 & 87–93):**
   Server FastAPI memang mengembalikan probabilitas prediksi kematangan yang sebenarnya (`data['confidence']`), lalu menyimpannya ke `ripenessConfidence`. Namun karena model backend saat ini khusus pisang dan tidak mengklasifikasikan jenis buah lain, `FastApiScanService.scan` mengisi `fruitConfidence` dengan angka statis **`0.98`**:
   ```dart
   return ScanSuccess(
     fruitLabel: fruitLabel,
     ripenessLabel: rawRipeness,
     fruitConfidence: 0.98,
     ripenessConfidence: ripenessConfidence,
     classProbabilities: classProbabilities,
   );
   ```
2. **`lib/providers/scan_notifier.dart` (baris 41–48):**
   Saat menyimpan catatan riwayat ke database lokal (`ScanResult`), `ScanNotifier._run` justru menyimpan `outcome.fruitConfidence` (`0.98`), bukan `outcome.ripenessConfidence`:
   ```dart
   final resultRecord = ScanResult(
     imagePath: imagePath,
     fruitLabel: outcome.fruitLabel,
     ripenessLabel: outcome.ripenessLabel,
     confidence: outcome.fruitConfidence, // <-- selalu 0.98 untuk hasil FastAPI
     createdAt: DateTime.now(),
   );
   ```
3. **`lib/ui/screens/history_detail_screen.dart` (baris 157–166):**
   Halaman detail riwayat merender `(item.confidence * 100).toStringAsFixed(0)%` dengan label `Akurasi Pindai`. Karena `item.confidence` selalu tersimpan `0.98`, semua riwayat pindai menampilkan `98%`.

### Rekomendasi Perbaikan Kode (Jalur A / Flutter)
- Ubah baris 45 pada `lib/providers/scan_notifier.dart` dari:
  ```dart
  confidence: outcome.fruitConfidence,
  ```
  menjadi:
  ```dart
  confidence: outcome.ripenessConfidence,
  ```
  *(Catatan: perbaikan ini akan membuat seluruh riwayat baru menyimpan skor probabilitas SVM yang sebenarnya. Data riwayat lama di SQLite yang sudah terlanjur tersimpan dengan `0.98` tetap bernilai `98%` kecuali dipindai ulang.)*

