# Laporan Audit Uji On-Device FruitLens (ML Kit + TFLite MobileNetV3 + SVM Baru)

**Tanggal:** 14 November 2026  
**Artefak Model yang Diaudit:**
- `baca/mobilenet_v3_extractor.tflite`
- `baca/svm_pisang_3kelasNew.pkl` (dikonversi ke `assets/models/svm_pisang_meta.json` & `svm_pisang_weights.bin`)

**Modul Flutter yang Diaudit:**
- `lib/services/ml_kit_fruit_detector.dart`
- `lib/services/on_device_scan_service.dart`
- `lib/services/on_device_image_preprocessor.dart`
- `lib/services/on_device_svm_classifier.dart`
- `lib/providers/scan_notifier.dart`
- `lib/core/constants/app_constants.dart`

---

## 1. Ringkasan Eksekutif

Pengujian 8 foto pisang pada aplikasi Flutter memunculkan **2 masalah utama yang sumbernya terpisah**:

1. **Foto pisang asli (#1, #2, #6) ditolak sebagai `"Buah tidak dikenali"` (`ScanUncertain`)** -> Akar masalah ada di **aplikasi Flutter (Jalur A)** akibat konflik ambang batas (*threshold*) antara `MlKitFruitValidator` (`0.45`) dan `ScanNotifier` (`0.60`), plus logika fallback `0.90` yang terbalik.
2. **Pisang mentah (#3 & #7) masih terdeteksi `"Matang"`** -> Akar masalah ada di **pipeline training `svm_pisang_3kelasNew.pkl` (Jalur B)**: pengali bobot `hsv_weight = 2.5` ternetralisir otomatis oleh `StandardScaler()`, sehingga SVM masih didominasi **94.1% fitur CNN** vs **5.9% fitur HSV**, ditambah margin `C = 0.015` yang terlalu lunak.

> **Hasil Verifikasi Paritas Dart vs Python:**  
> Implementasi matematika `OnDeviceSvmClassifier` di Dart sudah diuji terhadap `scikit-learn` (`svm.predict_proba`) pada seluruh 8 vektor uji nyata dan terbukti **identik** dengan selisih maksimum hanya **`2.13e-12` s/d `3.86e-8`**. Artinya, kesalahan prediksi bukan berasal dari rumus SVM di Dart.

---

## 2. Rekap Hasil Uji: Aplikasi HP vs Pengujian Python (Crop Gambar UI)

| No | Kondisi Foto Uji | Hasil di Aplikasi (HP) | Hasil Python TFLite+SVM (Crop UI) | Diagnosis Utama |
|---|---|---|---|---|
| #1 | Pisang hijau tunggal (latar putih) | **Buah tidak dikenali** (`ScanUncertain`) | `Mentah 100.0%` (`mean H = 40.5`) | Diblokir threshold Flutter / ML Kit (lihat Bab 3) |
| #2 | Pisang kuning tunggal (latar gelap/aspal) | **Buah tidak dikenali** (`ScanUncertain`) | `Matang 98.9%`, `Busuk 1.1%` (`mean H = 19.2`) | Diblokir threshold Flutter / ML Kit (lihat Bab 3) |
| #3 | Pisang hijau tunggal (latar putih) | **Matang 96%** (`Mentah 1.3%`) | Crop pas: **`Mentah 84–86%`**, tapi diberi ruang putih 3:4 -> **`Matang 88.9%`** | CNN terlalu dominan (94.1%) & sensitif terhadap rasio/latar foto |
| #4 | 2 pisang busuk cokelat/hitam | **Busuk 81%** (`Matang 19.2%`) | `Busuk 95.7%`, `Matang 4.2%` | Sesuai |
| #5 | 3 pisang kuning (latar putih) | **Matang 90%** (`Busuk 9.6%`) | `Matang 93.9%`, `Busuk 5.7%` | Sesuai |
| #6 | Sesisir pisang kuning berbintik cokelat | **Buah tidak dikenali** (`ScanUncertain`) | `Busuk 57.4–59.9%`, `Matang 39.8–42.4%` | Lolos threshold service (`0.35`), tapi dibuang `ScanNotifier` karena `< 0.60` |
| #7 | Sesisir pisang hijau kekuningan | **Matang 61%** (`Busuk 35.6%`, `Mentah 3.5%`) | `Matang 59.7–67.2%`, `Busuk 30.2–38.8%`, `Mentah 1.4–2.6%` (`mean H = 34.0`) | Overlap Hue bin 4 + CNN sesisir + `C = 0.015` |
| #8 | Sesisir pisang kuning (latar kayu) | **Matang 87%** (`Busuk 13.2%`) | `Matang 66.8%`, `Busuk 33.1%` | Sesuai |

*(Catatan: pada `baca/foto_uji/02_hijau_latar_putih_2253_matang.jpg`, model juga memprediksi `Matang 47–62%`, `Busuk 36–52%`, `Mentah ~1%`.)*

---

## 3. Audit Masalah #1 — Bug di Kode Flutter (Jalur A)

### A. Bentrok Threshold `0.45` vs `0.60` & Bug Fallback `0.90`
- Di `lib/services/ml_kit_fruit_detector.dart`, `ImageLabeler` diset `confidenceThreshold: 0.45`.
- Pada `evaluateLabels()` (baris 173–175):
  ```dart
  final resolvedConfidence = bestBananaConfidence > 0
      ? bestBananaConfidence
      : (bestFruitConfidence > 0 ? bestFruitConfidence : 0.90);
  ```
- Sementara itu di `lib/providers/scan_notifier.dart` (`_applyThreshold`, baris 103–109), hasil `ScanSuccess` tetap dibuang menjadi `ScanUncertain` (*"Buah tidak dikenali"*) bila:
  ```dart
  outcome.fruitConfidence < kConfidenceThreshold ||
  outcome.ripenessConfidence < kConfidenceThreshold
  ```
  dengan `kConfidenceThreshold = 0.6` (`lib/core/constants/app_constants.dart`).
- **Dampak logis (khususnya pada Foto #1 & #2):**  
  *(Catatan: runtime native Google ML Kit Android tidak dijalankan langsung pada environment audit ini, sehingga perilaku spesifik di HP disimpulkan dari alur kode di atas.)*  
  Model bawaan Google ML Kit *Image Labeling* adalah model umum ~400 kelas, bukan detektor pisang khusus. Bila ML Kit memberi label `Banana` / `Fruit` / `Food` / `Vegetable` dengan skor **`0.45–0.59`**, `MlKitFruitValidator` meloloskannya, lalu `ScanNotifier` **langsung menolaknya sebagai `"Buah tidak dikenali"`** karena `< 0.60`. Ironisnya, jika ML Kit tidak menemukan label buah maupun non-buah yang kuat (`bestFruitConfidence == 0.0`), fallback justru diisi `0.90` dan lolos. Selain itu, pada foto dengan latar gelap/bertekstur (#2), jika ML Kit tidak mengeluarkan label buah `>= 0.45` dan mengeluarkan label di `_nonFruitKeywords` `>= 0.60`, validator juga akan menolak gambar.

### B. Threshold `ripenessConfidence < 0.60` Membuang Kasus Transisi (Terbukti di Foto #6)
- `OnDeviceScanService` sudah menetapkan ambang ragu `0.35` untuk model 3 kelas.
- Namun `ScanNotifier._applyThreshold` tetap mewajibkan `ripenessConfidence >= 0.60`.
- Pada Foto #6 (pisang kuning berbintik cokelat di fase transisi matang menuju busuk), SVM menghasilkan **`Busuk 57.4%–59.9%` vs `Matang 39.8%–42.4%`**. Karena skor tertinggi tipis di bawah `60%`, `ScanNotifier` membuang seluruh probabilitas tersebut dan menampilkan *"Buah tidak dikenali"*.

### C. Perbedaan Minor Algoritma Resize (Flutter vs Python)
- `OnDeviceImagePreprocessor` menggunakan `img.Interpolation.linear` dari `package:image` (tanpa filter anti-aliasing saat mengecilkan gambar beresolusi besar), sedangkan Python `PIL.Image.Resampling.BILINEAR` menerapkan resampling dengan anti-aliasing.
- Perbedaan terukur pada foto uji: `hsv_max_diff` sekitar **`0.013–0.069`** dan rata-rata tensor input CNN (`cnn_mean_diff`) sekitar **`0.16–1.03`**.

---

## 4. Audit Masalah #2 — Bug Pipeline Training Model `svm_pisang_3kelasNew.pkl` (Jalur B / Colab)

Hasil inspeksi internal `baca/svm_pisang_3kelasNew.pkl`:
- `class_names`: `['ripe', 'rotten', 'unripe']`
- `hsv_weight`: `2.5`
- `SVC`: `kernel='rbf'`, **`C = 0.015`**, `gamma = 0.001968`, `class_weight = 'balanced'`
- `n_support_`: **`ripe = 2.409`**, **`rotten = 2.144`**, **`unripe = 1.609`** *(total 6.162 support vectors)*

### A. Pengali `hsv_weight = 2.5` Dibatalkan Total oleh `StandardScaler()`
Pipeline `prep` di `.pkl` adalah:
1. `cnn_pca` (`slice(0, 576)`): `StandardScaler()` ➔ `PCA(n_components=100)`
2. `hsv_pure` (`slice(576, 606)`): **`StandardScaler()`**

Karena fitur HSV dikali `2.5` **sebelum** masuk ke `StandardScaler`, rumus standardisasi $z = \frac{2.5x - 2.5\mu}{2.5\sigma} = \frac{x - \mu}{\sigma}$ **otomatis menghapus faktor `2.5` kembali menjadi `1.0`**. Bobot ekstra `2.5x` yang dimaksudkan di kode ekstraksi tidak pernah sampai ke SVM.

### B. Ruang Fitur RBF SVM Masih Didominasi **94.1% CNN vs 5.9% HSV**
Karena `cnn_pca` men-standardize **sebelum** PCA dan tidak men-standardize ulang komponen PCA (atau menormalkan blok):
- Total varians 100 fitur CNN yang masuk ke kernel RBF = **`478.1`** (pada *support vectors*: **`507.3`**).
- Total varians 30 fitur HSV = **`30.0`** (pada *support vectors*: **`35.7`**).
- Rasio pengaruh jarak Euclidean kuadrat di kernel RBF masih **`94.1% CNN : 5.9% HSV`**.

### C. Bukti Pengaruh Latar Putih/Rasio Foto pada Foto #3
Pada Foto #3 (pisang hijau latar putih):
- Saat area pisang di-crop rapat sesuai kotak preview UI, Python TFLite+SVM memprediksi **`Mentah 84.2%` / `Matang 15.4%`**.
- Ketika gambar yang sama diberi tambahan latar putih atas-bawah agar berbentuk persegi (`1:1`), prediksi berubah menjadi **`Matang 68.0%` / `Mentah 31.5%`**.
- Saat diberi latar putih rasio portrait (`3:4`), prediksi langsung berbalik menjadi **`Matang 88.9%` / `Mentah 10.2%`** (di foto asli HP mencapai **`Matang 96.0%`**).
- Padahal fitur HSV pada ketiga kondisi tersebut nyaris tidak berubah karena piksel putih (`Saturation < 28`) dibuang oleh masking HSV. Pembalikan prediksi berasal dari fitur CNN MobileNetV3 yang masih mendominasi 94.1%.

### D. Tumpang Tindih Warna Hijau Kekuningan & `C = 0.015` (Foto #7)
Dari inspeksi nilai HSV rata-rata seluruh *support vectors* tiap kelas (skala OpenCV `H: 0–179`):
- `ripe` (Matang): rata-rata `H = 25.4`, proporsi bin Hue 4 (`H = 30–37.5`) = **`0.190`**
- `rotten` (Busuk): rata-rata `H = 23.9`, proporsi bin Hue 4 (`H = 30–37.5`) = **`0.205`**
- `unripe` (Mentah): rata-rata `H = 36.7`, puncak bin Hue 4 = **`0.482`** dan bin Hue 5 (`37.5–45`) = **`0.430`**

Foto #7 (sesisir pisang hijau kekuningan dengan bayangan & tangkai) memiliki `mean H = 34.0` yang berada tepat di bin 4, ditambah struktur visual sesisir pada CNN yang mirip banyak sampel `ripe`/`rotten`. Dengan `n_support_` `unripe` paling sedikit (`1.609`) dan `C = 0.015` (lebih lunak lagi dari model lama `0.03`), margin keputusan menggeser Foto #7 ke **`Matang 61%` / `Busuk 36%`**.

---

## 5. Rencana Perbaikan Konkret (Per Jalur)

### A. Perbaikan untuk Jalur B (Training Model di Colab — Teman)
1. **Terapkan bobot warna HSV *sesudah* scaling (jangan sebelum `StandardScaler`):**
   - Standarisasi/normalisasi output `cnn_pca` (atau bagi dengan $\sqrt{\text{total\_var}}$ / tambahkan `StandardScaler()` sesudah `PCA`), lalu kalikan blok HSV dengan bobot (misal `2.5–4.0` atau sesuaikan proporsi PCA lebih kecil, misal `30–50` komponen) **sesudah** `StandardScaler` agar porsi varians HSV benar-benar naik menjadi **~40–50%** terhadap CNN.
   - *(Contoh sederhana di `sklearn`: pakai `FunctionTransformer(lambda X: X * 3.0)` di akhir pipeline `hsv_pure`, setelah `StandardScaler()`, serta pertimbangkan `StandardScaler()` setelah `PCA` pada `cnn_pca` agar kedua blok seimbang sebelum diboboti.)*
2. **Crop Otomatis (*Tight Bounding Box*) Sebelum Ekstraksi CNN:**
   - Saat training (dan nanti disamakan ke Flutter/kontrak), deteksi bounding box piksel buah dari mask HSV lalu crop gambar sebelum di-resize ke `224×224` untuk MobileNetV3. Ini menghilangkan bias ruang kosong/latar putih seperti pada kasus Foto #3.
3. **Naikkan `C` dan Perbanyak Data Sesisir Hijau:**
   - Lakukan tuning `C` di kisaran `0.5 – 5.0` (jangan `0.015`) agar batas `unripe` tidak mengalah pada area tumpang tindih bin Hue 4, dan tambahkan foto **sesisir pisang mentah** (hijau muda & hijau tua) pada set latih.

### B. Perbaikan untuk Jalur A (Aplikasi Flutter)
1. **Pisahkan validasi non-buah vs ambang skor kematangan di `ScanNotifier` & `MlKitFruitValidator`:**
   - Hilangkan penolakan paksa `ripenessConfidence < 0.60` di `ScanNotifier` untuk output `OnDeviceScanService` agar kasus transisi seperti Foto #6 (`57–60%`) tetap menampilkan rincian probabilitas 3 kelas (bukan *"Buah tidak dikenali"*).
   - Hilangkan ketergantungan `ScanNotifier` pada `fruitConfidence < 0.60` saat `MlKitFruitValidator` sudah menyatakan gambar valid (`0.45`), dan perbaiki logika fallback `0.90` agar konsisten.
2. **Evaluasi interpolasi resize di `OnDeviceImagePreprocessor`:**
   - Uji `img.Interpolation.average` / `cubic` agar downscaling foto resolusi tinggi lebih mendekati `PIL.BILINEAR`.
