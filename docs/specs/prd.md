# PRD: FruitLens (nama sementara)

| | |
|---|---|
| Versi | 1.0 (draf) |
| Jenis | Tugas besar: Pemrograman Mobile 2, Visi Komputer, AI |
| Platform | Android (Flutter) |
| Status | Perencanaan |

---

## 1. Latar Belakang

Banyak orang kesulitan menilai kematangan dan kesegaran buah, serta tidak tahu kandungan gizi dan cara mengolahnya. Informasi tersebut tersebar dan tidak kontekstual. Kemajuan visi komputer di perangkat mobile memungkinkan identifikasi buah langsung dari kamera.

## 2. Pernyataan Masalah

> Pengguna ingin cepat tahu **buah apa ini, apakah sudah matang, apa gizinya, dan mau dibuat apa**, tanpa mencari manual di banyak tempat.

## 3. Tujuan

### Tujuan produk
1. Mengidentifikasi jenis buah dari foto dengan akurasi tinggi
2. Menilai tingkat kematangan buah
3. Memberi informasi nutrisi dan saran yang relevan dengan kondisi pengguna
4. Menyediakan asisten AI untuk tanya jawab seputar buah

### Tujuan akademik
1. Mendemonstrasikan integrasi tiga mata kuliah dalam satu aplikasi utuh
2. Menghasilkan model terlatih yang dievaluasi secara terukur
3. Aplikasi stabil dan siap didemokan

### Metrik keberhasilan

| Metrik | Target |
|---|---|
| Akurasi jenis buah (data uji) | ≥ 90% |
| Akurasi kematangan (data uji) | ≥ 80% |
| Waktu hasil scan | ≤ 2 detik |
| Alur utama berjalan tanpa crash saat demo | 100% |
| Fitur Must selesai | 100% |

## 4. Target Pengguna

| Persona | Kebutuhan |
|---|---|
| **Ibu rumah tangga / pembeli di pasar** | Memilih buah matang, ide olahan |
| **Pelaku diet / pola hidup sehat** | Kalori dan nutrisi cepat, cocok tidaknya dengan tujuan |
| **Mahasiswa / pengguna umum** | Penasaran, belajar, ingin tahu cara simpan |
| **Dosen / penguji (konteks tugas)** | Melihat integrasi teknologi yang jelas |

## 5. Ruang Lingkup

### Dalam cakupan (MVP)
- Login/registrasi
- Scan kamera/galeri: jenis + kematangan
- Info nutrisi
- Chatbot AI
- Riwayat scan lokal
- Mode offline untuk scan

### Pengembangan lanjutan (jika waktu ada)
- Rekomendasi resep dan profil personal
- Favorit, sinkronisasi cloud
- Notifikasi pengingat
- Deteksi multi-buah dan live detection
- Dark mode

### Di luar cakupan
Pembayaran, e-commerce, diagnosis medis, iOS, pengenalan buah di luar daftar kelas.

---

## 6. User Stories

| ID | Sebagai | Saya ingin | Agar | Prioritas |
|---|---|---|---|---|
| US-01 | Pengguna | memotret buah | tahu jenis buahnya | Must |
| US-02 | Pengguna | tahu kematangan buah | tidak salah beli/makan | Must |
| US-03 | Pengguna | melihat nutrisi buah | mengatur asupan | Must |
| US-04 | Pengguna | bertanya ke chatbot | mendapat jawaban cepat | Must |
| US-05 | Pengguna | melihat riwayat scan | mengingat buah yang pernah dipindai | Must |
| US-06 | Pengguna | scan tanpa internet | tetap bisa dipakai di pasar | Must |
| US-07 | Pengguna | login | data saya terhubung ke akun | Should |
| US-08 | Pengguna | mengisi profil dan alergi | mendapat peringatan sesuai kondisi | Should |
| US-09 | Pengguna | mendapat saran resep | tahu cara mengolah buah | Should |
| US-10 | Pengguna | menyimpan favorit | cepat mengakses lagi | Should |
| US-11 | Pengguna | mendapat pengingat | buah tidak terbuang | Could |

---

