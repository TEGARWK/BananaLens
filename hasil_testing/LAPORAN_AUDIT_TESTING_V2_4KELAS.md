# Laporan Audit & Analisis Hasil Testing Model 4-Kelas (V2) — BananaLens / FruitLens

**Tanggal Audit:** 21 November 2026  
**Versi Model Diuji:** SVM 4-Kelas + PCA 60 + MobileNetV3Small (`svm_pisang_weights.bin` v2, 2.17 MB)  
**Lokasi Bukti Screenshot:** [`hasil_testing/screenshots_v2_4kelas/`](./screenshots_v2_4kelas/)  
**Cakupan Pengujian:** 12 sampel uji langsung pada aplikasi mobile Android (termasuk 4 kelas kematangan pisang dan 1 sampel buah non-pisang).

---

## 1. Ringkasan Eksekutif & Spesifikasi Teknis Pipeline

Pengujian ini mengevaluasi perilaku end-to-end model baru 4-kelas dari Jalur B setelah diintegrasikan ke pipeline deteksi on-device Flutter (Jalur A):

1. **Tahap 1 — Google ML Kit Image Labeling** (`lib/services/ml_kit_fruit_detector.dart`): Pra-validasi label objek/buah secara on-device.
2. **Tahap 2 — Filter Pigmen Non-Pisang** (`lib/services/on_device_scan_service.dart`): Menolak objek dominan merah/oranye/ungu cerah (`nonBananaVividRatio >= 0.45`).
3. **Tahap 3 — Stage-1 Banana Gate** (`lib/services/on_device_banana_gate.dart`): Klasifikasi ImageNet EfficientNet-Lite0 (1000 kelas, target indeks `#954 = banana`, lolos jika `prob >= 0.08` atau masuk top-5 dengan `prob >= 0.03` dan rasio relatif `>= 0.25`).
4. **Tahap 4 — Ekstraksi Fitur & Klasifikasi SVM 4-Kelas** (`lib/services/on_device_svm_classifier.dart`):
   - **Ekstraktor CNN:** `mobilenet_v3_extractor.tflite` (`576` dimensi).
   - **Reduksi Dimensi:** PCA `60` komponen (sebelumnya `100` komponen pada model 3-kelas).
   - **Fitur Warna:** Masked HSV `30` dimensi (`hsv_weight = 2.5`) → total **90 fitur** gabungan.
   - **Parameter RBF SVM (`svm_pisang_meta.json`):** `gamma = 0.002154873`, total `5.443` *support vectors* (`overripe: 1.200`, `ripe: 1.775`, `rotten: 1.599`, `unripe: 869`), probabilitas dihitung via Platt Scaling (`6` pasangan kelas) + solver *pairwise coupling* Wu, Lin & Weng (2004).

