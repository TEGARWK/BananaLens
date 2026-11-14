# Laporan Analisis Teknis: Mengapa Pisang Mentah (`unripe`) Sering Terdeteksi sebagai Matang (`ripe`) & Rekomendasi Solusi

**Tanggal:** 13 November 2026  
**Model yang Dianalisis:** `baca/svm_pisang_3kelas(96%).pkl`  
**Backend Inferensi:** `backend/main.py` (Hybrid MobileNetV3Small + HSV + PCA + SVM)

---

## 1. Ringkasan Masalah
Saat dilakukan pengujian langsung pada model visi komputer FruitLens:
- Pisang **Matang (`ripe`)** dan **Busuk (`rotten`)** mayoritas terprediksi **benar**.
- Pisang **Mentah (`unripe` / hijau)** hampir selalu terprediksi sebagai **Matang (`ripe`)** (atau sesekali `rotten` jika latar belakangnya gelap/berwarna).

Masalah ini **bukan disebabkan oleh bug pada aplikasi Flutter maupun preprocessing di `backend/main.py`**, melainkan berakar pada **komposisi fitur, parameter model SVM, distribusi data latih, dan tidak adanya pemisahan latar belakang (*background segmentation*)**.

---

## 2. Bedah Teknis: Parameter Aktual Model

Hasil inspeksi langsung terhadap bundel model `baca/svm_pisang_3kelas(96%).pkl`:

| Komponen | Nilai / Konfigurasi Aktual |
|---|---|
| **Pipeline** | `StandardScaler` ➔ `PCA (n_components=100)` ➔ `SVC` |
| **Varians PCA Tersisa** | `81.52%` dari total 606 fitur |
| **Kelas Target** | `['ripe', 'rotten', 'unripe']` |
| **Kernel & Parameter SVC** | `kernel='rbf'`, `C=0.03`, `gamma='scale'`, `class_weight='balanced'` |
| **Jumlah Support Vectors (`n_support_`)** | • `rotten` (Busuk): **1.947**<br>• `ripe` (Matang): **1.835**<br>• `unripe` (Mentah): **670** *(hanya ~35% dari kelas lain)* |

---

## 3. Penjelasan Detail Akar Masalah (5 Faktor Utama)

### Faktor 1: Dominasi Fitur Bentuk CNN (95%) atas Fitur Warna HSV (5%)
Di `backend/main.py`, setiap gambar `224×224` diubah menjadi vektor gabungan **606 dimensi**:
- **576 dimensi (~95%)** berasal dari `MobileNetV3Small` (`weights="imagenet"`, `pooling="avg"`).
- **30 dimensi (~5%)** berasal dari histogram dan momen warna `HSV` (12 bin Hue, 6 bin Saturation, 6 bin Value, 3 mean, 3 std).

**Mengapa ini merugikan kelas Mentah?**
1. `MobileNetV3Small` bawaan ImageNet dilatih untuk mengenali **bentuk, garis tepi, dan tekstur objek**, bukan gradasi kematangan buah.
2. Secara visual, **pisang mentah dan pisang matang memiliki bentuk & tekstur kulit yang hampir identik** (sama-sama lonjong, berkulit mulus, tanpa bercak gelap/keriput seperti pisang busuk).
3. Sebaliknya, pisang **busuk (`rotten`)** memiliki tekstur bercak cokelat/hitam yang sangat kontras, sehingga fitur CNN-nya langsung berbeda jauh dari `ripe` dan `unripe`.
4. Ketika 606 fitur tersebut dinormalisasi dengan `StandardScaler` lalu dipadatkan oleh `PCA(100 komponen)`, **sinyal warna hijau dari 30 fitur HSV kalah dominan dan tereduksi** oleh 576 fitur bentuk yang mirip antara mentah dan matang. Akibatnya, di mata SVM, fitur pisang mentah sangat berdekatan dengan pisang matang.

---

