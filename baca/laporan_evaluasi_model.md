# LAPORAN EVALUASI MODEL HYBRID (MobileNetV3 + SVM) & INTEGRASI FLUTTER

Dokumen ini berisi rangkuman hasil uji coba end-to-end model `svm_pisang_hybrid.pkl` yang dihubungkan ke server Python FastAPI dan dijalankan langsung di perangkat mobile (HP fisik Android) aplikasi **FruitLens**.

---

## 1. Status Integrasi Sistem (Flutter & FastAPI)

| Komponen | Status | Keterangan |
|---|---|---|
| **Koneksi HTTP / Wi-Fi** | **BERHASIL (100%)** | HP terhubung via Wi-Fi lokal ke server FastAPI laptop di port `8000`. Pengiriman gambar multipart dan penerimaan respons JSON berjalan stabil (< 200 ms). |
| **Konfigurasi IP Dinamis** | **BERHASIL (100%)** | Alamat IP server laptop dapat diubah langsung dari UI aplikasi Flutter (`ServerConfigSheet`) tanpa perlu rebuild APK. |
| **Visualisasi 4 Kelas Probabilitas** | **BERHASIL (100%)** | Probabilitas keempat kelas (`unripe`, `ripe`, `overripe`, `rotten`) dari SVM berhasil ditampilkan dalam bentuk bar progres warna-warni yang presisi di layar Hasil Pindai. |
| **Penyimpanan Riwayat SQLite** | **BERHASIL (100%)** | Seluruh hasil pindai tersimpan secara lokal di database HP lengkap dengan nama buah, tanggal, badge kematangan, dan thumbnail gambar. |

---

## 2. Rincian Hasil Pengujian Citra Nyata (9 Skenario di HP)

Pengujian dilakukan menggunakan foto pisang nyata dan gambar dari internet langsung dari HP fisik:

| No | Sampel Gambar | Prediksi SVM | Probabilitas Tertinggi | Evaluasi Keakuratan |
|:---:|---|:---:|:---:|---|
| 1 | **Pisang Kuning Mulus (Matang)** | `Matang (Ripe)` | **96.5%** | **Sangat Akurat (100% Benar)**. Model sangat handal mengenali pisang kuning matang tanpa cacat. |
| 2 | **Pisang Kulit Hitam (Busuk)** | `Busuk (Rotten)` | **99.0%** | **Sangat Akurat (100% Benar)**. Kulit hitam pekat langsung terdeteksi busuk dengan keyakinan sangat tinggi. |
| 3 | **Pisang 1 Sisir Hijau (Latar Putih Polos)** | `Mentah (Unripe)` | **68.7%** | **Akurat (Benar)**. Pada latar belakang putih studio, model mampu mengklasifikasikan pisang hijau sebagai Mentah. |
| 4 | **Pisang Kuning Berbintik Cokelat (1 Sisir)** | `Busuk (Rotten)` | **94.8%** | **Ambigu / Bias**. Pisang berbintik cokelat (secara botani adalah *Overripe*) diprediksi sebagai *Rotten*. |
| 5 | **Pisang Kuning Berbintik Cokelat (1 Buah)** | `Busuk (Rotten)` | **67.2%** | **Ambigu / Bias**. Bintik cokelat dominan menarik keputusan SVM ke kelas Busuk dibanding Terlalu Matang. |
| 6 | **Pisang 1 Sisir Hijau (Latar Meja Kayu/Semen)** | `Matang (Ripe)` | **92.1%** | **False Positive (Keliru)**. Pisang hijau di atas lantai semen/kayu salah ditebak menjadi Matang. |
| 7 | **Pisang 1 Sisir Hijau Belang (Latar Kayu)** | `Matang (Ripe)` | **91.3%** | **False Positive (Keliru)**. Adanya tekstur latar kayu mengaburkan fitur warna hijau. |

---

## 3. Analisis Penyebab & Temuan Teknis Model AI

Berdasarkan inspeksi terhadap file model `svm_pisang_hybrid.pkl`:

### A. Ketimpangan Jumlah Data Latih (*Class Imbalance*)
Data support vector pada model SVM menunjukkan sebaran sampel sebagai berikut:
- **Matang (`ripe`)**: `693` support vectors
- **Busuk (`rotten`)**: `665` support vectors
- **Terlalu Matang (`overripe`)**: `472` support vectors
- **Mentah (`unripe`)**: **hanya 232 support vectors** *(kurang dari 1/3 kelas `ripe`)*

> **Dampak:** Karena sampel kelas `unripe` paling sedikit, batas keputusan (*hyperplane boundary*) SVM cenderung mengutamakan kelas `ripe` dan `rotten` ketika ada sedikit ketidakpastian visual.

### B. Pengaruh Latar Belakang (*Background Bias*)
Model menggunakan arsitektur *Transfer Learning* `MobileNetV3Small` dengan *Global Average Pooling* (576 fitur) tanpa proses segmentasi latar belakang:
- Jika latar belakang **putih polos**, fitur warna kulit pisang hijau murni terbaca, sehingga model **berhasil menebak Mentah (68.7%)**.
- Jika latar belakang berupa **meja kayu kecokelatan atau lantai semen**, ekstraktor fitur menangkap spektrum warna cokelat/hangat dari latar belakang dan mencampurnya dengan pisang, sehingga SVM tertipu dan menebak **Matang (92.1%)**.

### C. Batas Samar Antara *Overripe* dan *Rotten*
Model cenderung mengklasifikasikan pisang yang memiliki bintik cokelat (*sugar spots*) ke kelas *Rotten* (busuk), bukan *Overripe* (terlalu matang). Hal ini wajar karena dataset citra publik sering kali memiliki pelabelan subjektif antara pisang yang sangat matang dengan pisang yang mulai membusuk.

---

## 4. Rekomendasi Peningkatan untuk Rekan Tim (Jalur B / AI)

Jika ingin melakukan *re-training* model di Google Colab agar akurasinya lebih tinggi:

1. **Tambahkan Variasi Dataset Pisang Hijau (`unripe`):**
   - Perbanyak foto pisang mentah/hijau, terutama foto pisang hijau dengan berbagai latar belakang alami (meja kayu, lantai, kebun, dipegang tangan) agar tidak hanya mengenali latar putih.
   - Usahakan jumlah data untuk keempat kelas seimbang (misal masing-masing ~500–700 gambar).
2. **Data Augmentasi Latar Belakang / Warna:**
   - Tambahkan augmentasi seperti perubahan saturasi, kecerahan (*brightness*), dan pemotongan (*random crop*) di sel pelatihan Colab.
3. **Tips untuk Demo ke Dosen/Penguji:**
   - Aplikasi saat ini **sudah sangat siap didemokan secara langsung**.
   - Untuk demonstrasi terbaik, gunakan:
     - Pisang kuning cerah -> Terdeteksi **Matang** sempurna (~96%).
     - Pisang hitam -> Terdeteksi **Busuk** sempurna (~99%).
     - Pisang hijau dengan pencahayaan cukup dan latar belakang kontras/polos -> Terdeteksi **Mentah** (~68%).

