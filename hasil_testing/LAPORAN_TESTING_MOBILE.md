# Laporan Hasil Testing Aplikasi Mobile FruitLens

**Tanggal Pengujian:** 18 November 2026  
**Cakupan Pengujian:**
1. Pengujian langsung pada aplikasi mobile Flutter (12 sampel foto/ilustrasi pisang).
2. Pengujian otomatis & analisis statis kode internal (`flutter analyze`, `flutter test`, dan inspeksi kode/model).

---

## 1. Ringkasan Eksekutif

- **Uji Otomatis Kode (`flutter analyze` & `flutter test`):**
  - `flutter analyze`: **Bersih (`No issues found!`)**.
  - `flutter test`: **102 / 102 test lulus** (mencakup 32 file uji: logika gating keamanan pangan, generator resep, chatbot, scan notifier, repository SQLite, dan widget UI).
- **Uji Aplikasi Mobile (12 Sampel):**
  - **Kelas Matang (utuh & terkupas — 3 sampel):** `3/3` terklasifikasi **Matang** (1 sampel terkupas di confidence rendah `57%`).
  - **Kelas Busuk (4 sampel):** `4/4` terklasifikasi **Busuk**.
  - **Kelas Mentah (4 sampel):** `1/4` benar (`100%` pada pisang hijau tunggal foto asli), sedangkan **`3/4` salah terdeteksi sebagai Matang** (ilustrasi hijau, hijau kekuningan, dan sesisir hijau).
  - **Transisi *Overripe* berbintik cokelat (1 sampel):** Jatuh tipis ke **Busuk** (`50.2%` vs `Matang 49.7%`).
- **Alur UI & Gating Keamanan Pangan:** Seluruh tampilan label, banner peringatan `<60%`, estimasi tunggu pisang mentah (`4–5 hari`), tombol rekomendasi resep, dan peringatan buang untuk buah busuk berjalan konsisten 100%.

---

## 2. Rincian Hasil Uji 12 Sampel Aplikasi Mobile

| No | Sampel Uji | Screenshot | Hasil Prediksi | Rincian Probabilitas (Mentah / Matang / Busuk) | Evaluasi & Status Gating UI |
|:---:|---|---|---|---|---|
| 1 | 1 pisang hijau tunggal (foto asli, latar putih) | [01_mentah_tunggal_hijau_benar.jpg](./screenshots/01_mentah_tunggal_hijau_benar.jpg) | **Mentah (100%)** | `100.0%` / `0.0%` / `0.0%` | **Benar.** Muncul Opsi Olahan Mentah + estimasi `4–5 hari`. |
| 2 | 1 pisang hijau (gambar ilustrasi/kartun, latar putih) | [02_mentah_ilustrasi_hijau_salah_matang.jpg](./screenshots/02_mentah_ilustrasi_hijau_salah_matang.jpg) | **Matang (66%)** | `0.8%` / `65.9%` / `33.3%` | **Salah (False Matang).** Gating masuk `Matang Banget`. |
| 3 | 1 pisang hijau kekuningan (foto asli, latar putih) | [03_mentah_hijau_kekuningan_salah_matang.jpg](./screenshots/03_mentah_hijau_kekuningan_salah_matang.jpg) | **Matang (95%)** | `1.1%` / `95.5%` / `3.4%` | **Salah (False Matang).** Gating masuk `Matang Pas`. |
| 4 | 1 pisang kuning matang terkupas sebagian (latar putih) | [04_matang_terkupas_low_conf.jpg](./screenshots/04_matang_terkupas_low_conf.jpg) | **Matang (57%)** | `0.2%` / `57.5%` / `42.3%` | **Benar (Confidence `<60%`).** Muncul banner foto kurang jelas + `Matang Banget`. |
| 5 | 1 pisang kuning matang (latar polos kebiruan/abu) | [05_matang_tunggal_latar_abu_benar.jpg](./screenshots/05_matang_tunggal_latar_abu_benar.jpg) | **Matang (100%)** | `0.2%` / `99.6%` / `0.3%` | **Benar (Sangat Akurat).** Gating masuk `Matang Pas`. |
| 6 | 1 pisang kuning matang (latar gelap/aspal bertekstur) | [06_matang_tunggal_latar_gelap_benar.jpg](./screenshots/06_matang_tunggal_latar_gelap_benar.jpg) | **Matang (98%)** | `0.1%` / `97.9%` / `2.0%` | **Benar (Sangat Akurat).** Lolos validasi latar gelap. |
| 7 | 1 pisang kulit cokelat-hitam (busuk, latar putih) | [07_busuk_tunggal_cokelat_benar.jpg](./screenshots/07_busuk_tunggal_cokelat_benar.jpg) | **Busuk (61%)** | `0.3%` / `39.2%` / `60.6%` | **Benar.** Muncul peringatan `"Buang saja, jangan dikonsumsi"` + `Tips Daur Ulang`. |
| 8 | 1 pisang kulit cokelat gelap (busuk, latar putih) | [08_busuk_tunggal_gelap_benar.jpg](./screenshots/08_busuk_tunggal_gelap_benar.jpg) | **Busuk (61%)** | `0.3%` / `39.2%` / `60.5%` | **Benar.** Muncul peringatan buang + `Tips Daur Ulang`. |
| 9 | 2 pisang kulit hitam bercak berat (busuk, latar putih) | [09_busuk_dua_buah_hitam_benar.jpg](./screenshots/09_busuk_dua_buah_hitam_benar.jpg) | **Busuk (97%)** | `0.0%` / `3.4%` / `96.6%` | **Benar (Sangat Akurat).** Muncul peringatan buang + `Tips Daur Ulang`. |
| 10 | Sesisir pisang hijau (mentah, latar putih) | [10_mentah_sesisir_hijau_salah_matang.jpg](./screenshots/10_mentah_sesisir_hijau_salah_matang.jpg) | **Matang (87%)** | `8.1%` / `86.7%` / `5.2%` | **Salah (False Matang).** Gating masuk `Matang Pas`. |
| 11 | Sesisir pisang kuning berbintik cokelat merata (*overripe*) | [11_overripe_sesisir_bintik_abu_abu_busuk.jpg](./screenshots/11_overripe_sesisir_bintik_abu_abu_busuk.jpg) | **Busuk (50%)** | `0.2%` / `49.7%` / `50.2%` | **Batas Abu-abu (`<60%`).** Terbelah 50:50, muncul banner kurang jelas & peringatan buang. |
| 12 | Sesisir pisang kuning bercak cokelat-hitam (mulai busuk) | [12_transisi_sesisir_bercak_hitam_busuk.jpg](./screenshots/12_transisi_sesisir_bercak_hitam_busuk.jpg) | **Busuk (65%)** | `0.2%` / `35.1%` / `64.7%` | **Sesuai (Transisi ke Busuk).** Muncul peringatan buang + `Tips Daur Ulang`. |