### Faktor 2: Ketimpangan *Support Vectors* (`670` vs `1.835` & `1.947`)
Meskipun saat pelatihan sudah menggunakan `class_weight='balanced'`, distribusi *support vectors* di dalam model menunjukkan ketimpangan yang sangat besar:
- `rotten`: **1.947** *support vectors*
- `ripe`: **1.835** *support vectors*
- `unripe`: **670** *support vectors*

**Dampak:**  
Variasi contoh pisang mentah yang membentuk batas keputusan (*decision boundary*) jauh lebih sedikit dan sempit. Wilayah keputusan kelas `unripe` menjadi seperti **"pulau kecil"** di dalam ruang 100-dimensi PCA yang dikelilingi wilayah `ripe` dan `rotten` yang hampir 3× lebih luas. Begitu foto uji dari kamera asli memiliki sedikit perbedaan pencahayaan, sudut, atau warna hijau yang agak pucat, titik fiturnya langsung keluar dari pulau `unripe` dan jatuh ke wilayah `ripe`.

---

### Faktor 3: Nilai Regularisasi `C = 0.03` Terlalu Lunak (*Underfitting* pada Kelas Minoritas)
Model menggunakan `SVC(C=0.03, kernel='rbf')`.
- Dalam algoritma SVM, parameter `C` mengontrol seberapa keras model menghukum kesalahan klasifikasi pada data latih.
- Nilai **`C = 0.03` sangat kecil** (*very soft margin*). Ini membuat batas pemisah antar kelas menjadi sangat lebar, tumpul, dan mengalah pada area tumpang tindih (*overlap*) antara hijau-kekuningan (`unripe`) dan kuning-kehijauan (`ripe`).
- Ketika dua kelas saling bertumpuk di ruang fitur, margin yang terlalu lunak cenderung memilih kelas dengan kepadatan dan variasi sampel lebih besar — yaitu `ripe`.

---

### Faktor 4: *Background Bias* (Latar Belakang Ikut Dihitung ke dalam Fitur)
Pipeline saat ini mengekstrak fitur CNN dan histogram HSV dari **seluruh frame gambar `224×224` tanpa segmentasi objek**:
- Jika foto pisang hijau diambil dengan latar belakang **meja kayu, dinding krem, kain/lantai hangat, atau di bawah lampu ruangan kekuningan**, maka piksel warna kuning/hangat dari latar belakang masuk ke histogram `Hue` dan nilai `mean_hsv`.
- Campuran piksel hijau pisang + piksel hangat/kuning/krem latar belakang menggeser rata-rata warna menuju spektrum **kuning (`ripe`)** atau **cokelat (`rotten`)**.

---

### Faktor 5: *Domain Shift* & Ilusi Akurasi `96%`
Label `96%` pada nama file `svm_pisang_3kelas(96%).pkl` merupakan skor validasi pada **dataset latih yang homogen** (kemungkinan besar memiliki pencahayaan studio atau latar seragam, atau foto yang mirip antara set *train* dan *test*).  
Saat berhadapan dengan foto dunia nyata (*in-the-wild*) dari kamera HP/emulator dengan *white balance*, bayangan, dan latar berbeda, terjadi *domain shift* yang paling parah memukul kelas dengan variasi sampel paling sedikit (`unripe`).

*(Catatan minor: model di-pickle menggunakan `scikit-learn 1.6.1`, sedangkan environment backend saat ini menjalankan `1.9.1`. Ini tidak menyebabkan error langsung, namun versi library sebaiknya diselaraskan saat retraining ulang.)*

---

## 4. Rekomendasi Solusi (Bertahap dari Tercepat hingga Fundamental)

### A. Solusi Jangka Pendek (Tanpa *Retraining* Model — Untuk Pengujian & Demo)
Jika model belum bisa dilatih ulang dalam waktu dekat, akurasi deteksi pisang mentah dapat ditingkatkan saat pengambilan foto:
1. **Gunakan Latar Belakang Putih Polos / Kontras Dingin:** Hindari meja kayu, lantai krem, atau terpal berwarna hangat.
2. **Penuhi Frame dengan Objek Pisang (>70% area foto):** Dekatkan kamera agar porsi latar belakang yang masuk ke perhitungan HSV seminimal mungkin.
3. **Pencahayaan Putih Netral:** Hindari lampu kuning (*warm white*) karena langsung menggeser nilai *Hue* hijau menjadi kuning (`ripe`).