### Ringkasan Hasil Uji 12 Sampel:
- **Prediksi Tepat & Confidence Tinggi (`81%–97%`):** **4 sampel** (`Mentah` #7, `Matang` #8, `Busuk` #9, dan penolakan `Mangga` #12).
- **Prediksi Benar dengan Bug Sinkronisasi UI Resep:** **1 sampel** (`Matang 64%` #5, kartu atas *Matang*, kartu resep bawah sempat tampil *Matang Banget* — **sudah diperbaiki**).
- **Prediksi Meleset / Terpecah di Zona `overripe` & Pisang Cokelat Gelap (`45%–55%`):** **6 sampel** (#1, #2, #3, #4, #10, #11).
- **False Rejection oleh Pra-Validasi / Gate:** **1 sampel** (pisang busuk di atas lantai keramik dengan watermark #6 ditolak sebagai `"Buah tidak dikenali"`).

---

## 2. Rincian Hasil Uji 12 Sampel Aplikasi Mobile

| No | Sampel Uji & Kondisi Visual | Screenshot | Hasil Utama App | Rincian Probabilitas (`Mentah` / `Matang` / `Matang Banget` / `Busuk`) | Evaluasi Akurasi & Perilaku UI |
|:---:|---|---|---|---|---|
| 1 | 2 buah pisang kuning berbintik cokelat merata (*sugar spots*, latar putih) | [01_overripe_dua_buah_bintik_salah_busuk_49.jpg](./screenshots_v2_4kelas/01_overripe_dua_buah_bintik_salah_busuk_49.jpg) | **Busuk (49%)** | `0.7%` / `46.0%` / **`3.9%`** / `49.3%` | **Meleset (Seharusnya Matang Banget).** Probabilitas terbelah antara `Matang` & `Busuk`; `Matang Banget` hanya `3.9%`. Muncul banner `<60%` & peringatan buang. |
| 2 | 3 buah pisang berbintik cokelat padat (latar abu-abu bertekstur) | [02_overripe_tiga_buah_bintik_salah_busuk_51.jpg](./screenshots_v2_4kelas/02_overripe_tiga_buah_bintik_salah_busuk_51.jpg) | **Busuk (51%)** | `0.2%` / `14.9%` / **`34.2%`** / `50.7%` | **Meleset Tipis (Seharusnya Matang Banget).** `Matang Banget` di urutan ke-2 (`34.2%`), kalah dari `Busuk` (`50.7%`). Muncul banner `<60%`. |
| 3 | Sesisir pisang kuning berbintik cokelat banyak (latar putih) | [03_overripe_sesisir_bintik_salah_matang_50.jpg](./screenshots_v2_4kelas/03_overripe_sesisir_bintik_salah_matang_50.jpg) | **Matang (50%)** | `0.9%` / `50.0%` / **`27.8%`** / `21.4%` | **Kurang Tepat (Seharusnya Matang Banget).** `Matang Banget` hanya `27.8%`, kalah oleh `Matang` (`50.0%`). Muncul banner `<60%`. |
| 4 | Sesisir pisang kuning bercak cokelat-hitam (latar putih) | [04_overripe_sesisir_bercak_hitam_salah_matang_45.jpg](./screenshots_v2_4kelas/04_overripe_sesisir_bercak_hitam_salah_matang_45.jpg) | **Matang (45%)** | `0.8%` / `45.0%` / **`25.0%`** / `29.2%` | **Meleset (Seharusnya Matang Banget / Busuk).** Skor terpecah ke 3 kelas (`45%` / `29%` / `25%`). Muncul banner `<60%`. |
| 5 | Sesisir pisang kuning cerah sedikit bintik (latar putih) | [05_matang_sesisir_kuning_benar_64_bug_resep.jpg](./screenshots_v2_4kelas/05_matang_sesisir_kuning_benar_64_bug_resep.jpg) | **Matang (64%)** | `0.3%` / `64.2%` / **`21.3%`** / `14.1%` | **Prediksi Benar, Bug UI Resep.** Kartu atas `Matang`, tetapi kartu `Ide Olahan Pisang` di bawah tampil `Matang Banget` *(telah diperbaiki di kode)*. |
| 6 | 3 pisang busuk cokelat tua di atas lantai keramik (+ watermark) | [06_busuk_tiga_buah_lantai_ditolak_tidak_dikenali.png](./screenshots_v2_4kelas/06_busuk_tiga_buah_lantai_ditolak_tidak_dikenali.png) | **Ditolak (`Buah tidak dikenali`)** | — | **False Rejection.** Ditolak oleh pra-validasi / Stage-1 Banana Gate sebelum masuk ke SVM. |
| 7 | Sesisir pisang hijau segar (mentah, latar putih) | [07_mentah_sesisir_hijau_benar_81.jpg](./screenshots_v2_4kelas/07_mentah_sesisir_hijau_benar_81.jpg) | **Mentah (81%)** | `80.9%` / `16.6%` / `0.8%` / `1.6%` | **Benar & Akurat.** Muncul opsi olahan pisang mentah (`Tunggu matang` / `Masak sekarang`). |
| 8 | 3 buah pisang kuning mulus (matang pas, latar putih) | [08_matang_tiga_buah_kuning_mulus_benar_93.jpg](./screenshots_v2_4kelas/08_matang_tiga_buah_kuning_mulus_benar_93.jpg) | **Matang (93%)** | `0.7%` / `93.4%` / `3.9%` / `2.1%` | **Benar & Sangat Akurat.** Kartu `Ide Olahan Pisang` tampil `Matang Pas`. |
| 9 | 2 buah pisang hitam/busuk (latar putih) | [09_busuk_dua_buah_hitam_latar_putih_benar_97.jpg](./screenshots_v2_4kelas/09_busuk_dua_buah_hitam_latar_putih_benar_97.jpg) | **Busuk (97%)** | `0.0%` / `1.4%` / `1.3%` / `97.2%` | **Benar & Sangat Akurat.** Peringatan `"Buang saja, jangan dikonsumsi"` + `Tips Daur Ulang` aktif. |
| 10 | 1 pisang tunggal kulit cokelat-hitam menyeluruh (latar putih) | [10_busuk_tunggal_cokelat_gelap_salah_matang_49.jpg](./screenshots_v2_4kelas/10_busuk_tunggal_cokelat_gelap_salah_matang_49.jpg) | **Matang (49%)** | `1.0%` / `49.1%` / **`3.4%`** / `46.4%` | **Meleset Fatal (Seharusnya Busuk).** Pisang cokelat gelap diprediksi `Matang` (`49.1%` vs `Busuk 46.4%`); `Matang Banget` hanya `3.4%`. |
| 11 | 1 pisang tunggal kulit cokelat tua berbercak jamur (latar putih) | [11_busuk_tunggal_cokelat_berjamur_salah_matang_55.jpg](./screenshots_v2_4kelas/11_busuk_tunggal_cokelat_berjamur_salah_matang_55.jpg) | **Matang (55%)** | `0.8%` / `54.9%` / **`3.4%`** / `40.9%` | **Meleset Fatal (Seharusnya Busuk).** Pisang cokelat tua diprediksi `Matang` (`54.9%` vs `Busuk 40.9%`); `Matang Banget` hanya `3.4%`. |
| 12 | Buah non-pisang: mangga iris kuning-oranye (latar putih) | [12_non_pisang_mangga_ditolak_benar.png](./screenshots_v2_4kelas/12_non_pisang_mangga_ditolak_benar.png) | **Ditolak (`Buah tidak dikenali`)** | — | **Benar.** Filter non-pisang bekerja dengan tepat menahan buah mangga. |

---

## 3. Audit Mendalam & Analisis Akar Masalah

### A. Temuan pada Model SVM 4-Kelas (Jalur B)

#### 1. Lemahnya Separasi Kelas `overripe` (`Matang Banget`) pada Sampel #1, #2, #3, #4
- **Fakta Pengujian:** Pada keempat foto pisang berbintik cokelat (*sugar spots*) yang secara visual merupakan ciri klasik *overripe*, kelas `overripe` gagal menjadi pemenang di **4 dari 4 kasus** (`3.9%`, `34.2%`, `27.8%`, dan `25.0%`).
- **Akar Masalah Teknis:**
  1. **Posisi Fitur di Ruang Transisi:** Secara spektrum warna dan tekstur, *sugar spots* berada tepat di perbatasan antara `ripe` (kuning polos) dan `rotten` (cokelat/hitam). Pada ruang RBF kernel SVM, jarak vektor uji terhadap *support vectors* `ripe` dan `rotten` hampir seimbang, sehingga probabilitasnya terpecah (~45–50% ke `ripe` atau `rotten`).
  2. **Pemangkasan Dimensi PCA (`100` → `60`):** Model baru memangkas dimensi fitur CNN dari `100` komponen menjadi `60` komponen (`pca_components: [60, 576]`). Reduksi varian yang lebih agresif berisiko mengaburkan komponen halus (*high-frequency texture*) seperti pola bintik kecil pada kulit pisang yang menjadi pembeda utama antara `ripe` dan `overripe`.
  3. **Ketidakseimbangan Support Vectors & Potensi Overlap Dataset:** Kelas `overripe` hanya memiliki `1.200` *support vectors*, lebih sedikit dibandingkan `ripe` (`1.775`) dan `rotten` (`1.599`). Jika di dataset latih masih terdapat foto pisang berbintik di folder `ripe` atau `rotten`, batas keputusan `overripe` akan tertekan.

#### 2. Misklasifikasi Pisang Tunggal Cokelat Gelap sebagai `Matang` pada Sampel #10 & #11
- **Fakta Pengujian:** Pisang tunggal dengan kulit cokelat gelap menyeluruh (#10 dan #11) malah diprediksi sebagai **`Matang`** (`49.1%` dan `54.9%`), mengalahkan **`Busuk`** (`46.4%` dan `40.9%`), sementara `Matang Banget` hanya mendapat `3.4%`.
- **Akar Masalah Teknis:**
  1. **Dominasi Fitur Bentuk CNN:** Karena bentuk pisang tunggal pada #10 dan #11 masih utuh, melengkung rapi, dan bersih di latar putih, fitur bentuk dari `MobileNetV3Small` (`576` dims → `60` PCA) cenderung dekat dengan *support vectors* kelas `ripe`.
  2. **Kegagalan Sinyal Warna Memenangkan Kelas `rotten`:** Meskipun warna kulit sudah cokelat gelap, probabilitas gabungan dari SVM hanya membagi skor antara `ripe` dan `rotten` di angka ~45–55%.
  3. **Kalibrasi Warna di Flutter Tidak Ikut Campur:** Fungsi `_applyOverripeYellowCalibration` di `OnDeviceSvmClassifier` mensyaratkan `pigment.yellowRatio >= 0.50`. Karena #10 dan #11 dominan cokelat gelap (bukan kuning cerah), kalibrasi tidak aktif — artinya angka ~49%–55% `Matang` tersebut **100% merupakan keluaran matematis murni dari model SVM baru**.

#### 3. Verifikasi Paritas Matematika Flutter (Menjamin Bukan Bug Kode)
- Audit terhadap `lib/services/on_device_svm_classifier.dart` dan `tool/pack_svm_model.py` memastikan:
  - Dimensi PCA dibaca dinamis dari metadata/ukuran tensor (`34.560 / 576 = 60`), sehingga `totalDim = 90`.
  - Seluruh tensor (`542.547` float32 = `2.170.188` bytes) cocok terhadap nilai min/max pada `svm_pipeline_params.json`.
  - Rumus LIBSVM *one-vs-one* (`6` pasangan kelas untuk `4` kelas), Platt sigmoid (`fApB`), dan solver iteratif Wu, Lin & Weng (2004) berjalan konsisten tanpa bug aritmatika.

---

### B. Temuan pada Pra-Validasi & Stage-1 Gate (Jalur A)

#### 1. False Rejection pada Pisang Busuk Latar Lantai + Watermark (Sampel #6)
- **Fakta Pengujian:** Foto 3 pisang busuk cokelat kehitaman di atas lantai keramik dengan bar hitam watermark di bawahnya ditolak sebagai `"Buah tidak dikenali"` (`ScanUncertain`).
- **Akar Masalah Teknis:**
  - Berbeda dengan sampel #9 (pisang busuk di atas latar putih bersih yang lolos dengan `97%`), pisang yang hampir seluruhnya cokelat gelap di atas latar bertekstur + watermark sering kali:
    1. Tidak memunculkan label `banana` di Google ML Kit (hanya terdeteksi label umum atau objek ruangan/meja).
    2. Mendapat skor kelas `#954 (banana)` yang terlalu rendah di **Stage-1 ImageNet Banana Gate** (di bawah `minDirectBananaProbability = 0.08` atau gagal syarat top-5 `minTopRankBananaProbability = 0.03` & `minTopRankRelativeRatio = 0.25`) karena ImageNet sangat mengandalkan warna kuning khas pisang saat latar tidak bersih.

#### 2. Status Penolakan Buah Non-Pisang
- Sampel #12 (**Mangga**) berhasil ditolak (`Buah tidak dikenali`).
- *(Catatan lintasan uji sebelumnya: buah dengan daging kuning-hijau seperti belahan alpukat masih berpotensi lolos apabila ML Kit hanya mengeluarkan label generik `Food`/`Produce`/`Fruit` tanpa label spesifik `Avocado` dan kebetulan lolos skor Stage-1 Banana Gate).*

---

### C. Temuan pada Sinkronisasi UI & Gating Resep (Jalur A) — **SUDAH DIPERBAIKI ✅**

- **Fakta Pengujian (Sampel #5):**
  - Kartu hasil utama atas menampilkan **`Matang (64%)`**.
  - Namun kartu **`Ide Olahan Pisang`** di bawah menampilkan chip **`Matang Banget`**.
- **Akar Masalah (`lib/core/constants/ripeness_recipe_config.dart`):**
  - Logika `resolveRipeBucket()` masih menggunakan aturan fallback era **model 3-kelas** (ketika kelas `overripe` belum tersedia di model):
    - Jika `rottenProb >= 0.15`, atau `ripenessConfidence < 0.75 && unripeProb < 0.10`, hasil `ripe` otomatis digeser menjadi `RipenessBucket.veryRipe` (`Matang Banget`).
  - Pada sampel #5 (`ripe = 64.2% < 75%`, `unripe = 0.3% < 10%`), aturan lama tersebut menimpa keputusan model 4-kelas yang secara sadar memilih `ripe` (`64.2%`) di atas `overripe` (`21.3%`).
- **Perbaikan yang Sudah Diterapkan:**
  - Menambahkan guard di `RipenessRecipeConfig.resolveRipeBucket()`: apabila `classProbabilities` sudah memiliki kunci `'overripe'` (menandakan output model 4-kelas native), keputusan `ripe` dipertahankan sebagai `RipenessBucket.ripe`, dan hanya `overripe` yang masuk ke `RipenessBucket.veryRipe`.
  - Menambahkan 2 unit test baru di `test/services/recipe_gating_service_test.dart` (`11/11` test lulus, `flutter analyze` 0 issues).

---

## 4. Rekomendasi Tindak Lanjut

### Untuk Jalur B (Tim Model & Visi Komputer)
1. **Audit Confusion Matrix Kelas `overripe`:** Evaluasi precision & recall per kelas di Python untuk mengetahui seberapa besar kebocoran prediksi `overripe` ke `ripe` dan `rotten`.
2. **Kurasi Ulang Dataset `overripe` vs `ripe` / `rotten`:** Pastikan foto pisang kuning berbintik cokelat (*sugar spots*) tidak bercampur di folder `ripe` maupun `rotten`.
3. **Evaluasi Kembali Jumlah Komponen PCA:** Bandingkan akurasi validasi silang antara `PCA = 60` dan `PCA = 100` (atau `120`) untuk memastikan detail tekstur bintik halus tidak hilang akibat reduksi dimensi.
4. **Perbanyak Sampel Pisang Tunggal Cokelat Gelap pada Kelas `rotten`:** Untuk mengatasi kasus #10 dan #11 di mana bentuk buah utuh mengecoh model ke kelas `ripe`.

### Untuk Jalur A (Tim Aplikasi Flutter)
1. **Lanjutkan Tahap 4 & 5:** Jalankan verifikasi penuh `flutter test` untuk seluruh suite aplikasi, perbarui `CHANGELOG.md`, dan build APK rilis terbaru dengan perbaikan sinkronisasi `RipenessRecipeConfig`.
2. **Evaluasi Lanjutan Filter Non-Pisang & Banana Gate (Opsional Iterasi Berikutnya):**
   - Pertimbangkan pengetatan `MlKitFruitValidator` agar hanya menerima gambar dengan label `banana`/`plantain` (menutup celah alpukat/buah lain).
   - Evaluasi apakah Stage-1 Banana Gate perlu melonggarkan sedikit syarat untuk pisang busuk berlatar non-putih apabila label ML Kit sudah mengonfirmasi objek buah.
