# Changelog — FruitLens

> Catatan seluruh pembaruan dan perbaikan proyek **FruitLens**.  
> **Aturan Wajib:** Setiap ada perubahan fitur, perbaikan bug, atau update kode/dokumentasi yang di-commit/push, wajib menambahkan entri terbaru di bagian paling atas file ini dengan format **Hari, Tanggal** diikuti ringkasan perubahan.

---

## Kamis, 19 November 2026

### Ilustrasi Onboarding Baru (Tema BananaLens)
- **Pembaruan 3 aset ilustrasi onboarding:** Mengganti `assets/images/onboarding/slide_scan.png`, `slide_nutrition.png`, dan `slide_assistant.png` (1024×1024 PNG transparan) agar selaras dengan gaya **BananaLens — Layered Tactile Industrial Minimalism** (*Banana Volt Yellow* `#F5D51E`, outline arang `#181A16`, *hard offset depth*) dan fokus khusus ke komoditas pisang (tanpa buah lain).
- **Layout & Teks Onboarding:** Menghapus kotak `IndustrialSpecimenCard` di belakang ilustrasi pada `onboarding_slide_content.dart` agar gambar tampil lepas lebih besar (`340×330`), serta memperbarui teks pada `onboarding_screen.dart` agar fokus ke buah pisang (Mentah, Matang, Busuk), gizi/alergi, dan resep sesuai selera.
- **Ilustrasi & Header Auth (Masuk, Daftar, Lupa Sandi):** Membuat 3 ilustrasi baru bertema **BananaLens** (`assets/images/auth/auth_login.png`, `auth_register.png`, `auth_forgot.png`) serta mengganti kotak card header di `auth_widgets.dart` dan `forgot_password_screen.dart` dengan ilustrasi lepas berukuran proporsional.
- **Ikon Input Form (`app_text_field.dart`):** Menghapus kotak kuning pada `prefixIcon` form input agar ikon tampil bersih selaras dengan ikon kanan.
- **Ikon Launcher Aplikasi (`ic_launcher_banana_foreground.xml`, `mipmap-*/ic_launcher*.png`):** Menyesuaikan skala kotak ikon (`0.58×`) agar masuk ke dalam *safe zone* lingkaran Adaptive Icon Android sehingga tidak terpotong di launcher.
- **Native Splash Screen Android 12+ (`splash_banana_mark.xml`, `values/colors.xml`, `values-night/colors.xml`):** Mengubah latar splash native menjadi **Banana Volt Yellow** (`#F5D51E`) dan menampilkan logo kotak instrumen berbayangan hitam + pisang kuning skala aman (`0.58×`) persis seperti ikon aplikasi.
- **Resep 100% Fokus Pisang (`recipes.json`, `recipes_list_screen.dart`, `app_database.dart`):** Mengganti 6 resep non-pisang (Apel, Alpukat, Mangga, Semangka) di `assets/data/recipes.json` dengan 6 resep olahan pisang baru sehingga total 12 resep khusus pisang, mengubah filter `RecipesListScreen` ke tingkat kematangan & jenis olahan (`Semua`, `Mentah`, `Matang`, `Matang Banget`, `Makanan`, `Minuman`), serta menaikkan SQLite ke v5 agar tabel `recipes` ter-refresh otomatis.
- **3 Ikon Pisang Industrial (`assets/images/fruits/`, `fruit_vector_icon.dart`):** Menghapus ikon buah lain dan menggantinya dengan 3 ikon pisang bergaya **BananaLens** (`banana_unripe.png`, `banana_ripe.png`, `banana_rotten.png`), serta menyambungkan status kematangan di daftar resep, detail resep, beranda, dan riwayat scan.
- **Animasi Skeleton Loading (`shimmer_box.dart`):** Memperbaiki warna skeleton yang sebelumnya menyatu dengan warna kartu `#EBEDE3` dan mengganti efek pudar statis menjadi animasi kilau berjalan (*sliding shimmer gradient*) yang kontras di mode terang maupun gelap pada seluruh halaman.
- **Audit & Penyelarasan 100% Fokus Pisang (`BananaLens`):** Memperbarui seluruh tips harian (`home_today_tip_card.dart`), pengingat pintar (`home_smart_reminder_card.dart`), chip saran & prompt chat (`chat_screen.dart`, `gemini_chat_service.dart`), daftar alergi relevan olahan pisang (`account_preference_tiles.dart`, `auth_service.dart`, `profile_screen.dart`), serta teks kosong/loading di `recipes_list_screen.dart` dan `result_state_views.dart`.
- **Penolakan Buah Non-Pisang & OOD di Scanner (`ml_kit_fruit_detector.dart`, `on_device_image_preprocessor.dart`, `on_device_svm_classifier.dart`, `on_device_scan_service.dart`):** Memisahkan daftar `_otherFruitKeywords`, menolak objek non-buah dominan tanpa label pisang, menambahkan filter spektrum pigmen merah/oranye cerah/ungu (`nonBananaVividRatio >= 0.45`), serta mengaktifkan deteksi *out-of-distribution* berbasis jarak RBF kernel ke 6.162 support vector pisang (`maxKernelSimilarity < 0.54`) untuk menolak buah kuning/hijau non-pisang seperti alpukat, mangga, dan terong.
- **Pembaruan Dokumentasi (`README.md`):** Menyelaraskan seluruh isi `README.md` ke identitas baru **BananaLens** (fokus deteksi kematangan pisang, multi-layer penolakan non-pisang/OOD, 12 resep pisang, 3 ikon pisang industrial, status `109 / 109` tests, dan URL repo `BananaLens`).

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
- **Pembaruan `README.md`:** Menyelaraskan deskripsi fitur, arsitektur folder `lib/` & `backend/`, panduan instalasi/env, `104` automated tests, kalibrasi warna, gating resep AI, dan skenario demo terbaru.
- **Folder Laporan Testing:** Menambahkan `hasil_testing/LAPORAN_TESTING_MOBILE.md` beserta 12 screenshot uji di `hasil_testing/screenshots/` *(commit `eb97203`)*.
- **Tambalan Proposal PM2:** Menambahkan `proposal-pm2-update-terbaru.md` untuk pembaruan laporan proposal *(commit `eb97203`)*.
- **Verifikasi:** `flutter analyze` bersih (`No issues found!`) dan `104 / 104` automated tests lulus *(termasuk test baru di `test/services/on_device_scan_service_test.dart`)*.

---

## Sabtu, 14 November 2026

- **Inisialisasi & Integrasi Awal FruitLens:** Setup aplikasi Flutter (Riverpod, GoRouter, tema *Fresh/Night Harvest*), pipeline *on-device* (`Google ML Kit` + `TFLite MobileNetV3Small` + `Masked HSV` + `PCA` + `RBF SVM`), database SQLite *offline-first*, Firebase Auth & Cloud Firestore Sync, serta Asisten Chat Gemini AI (`GeminiChatService`) *(commit `4c35526`)*.