---

### B. Solusi Jangka Menengah (Perbaikan Pipeline Training SVM — Paling Efektif untuk Jalur ML)

1. **Pisahkan PCA Fitur CNN dan Jaga Bobot Fitur Warna HSV**
   Jangan menggabungkan 576 fitur CNN + 30 fitur HSV lalu langsung di-PCA bersamaan.
   - Reduksi 576 fitur CNN dengan PCA menjadi misal **30–50 komponen** saja.
   - Baru gabungkan dengan **30 fitur warna HSV** (yang diberi bobot setara atau lebih tinggi, misal dikalikan faktor `1.5`–`2.0`), lalu latih SVM.
   - Dengan cara ini, komposisi informasi berubah dari **95% bentuk : 5% warna** menjadi **~50% bentuk : 50% warna**, sehingga warna hijau pisang mentah tidak lagi tenggelam.

2. **Perbanyak & Seimbangkan Data Latih `unripe` di Lingkungan Nyata**
   - Tambahkan foto pisang hijau dengan berbagai variasi: hijau tua, hijau muda, hijau kekuningan, pencahayaan indoor/outdoor, serta latar belakang alami (meja, tangan, lantai).
   - Pastikan jumlah gambar `unripe`, `ripe`, dan `rotten` seimbang (masing-masing minimal ~1.000–1.500 gambar setelah augmentasi) serta pastikan tidak ada *data leakage* (foto dari sesi/tandan yang sama tidak boleh terpecah ke *train* dan *test*).

3. **Tuning Hyperparameter SVM (`C` dan `gamma`) dengan Metrik *Macro F1-Score***
   - Lakukan `GridSearchCV` pada `C: [0.1, 1, 5, 10, 50]` dan `gamma: ['scale', 0.01, 0.001]`.
   - Jangan hanya mengejar akurasi rata-rata (*accuracy*), tetapi evaluasi **Confusion Matrix** dan pastikan **Recall kelas `unripe` ≥ 90%**.

4. **Tambahkan *Center-Crop* atau Penekanan Area Tengah pada Ekstraksi Warna**
   - Saat menghitung `extract_color_features`, fokuskan perhitungan histogram HSV pada area tengah gambar (misal 60%–70% area tengah tempat buah berada di bingkai kamera) agar pinggiran latar belakang tidak mendominasi warna. *(Harus diterapkan identik saat training maupun di `backend/main.py`.)*

---

### C. Solusi Jangka Panjang (Arsitektur Produksi Ideal)
1. **Fine-Tuning Model CNN Secara Langsung (*End-to-End*):**  
   Latih lapisan atas *MobileNetV3Small* / *EfficientNet-B0* langsung pada dataset kematangan pisang dan ekspor ke format `.tflite` agar bisa berjalan *offline* langsung di Flutter tanpa bergantung pada server Python.
2. **Penambahan Tahap Segmentasi / *Background Removal* Ringan:**  
   Pisahkan piksel pisang dari latar belakang (misal menggunakan *masking* atau model deteksi objek ringan) sebelum menghitung warna dan tekstur kematangan.

---

## 5. Kesimpulan
Pisang mentah (`unripe`) selalu terbaca matang (`ripe`) karena **fitur bentuk CNN (576 dimensi) mendominasi fitur warna HSV (30 dimensi)**, sementara secara bentuk pisang mentah dan matang sangat mirip. Masalah ini diperparah oleh **jumlah *support vector* `unripe` yang hampir 3× lebih sedikit (`670` vs `1.835`)**, **margin lunak `C=0.03`**, serta **bias latar belakang** yang ikut terbaca ke dalam fitur global. Perbaikan paling berdampak bagi tim ML adalah **menyeimbangkan dataset `unripe` berlatar alami**, **memisahkan PCA CNN agar fitur warna HSV tidak tenggelam**, dan **menaikkan nilai `C` melalui *tuning* berbasis *Macro F1-Score***.