## 7. Fitur dan Kriteria Penerimaan

### F1. Scan Buah
**Deskripsi:** Ambil foto atau pilih dari galeri, sistem memproses dan menampilkan hasil.

**Kriteria penerimaan:**
- Izin kamera diminta; jika ditolak, tampil penjelasan + tombol ke pengaturan
- Hasil menampilkan: foto, nama buah, kematangan, confidence (%)
- Confidence < 60% menampilkan pesan "Buah tidak dikenali, coba foto ulang"
- Proses ≤ 2 detik, ada indikator loading
- Berfungsi offline

### F2. Halaman Hasil dan Info Nutrisi
**Kriteria penerimaan:**
- Menampilkan kalori, karbo, gula, serat, vitamin per 100 g
- Menampilkan manfaat dan tips penyimpanan
- Tombol "Simpan ke favorit", "Tanya chatbot", "Lihat resep"
- Hasil otomatis masuk riwayat

### F3. Chatbot AI
**Kriteria penerimaan:**
- Input teks, balasan ditampilkan bergaya chat
- Jawaban dalam Bahasa Indonesia dan sesuai topik buah
- Tombol "Tanya tentang hasil scan" mengirim konteks (jenis + kematangan)
- Menangani error jaringan dengan pesan ramah dan opsi coba lagi
- Indikator "sedang mengetik"

### F4. Riwayat Scan
**Kriteria penerimaan:**
- Daftar diurutkan terbaru, menampilkan thumbnail, nama, kematangan, tanggal
- Ketuk item membuka detail
- Hapus satu item (dengan konfirmasi)
- Pencarian dan filter (Should)

### F5. Autentikasi dan Profil
**Kriteria penerimaan:**
- Registrasi, login, logout berfungsi; error validasi jelas
- Profil menyimpan usia, berat, tujuan, alergi
- Sesi tetap login setelah aplikasi ditutup

### F6. Rekomendasi Resep dan Personal (Should)
**Kriteria penerimaan:**
- Resep disesuaikan buah dan kematangan (mis. terlalu matang → smoothie/selai)
- Peringatan muncul jika buah masuk daftar alergi pengguna

### F7. Notifikasi dan Sinkronisasi (Could)
- Pengingat lokal untuk buah yang ditandai
- Riwayat disinkronkan ke Firestore saat online

---

## 8. Alur Pengguna Utama

```
Buka app → (Onboarding) → Login
        → Beranda
            ├─ Scan → Kamera/Galeri → Proses → Hasil
            │            ├─ Info nutrisi
            │            ├─ Resep
            │            ├─ Tanya chatbot
            │            └─ Simpan favorit (otomatis tersimpan ke Riwayat)
            ├─ Chatbot
            ├─ Riwayat → Detail → Hapus/Favorit
            └─ Profil → Edit data, Logout
```

## 9. Daftar Layar

| Layar | Isi utama |
|---|---|
| Splash + Onboarding | Logo, 3 slide pengantar |
| Login / Register | Form email-password, tombol Google |
| Beranda | Sapaan, tombol scan besar, tips harian, 3 riwayat terakhir |
| Scan | Preview kamera, tombol shutter, tombol galeri |
| Hasil Scan | Foto, label, kematangan, confidence, nutrisi, aksi |
| Resep | Daftar dan detail resep |
| Chatbot | Daftar pesan, input teks, chip saran pertanyaan |
| Riwayat | List + pencarian + filter |
| Detail Riwayat | Foto, hasil, waktu, hapus, favorit |
| Profil | Data diri, preferensi, tema, logout |

Navigasi: **bottom navigation** 5 tab: Beranda, Scan, Chatbot, Riwayat, Profil.

## 10. Panduan Desain

- Warna dominan hijau segar + aksen oranye; latar terang bersih
- Material 3, sudut membulat, kartu dengan bayangan lembut
- Tombol Scan menonjol (center FAB)
- Status kematangan memakai warna dan ikon: 🟢 mentah, 🟡 matang, 🟠 terlalu matang, 🔴 busuk (tidak hanya mengandalkan warna)
- Teks Bahasa Indonesia, ringkas dan ramah

