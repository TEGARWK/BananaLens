# Laporan Hasil Uji Aplikasi Mobile (Model PCA 100 + SPK PSO-RF) — Untuk Tim Model (Jalur B)

**Tanggal Pengujian:** 21 November 2026  
**Artefak Model yang Diuji:**
- `svm_pisang_meta.json` + `svm_pisang_weights.bin` (4 kelas: `overripe`, `ripe`, `rotten`, `unripe`, **PCA 100**, `5.434` *support vectors*, `gamma = 0.001508`)
- `mobilenet_v3_extractor.tflite` (versi terbaru)
- `spk_pso_rf_model.json` (26 pohon Random Forest hasil PSO)

**Lokasi Bukti Screenshot:** [`hasil_testing/screenshots_v3_final/`](./screenshots_v3_final/)

---

## 1. Ringkasan Eksekutif

1. **Integrasi Aplikasi & SPK (Jalur A) Sudah 100% Berjalan Baik:**
   - Seluruh dimensi classifier (`cnnDim = 576`, `pcaDim = 100`, `hsvDim = 30`) sudah dibaca dinamis dari metadata model tanpa hardcode.
   - **SPK PSO-RF (26 pohon)** sudah terintegrasi di layar hasil pindai dengan input `target_days` (`0/1/2`) & `usage_goal` (`0/1/2`), dan menghasilkan keputusan yang sinkron (*Simpan & Distribusi*, *Konsumsi & Jual Segar*, *Segera Olah*, *Buang / Kompos*).
   - Perbaikan kalibrasi latar gelap di Flutter berhasil menyelamatkan foto pisang kuning di aspal hitam (dari salah `Busuk 58%` → menjadi **`Matang 69%`**).

2. **Temuan Utama pada Model SVM Baru (Untuk Evaluasi Jalur B):**
   - Kelas **`Mentah` (`unripe`)** dan **`Matang` (`ripe`)** sudah jauh lebih stabil (termasuk di latar kayu gelap & aspal).
   - **MASALAH KRITIS pada kelas `Matang Banget` (`overripe`):** Pada **5 dari 5 foto uji pisang berbintik cokelat (*sugar spots*)** yang jelas merupakan *overripe*, probabilitas `overripe` dari model baru **selalu terjebak sangat rendah di angka `2.2% – 2.4%`**, kalah oleh `Matang` (`49%–69%`) dan `Busuk` (`28%–48%`).

---

## 2. Rincian Hasil Uji 9 Sampel Terbaru di Perangkat Android

| No | Sampel Uji | Screenshot | Prediksi Utama | `Mentah` | `Matang` | `Matang Banget` (`overripe`) | `Busuk` | Evaluasi |
|:---:|---|---|---|---|---|---|---|---|
| 1 | 1 pisang kuning mulus di atas aspal hitam | [01_matang_aspal_gelap_benar_69.jpg](./screenshots_v3_final/01_matang_aspal_gelap_benar_69.jpg) | **Matang (69%)** | `0.4%` | `69.2%` | `2.6%` | `27.8%` | **Benar** *(dibantu kalibrasi latar gelap Flutter; skor mentah SVM sebelumnya `Busuk 58.4%`)*. |
| 2 | Sesisir pisang kuning berbintik cokelat (*sugar spots*, latar putih) | [02_overripe_sesisir_bintik_putih_57.jpg](./screenshots_v3_final/02_overripe_sesisir_bintik_putih_57.jpg) | **Matang (57%)** | `0.8%` | `56.8%` | **`2.3%`** | `40.1%` | **Meleset Kelas (`overripe` → `ripe`).** Skor `overripe` hanya `2.3%`. |
| 3 | 1 pisang kuning mulus (latar abu-abu) | [03_matang_tunggal_abu_benar_68.jpg](./screenshots_v3_final/03_matang_tunggal_abu_benar_68.jpg) | **Matang (68%)** | `0.4%` | `68.3%` | `3.6%` | `27.6%` | **Benar** + SPK `Konsumsi & Jual Segar`. |
| 4 | Sesisir pisang kuning di meja kayu gelap | [04_matang_sesisir_kayu_gelap_benar_61.jpg](./screenshots_v3_final/04_matang_sesisir_kayu_gelap_benar_61.jpg) | **Matang (61%)** | `0.7%` | `60.6%` | `2.4%` | `36.4%` | **Benar** + SPK `Konsumsi & Jual Segar`. |
| 5 | Sesisir pisang hijau mentah di meja kayu | [05_mentah_sesisir_kayu_benar_75.jpg](./screenshots_v3_final/05_mentah_sesisir_kayu_benar_75.jpg) | **Mentah (75%)** | `75.5%` | `11.7%` | `2.3%` | `10.5%` | **Benar** + SPK `Simpan & Distribusi`. |
| 6 | 3 pisang berbintik cokelat padat (*sugar spots*, latar abu) | [06_overripe_tiga_buah_bintik_69.jpg](./screenshots_v3_final/06_overripe_tiga_buah_bintik_69.jpg) | **Matang (69%)** | `0.6%` | `69.2%` | **`2.2%`** | `27.9%` | **Meleset Kelas (`overripe` → `ripe`).** Bintik cokelat padat, tetapi `overripe` hanya `2.2%`. |
| 7 | Sesisir pisang berbintik cokelat (meja kayu + kain kotak) | [07_overripe_sesisir_kayu_taplak_57.jpg](./screenshots_v3_final/07_overripe_sesisir_kayu_taplak_57.jpg) | **Matang (57%)** | `0.8%` | `57.1%` | **`2.3%`** | `39.8%` | **Meleset Kelas (`overripe` → `ripe`).** Skor `overripe` hanya `2.3%`. |
| 8 | 2 buah pisang kuning berbintik berat (latar putih) | [08_overripe_dua_buah_putih_49.jpg](./screenshots_v3_final/08_overripe_dua_buah_putih_49.jpg) | **Matang (49%)** | `0.7%` | `49.2%` | **`2.4%`** | `47.7%` | **Meleset Kelas (`overripe` → `ripe`/`rotten`).** Skor terbelah `49%` vs `48%`, `overripe` cuma `2.4%`. |
| 9 | 2 buah pisang berbintik halus (latar kotak PNG) | [09_overripe_dua_buah_png_67.jpg](./screenshots_v3_final/09_overripe_dua_buah_png_67.jpg) | **Matang (67%)** | `0.5%` | `67.2%` | **`2.2%`** | `30.1%` | **Meleset Kelas (`overripe` → `ripe`).** Skor `overripe` hanya `2.2%`. |

