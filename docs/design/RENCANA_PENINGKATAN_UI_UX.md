# RENCANA PENINGKATAN UI/UX FRUITLENS (PROFESSIONAL POLISHING)

Dokumen ini mencatat daftar tugas penyempurnaan UI & UX aplikasi Flutter **FruitLens** berdasarkan hasil evaluasi penggunaan di perangkat fisik. Perbaikan difokuskan pada peningkatan kegunaan (*usability*), hierarki visual (*visual hierarchy*), dan kejelasan informasi (*information clarity*) tanpa mengubah logika bisnis inti.

---

## 1. Daftar Pekerjaan (Task Breakdown)

### Prioritas 1: High Usability & Quick Wins (Kritis)
- [x] **T-UX-01 (Label Akurasi di ResultScreen):**
  - **Masalah:** Angka `98% Keyakinan AI` di header buah bertabrakan makna dengan persentase kematangan SVM di bawahnya (`96.5%` atau `94.8%`).
  - **Perbaikan:** 
    - Ubah header menjadi menampilkan persentase kematangan utama secara sinkron (misal: jika kematangan Matang 96.5%, tampilkan `97% Keyakinan Kematangan`).
    - Beri label pembeda yang jelas untuk akurasi jenis buah (`Pisang: 98%`) dan akurasi kematangan (`Matang: 97%`).
  - **File:** `lib/ui/screens/result_screen.dart`

- [x] **T-UX-02 (Lokalisasi & Format Waktu di Riwayat):**
  - **Masalah:** Judul item riwayat tertulis huruf kapital kaku `BANANA`, dan format waktu menggunakan tanggal kaku `10/11/2026`.
  - **Perbaikan:**
    - Terjemahkan label buah ke Bahasa Indonesia ramah: `Pisang` (Title Case).
    - Tampilkan waktu relatif yang manusiawi (misal: *"Hari ini, 23.54"*, *"Kemarin, 14.20"*, atau *"2 hari lalu"*).
    - Tampilkan persentase kematangan spesifik di subtitle, bukan angka statis `98%`.
  - **File:** `lib/ui/screens/history_screen.dart`

---

### Prioritas 2: Smart Contextual UX (Nilai Tambah Logika)
- [x] **T-UX-03 (Tombol Aksi Cerdas / Contextual Recipe Action):**
  - **Masalah:** Jika buah terdeteksi **Busuk (Rotten)**, tombol *"Ide Resep"* tetap aktif, padahal buah busuk tidak layak dikonsumsi.
  - **Perbaikan:**
    - Jika buah **Matang / Terlalu Matang**: Tombol *"Ide Resep"* aktif menampilkan resep olahan (Banana Bread, Smoothie, dll).
    - Jika buah **Busuk**: Ganti tombol *"Ide Resep"* dengan tombol *"Panduan Kompos / Daur Ulang"* yang membuka tips pengolahan limbah organik di modal pop-up, atau nonaktifkan dengan label edukatif.
  - **File:** `lib/ui/screens/result_screen.dart`

- [x] **T-UX-04 (Pencegahan Salah Hapus / Safe Interaction di Riwayat):**
  - **Masalah:** Ikon Favorit (Bintang) dan Ikon Hapus (Tempat Sampah) berada sangat berdekatan di sisi kanan kartu (*fat finger issue*).
  - **Perbaikan:**
    - Tambahkan konfirmasi dialog cepat sebelum menghapus, atau gunakan gestur *Swipe-to-Dismiss* (geser ke kiri untuk hapus) agar tidak mudah tertekan secara tidak sengaja saat ingin menekan bintang favorit.
  - **File:** `lib/ui/screens/history_screen.dart`

---

### Prioritas 3: Micro-Interactions & "Juice" (Estetika & Rasa Halus)
- [x] **T-UX-05 (Animasi Pengisian Bar Probabilitas 4 Kelas):**
  - **Masalah:** Progress bar SVM langsung muncul kaku di angka target.
  - **Perbaikan:**
    - Tambahkan `TweenAnimationBuilder` (durasi 600ms, kurva `Curves.easeOutCubic`) sehingga progress bar bergerak mengisi secara mulus dari 0% ke persentase aktual saat layar Hasil Pindai terbuka.
  - **File:** `lib/ui/screens/result_screen.dart`

- [x] **T-UX-06 (Feedback Haptic Lembut):**
  - **Masalah:** Tidak ada feedback fisik ketika foto berhasil diproses.
  - **Perbaikan:**
    - Tambahkan `HapticFeedback.lightImpact()` saat hasil scan berhasil diterima dan layar berpindah ke hasil.
  - **File:** `lib/providers/scan_notifier.dart` atau `lib/ui/screens/scan_screen.dart`

---

## 2. File yang Disentuh

1. `lib/ui/screens/result_screen.dart`
2. `lib/ui/screens/history_screen.dart`
3. `lib/ui/screens/scan_screen.dart`
4. `lib/core/constants/app_strings.dart`
5. `test/ui/result_screen_test.dart` & `test/ui/history_screen_test.dart`

---

## 3. Rencana Verifikasi

1. **Analisis Statis:** `flutter analyze --no-pub` wajib 0 error / 0 warning.
2. **Format Kode:** `dart format .` dijalankan sebelum pelaporan.
3. **Pengujian Otomatis:** `flutter test` seluruh test (39+ unit & widget test) wajib lulus 100%.
4. **Verifikasi Visual:** Memastikan tampilan di mode gelap (*Night Harvest*) dan terang (*Fresh Harvest*) tetap harmonis tanpa teks overflow.