---

## 3. Daftar Penemuan Masalah & Analisis Akar Masalah

### A. Masalah Model Visi Komputer (Terbukti pada Pengujian Mobile)

1. **Pisang Mentah Hijau Kekuningan, Ilustrasi, & Sesisir Salah Terdeteksi sebagai Matang (Sampel #2, #3, #10)**
   - **Gejala:** Pisang hijau yang warnanya agak kekuningan (`#3` → `Matang 95.5%`), sesisir pisang hijau (`#10` → `Matang 86.7%`), dan ilustrasi pisang hijau (`#2` → `Matang 65.9%`) diklasifikasikan sebagai **Matang**.
   - **Akar Masalah (berdasarkan audit `baca/laporan_audit_ondevice_v2.md`):**
     - Pada pipeline training `svm_pisang_3kelasNew.pkl`, pengali bobot warna `hsv_weight = 2.5` ternetralisir otomatis karena diterapkan *sebelum* `StandardScaler()`. Akibatnya, jarak kernel RBF masih didominasi **94,1% fitur bentuk CNN (`MobileNetV3Small`)** vs **5,9% fitur warna HSV**.
     - Kelas `unripe` memiliki jumlah *support vectors* paling sedikit (`1.609` dibanding `ripe` `2.409` dan `rotten` `2.144`) dengan parameter regularisasi `C = 0.015` yang terlalu lunak.
     - Akibatnya, saat pisang mentah memiliki sedikit semburat kuning, berbentuk sesisir, atau berupa gambar ilustrasi, fitur bentuk CNN mengalahkan sinyal warna hijau HSV.
   - **Catatan Verifikasi:** Rumus `OnDeviceSvmClassifier` di Dart sudah diuji paritasnya terhadap `scikit-learn` (selisih maksimum `<= 3.86e-8`), sehingga kesalahan **bukan** berasal dari bug perhitungan aplikasi Flutter.

2. **Pisang Sangat Matang Berbintik Cokelat (*Overripe*) Terdorong ke Kelas Busuk (Sampel #11)**
   - **Gejala:** Sesisir pisang kuning berbintik cokelat merata (yang secara konsumsi masih tergolong sangat matang dan layak diolah) menghasilkan probabilitas nyaris seimbang (**Busuk 50.2%** vs **Matang 49.7%**), sehingga memicu peringatan `"Buang saja, jangan dikonsumsi"`.
   - **Akar Masalah:** Model SVM aktif hanya memiliki **3 kelas** (`unripe`, `ripe`, `rotten`) tanpa kelas `overripe`. Bintik cokelat pada kulit memicu kesamaan tekstur dengan kelas `rotten`.

3. **Pisang Terkupas Menurunkan Keyakinan Model (Sampel #4)**
   - **Gejala:** Pisang kuning matang yang sudah dikupas sebagian terprediksi **Matang 57.5%** dengan **Busuk 42.3%**, sehingga memicu banner peringatan `"Hasil foto kurang jelas (<60%)"`.
   - **Akar Masalah:** Dataset latih berfokus pada buah berkulit utuh, sehingga bagian daging buah yang terbuka diinterpretasikan sebagai ketidakpastian antara `Matang` dan `Busuk`.

---

### B. Masalah & Catatan Teknis Bagian Dalam (Audit Kode Flutter & Integrasi)

1. **Cakupan Model Baru Pisang & Hardcode `'banana'` (`lib/services/ml_kit_fruit_detector.dart`)**
   - `MlKitFruitValidator.evaluateLabels()` saat ini selalu mengembalikan `detectedFruitType: 'banana'`. Jika pengguna memindai buah lain (misalnya apel atau mangga), klasifikasi kematangannya tetap diproses menggunakan model SVM pisang.

2. **Fallback Confidence `0.90` Saat ML Kit Tidak Menemukan Label (`lib/services/ml_kit_fruit_detector.dart`)**
   - Jika Google ML Kit tidak mengeluarkan label buah (`bestFruitConfidence == 0.0`) dan juga tidak mendeteksi label non-buah `>= 0.60` (misalnya foto dinding polos atau sangat buram), `resolvedConfidence` masih diisi nilai fallback `0.90`, sehingga gambar berisiko lolos ke classifier SVM.

3. **Selisih Minor Resize Gambar Antara Flutter dan Python**
   - `OnDeviceImagePreprocessor` menggunakan `img.Interpolation.linear` dari `package:image` (tanpa *anti-aliasing*), berbeda tipis dari `PIL.Image` di Python (`hsv_max_diff` sekitar `0,013–0,069`).

4. **Ketergantungan Layanan AI Eksternal (Gemini API)**
   - Fitur rekomendasi resep AI (`lib/services/gemini_recipe_service.dart`) dan chatbot (`lib/services/gemini_chat_service.dart`) bergantung pada koneksi internet, kuota API, dan kestabilan server Google (`HTTP 503`/`429`).
   - **Mitigasi yang sudah berjalan:** Penambahan model cadangan (`gemini-2.5-flash-lite`, `gemini-3.5-flash`) dan fallback otomatis ke 12 resep lokal (`recipes.json` / SQLite) saat offline atau kuota habis.

---

## 4. Perbaikan yang Terbukti Berhasil pada Pengujian Ini

- **Latar gelap & skor transisi tidak lagi ditolak:** Sampel **#6** (pisang kuning di atas aspal gelap) berhasil dikenali **Matang 98%**, dan sampel dengan confidence `50%`–`57%` (**#4**, **#11**) tidak lagi dibuang sebagai `"Buah tidak dikenali"`, melainkan ditampilkan beserta peringatan foto kurang jelas (`<60%`).
- **Gating keamanan pangan 100% konsisten:** Buah busuk otomatis menahan tombol resep dan menampilkan peringatan buang + tips daur ulang; buah mentah menampilkan estimasi waktu tunggu matang; buah matang membuka akses ke halaman rekomendasi resep AI.

---

## 5. Rekomendasi Tindak Lanjut

1. **Untuk Jalur B (Model CV):** Terapkan pembobotan fitur HSV *sesudah* `StandardScaler()` (jangan sebelumnya), seimbangkan jumlah data/support vectors kelas `unripe`, tambah variasi foto pisang hijau kekuningan & sesisir, serta pertimbangkan penambahan kelas `overripe` jika pisang berbintik cokelat ingin tetap direkomendasikan untuk diolah.
2. **Untuk Jalur A (Flutter):** Perbaiki fallback confidence `0.90` di `MlKitFruitValidator` agar foto polos/buram tertolak aman sebagai `ScanUncertain`, serta dokumentasikan batasan bahwa model aktif baru mendukung komoditas pisang.
