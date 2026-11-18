# Changelog — FruitLens

> Catatan seluruh pembaruan dan perbaikan proyek **FruitLens**.  
> **Aturan Wajib:** Setiap ada perubahan fitur, perbaikan bug, atau update kode/dokumentasi yang di-commit/push, wajib menambahkan entri terbaru di bagian paling atas file ini dengan format **Hari, Tanggal** diikuti ringkasan perubahan.

---

## Rabu, 18 November 2026

### Kalibrasi Kematangan Pisang (Post-Processing Warna)
- **Kalibrasi *Overripe* (pisang kuning berbintik *sugar spots*):** Menambahkan `_applyOverripeYellowCalibration` di `lib/services/on_device_svm_classifier.dart` agar pisang kuning bertotol cokelat (*yellowRatio >= 50%* dan minimal `1,6×` lebih dominan dari piksel cokelat/gelap) tetap terbaca **Matang** (`Matang Banget`), sementara pisang busuk cokelat/hitam merata tetap terbaca **Busuk** *(commit `e057c44`)*.
- **Peredaman *false-positive* `Busuk` pada pisang hijau sesisir:** Memperbarui `_applyChlorophyllCalibration` agar skor `rotten` akibat bayangan sela-sela pisang atau latar gelap pada pisang hijau (`greenRatio >= 35%` dan minimal `1,8×` lebih dominan dari piksel cokelat/gelap) diredam ke `unripe` *(commit `e057c44`)*.
- **Kalibrasi Pigmen Klorofil:** Menambahkan `PigmentRatios` dan `analyzePigmentRatios` di `lib/services/on_device_image_preprocessor.dart` (filter latar netral `S >= 28`, `V >= 20`, deteksi klorofil hijau `Hue 31..88` & `G > R + 5`) untuk memperbaiki pisang hijau mentah/kekuningan yang sebelumnya salah terbaca Matang *(commit `eb97203`)*.

### Fitur Resep AI, Keamanan Pangan & UX
- **Rekomendasi Resep AI & Gating Keamanan Pangan:** Menambahkan `GeminiRecipeService`, `RecipeGatingService`, dan layar `ScanRecipesScreen` (`/scan-recipes`) dengan gating deterministik pasca-scan (0 panggilan AI sebelum tombol ditekan: `Busuk` → peringatan buang, `Mentah` → estimasi hari tunggu matang, `Matang`/`Matang Banget` → tombol Rekomendasi Resep) *(commit `eb97203`)*.
- **Pilihan Selera Resep & Cadangan Lokal:** Menambahkan 6 chip selera (`Semua`, `Makanan`, `Minuman`, `Manis`, `Gurih`, `Praktis`), penanda badge `AI`, *skeleton loading* (`ShimmerBox`), fallback model saat error `503`/`429`, dan cadangan 12 resep lokal (`assets/data/recipes.json`) *(commit `eb97203`)*.
- **Penyederhanaan UX & Pengaturan Akun:** Menyederhanakan teks error/label agar ramah pengguna awam serta menambahkan layar `AccountSettingsScreen` (`/account-settings`) *(commit `eb97203`)*.

### Dokumentasi, Laporan Testing & Pengujian
- **Folder Laporan Testing:** Menambahkan `hasil_testing/LAPORAN_TESTING_MOBILE.md` beserta 12 screenshot uji di `hasil_testing/screenshots/` *(commit `eb97203`)*.
- **Tambalan Proposal PM2:** Menambahkan `proposal-pm2-update-terbaru.md` untuk pembaruan laporan proposal *(commit `eb97203`)*.
- **Verifikasi:** `flutter analyze` bersih (`No issues found!`) dan `104 / 104` automated tests lulus *(termasuk test baru di `test/services/on_device_scan_service_test.dart`)*.

---

## Sabtu, 14 November 2026

- **Inisialisasi & Integrasi Awal FruitLens:** Setup aplikasi Flutter (Riverpod, GoRouter, tema *Fresh/Night Harvest*), pipeline *on-device* (`Google ML Kit` + `TFLite MobileNetV3Small` + `Masked HSV` + `PCA` + `RBF SVM`), database SQLite *offline-first*, Firebase Auth & Cloud Firestore Sync, serta Asisten Chat Gemini AI (`GeminiChatService`) *(commit `4c35526`)*.