---

## 11. Komponen AI/Visi Komputer

### Pipeline model
1. **Pengumpulan data:** Fruits-360 (jenis) + dataset/foto sendiri untuk kematangan
2. **Preprocessing:** resize 224×224, normalisasi, augmentasi (rotasi, flip, brightness)
3. **Pelatihan:** transfer learning MobileNetV2 di Google Colab
4. **Evaluasi:** akurasi, precision/recall, confusion matrix
5. **Konversi:** simpan sebagai `.tflite` (quantization untuk memperkecil ukuran)
6. **Integrasi:** muat model di aplikasi, jalankan inferensi di isolate agar UI tidak freeze

### Catatan penting
- Dataset Fruits-360 berlatar putih; tambahkan foto latar nyata agar model tahan di kondisi sebenarnya
- Dua model terpisah (jenis & kematangan) lebih mudah dilatih dibanding satu model gabungan
- Simpan `labels.txt` yang urutannya persis sama dengan output model

---

## 12. Rencana Pengerjaan (sesuaikan dengan tenggat)

| Fase | Pekerjaan | Pemilik (isi) |
|---|---|---|
| 1. Persiapan | Finalisasi kebutuhan, desain UI di Figma, setup repo | |
| 2. Model | Kumpulkan data, latih, evaluasi, ekspor TFLite | |
| 3. Inti aplikasi | Kamera, integrasi TFLite, layar hasil, data nutrisi | |
| 4. Fitur pendukung | Riwayat SQLite, login Firebase, profil | |
| 5. AI | Integrasi chatbot, resep | |
| 6. Polishing | Uji, perbaikan bug, optimasi, onboarding | |
| 7. Dokumentasi | Laporan, slide, video demo | |

## 13. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Akurasi turun di foto dunia nyata | Hasil salah | Tambah data latar nyata, augmentasi, ambang confidence |
| Dataset kematangan sulit dicari | Fitur inti tertunda | Kumpulkan foto sendiri, batasi ke 5–6 buah dulu |
| Model terlalu besar/lambat | UX buruk | Pakai MobileNet + quantization |
| Kuota/akses API chatbot habis | Chatbot mati saat demo | Siapkan pesan fallback, cache jawaban umum |
| Waktu tidak cukup | Fitur tidak selesai | Kerjakan berdasarkan prioritas Must dulu |
| Integrasi TFLite bermasalah di perangkat tertentu | Crash | Uji awal di perangkat fisik, bukan hanya emulator |

## 14. Pertanyaan Terbuka

- [ ] Framework final (Flutter / lainnya)?
- [ ] Daftar buah final (berapa kelas)?
- [ ] Model: klasifikasi saja atau object detection?
- [ ] Berapa anggota dan pembagian peran?
- [ ] Tenggat dan format penilaian dosen?

---

## 15. Instruksi untuk AI Coding Assistant (Vibe Coding)

Salin bagian ini sebagai konteks awal sesi:

```
Konteks: Saya membangun aplikasi Flutter "FruitLens" (pemindai buah). Baca
kebutuhan-sistem.md dan prd.md di repo sebagai sumber kebenaran.

Aturan kerja:
1. Kerjakan bertahap per fitur, urutan prioritas Must dulu.
2. Gunakan struktur folder pada kebutuhan-sistem.md bagian 9.
3. Satu state management saja (Riverpod) secara konsisten.
4. Jangan hardcode API key; baca dari .env.
5. Setiap fitur harus menangani: loading, error, dan state kosong.
6. Semua teks UI dalam Bahasa Indonesia.
7. Beri komentar singkat pada logika preprocessing dan inferensi model.
8. Setelah tiap tugas, jelaskan file apa saja yang diubah dan cara mengujinya.

Urutan pengerjaan yang diminta:
(a) setup proyek + tema + bottom navigation
(b) layar kamera/galeri
(c) integrasi TFLite + layar hasil
(d) data nutrisi lokal (JSON)
(e) riwayat SQLite
(f) chatbot Gemini
(g) auth Firebase + profil
(h) resep + personalisasi
(i) polishing dan pengujian
```