*(Catatan: Dari sesi sebelumnya sebelum kalibrasi latar gelap, foto pisang hitam busuk di latar putih tetap terdeteksi tepat **`Busuk 95%`** dan memicu SPK **`Tidak Layak Konsumsi / Daur Ulang Kompos`**).*

---

## 3. Analisis Teknis untuk Tim Model (Jalur B)

1. **Anomali Kelas `overripe` (`2.2% – 2.4%`) di Model PCA 100 Baru:**
   - Pada model **PCA 60** sebelumnya, pisang berbintik cokelat masih menghasilkan probabilitas `overripe` sebesar **`21% – 34%`**.
   - Pada model **PCA 100** terbaru (`svm_pisang_weights (1).bin`), meskipun akurasi validasi 80:20 tercatat **`96.11%`** (dengan kebocoran `39` data `overripe` → `ripe`), saat diuji dengan foto nyata di aplikasi (*unseen real-world images*), probabilitas `overripe` selalu turun ke **`~2.2% – 2.4%`**.
   - Hal ini membuat fitur **`Matang Banget`** pada aplikasi (dan skenario SPK untuk pisang *overripe*) hampir tidak pernah terpicu otomatis, karena model selalu membagi probabilitas hanya ke **`ripe`** (~50–69%) dan **`rotten`** (~28–48%).

2. **Sensitivitas Latar Gelap pada Output Mentah SVM:**
   - Tanpa bantuan kalibrasi warna di sisi Flutter, foto pisang kuning mulus di atas aspal gelap (Sampel #1) menghasilkan skor mentah SVM **`Busuk 58.4%`** vs `Matang 38.5%`. Menambah augmentasi background gelap pada data latih `ripe` akan sangat membantu ketahanan model di kondisi nyata.

---

## 4. Saran Perbaikan untuk Update Model Berikutnya (Jalur B)

1. **Cek Kalibrasi Probabilitas / `class_weight` & Kurasi Data `overripe`:**
   - Periksa kembali distribusi data latih kelas `overripe` vs `ripe` (pastikan pisang berbintik *sugar spots* tidak bercampur di folder `ripe`, dan jumlah sampel/bobot `overripe` cukup seimbang sehingga Platt scaling tidak menekan probabilitas `overripe` ke `~2%`).
2. **Uji Sampel Nyata di Python (`inference check`):**
   - Sebelum mengekspor `.bin`/`.json`, disarankan menguji 3–5 foto pisang berbintik dari Google/kamera (bukan dari split 80:20) langsung di notebook Python untuk memastikan `predict_proba()` untuk `overripe` bisa keluar di atas **60%**.
3. **Catatan Integrasi:**
   - Kode Flutter sudah mendukung dimensi dinamis sepenuhnya — jika ada model `.bin` + `.json` baru lagi, cukup ganti file di `assets/models/` tanpa perlu ubah kode aplikasi.
