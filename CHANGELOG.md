# Changelog — FruitLens

> Catatan seluruh pembaruan dan perbaikan proyek **FruitLens**.  
> **Aturan Wajib:** Setiap ada perubahan fitur, perbaikan bug, atau update kode/dokumentasi yang di-commit/push, wajib menambahkan entri terbaru di bagian paling atas file ini dengan format **Hari, Tanggal** diikuti ringkasan perubahan.

---

## Minggu, 22 November 2026

### Penyelarasan Model PCA 60 & Kalibrasi 4-Kelas Python (`baca/update`)
- **Pembaruan Aset Model (`assets/models/`):** Memasang `svm_pisang_meta.json`, `svm_pisang_weights.bin` (`1.595.820` bytes, PCA 60, `3.899` *support vectors*), dan `mobilenet_v3_extractor.tflite` dari `baca/update/`.
- **Penyelarasan Preprocessing & Rasio Pigmen (`on_device_image_preprocessor.dart`):** Menyamakan metode resize ke `Interpolation.linear` (BILINEAR) serta menyelaraskan mask aktif (`S >= 28`, `V >= 20`, `H <= 90`) dan definisi `greenRatio`, `yellowRatio`, `brownDarkRatio` agar identik dengan `calibrate_4class_probs` Python, sambil mempertahankan *non-banana vivid gate*.
- **Porting & Penyempurnaan `calibrate4ClassProbs` (`svm_post_processing.dart`, `on_device_svm_classifier.dart`):** Mengganti kalibrasi lama dengan logika 4-kelas (`unripe` untuk `greenRatio >= 0.25 && greenRatio > yellowRatio`, `rotten` untuk pembusukan dominan `brownRatio >= 0.58 && yellowRatio < 0.28` saat SVM ragu `ripe < 0.70 || rotten >= 0.20`, dan `overripe` hanya saat ada ambiguitas `rotten + overripe >= 0.20 || ripe < 0.70` dengan skor proporsional agar tidak terpaku di 88% serta tidak menimpa pisang `Matang` mulus di meja kayu/aspal).
- **Unit Test (`test/services/on_device_svm_classifier_test.dart`):** Memperbarui dan menambah verifikasi paritas `calibrate4ClassProbs` untuk kondisi `Mentah`, `Matang Banget`, `Matang`, dan `Busuk`.

### Upgrade UI/UX Halaman Detail Riwayat Pindai (`HistoryDetailScreen`)
- **Hero Card & Overlay Foto (`history_detail_hero_card.dart`):** Mengganti tag `SCAN // RECORD` menjadi `CATATAN // PINDAI`, memindahkan tombol `Perbesar` sebagai *overlay pill* di pojok kanan bawah foto, menambahkan isyarat ketuk `Ketuk untuk rincian` pada kotak akurasi, serta mendukung 4 kelas warna kematangan termasuk `Matang Banget`.
- **Blok Nutrisi Konsisten (`history_detail_screen.dart`):** Mengganti grid 2x2 nutrisi dengan banner kuning `89 kkal · Kalori | Per 100 g` dan 3 kartu makro (`Karbohidrat`, `Gula Alami`, `Serat Pangan`) selaras dengan halaman Hasil Pindai.
- **Panduan Sadar Kematangan (`history_detail_guidance_card.dart`):** Memperbaiki bug di mana tips penyimpanan `Matang` muncul pada pemindaian `Mentah`; kini `SARAN KONSUMSI` dan `DAYA SIMPAN` menyesuaikan kondisi `Mentah`, `Matang`, `Matang Banget`, dan `Busuk`.
- **Tombol Aksi 1 Baris & Sheet 4-Kelas (`history_detail_screen.dart`, `history_detail_sheets.dart`):** Merapikan tombol bawah menjadi 1 baris (`Resep` / `Daur Ulang` + `Tanya AI`), mendukung rincian skor 4 kelas pada bottom sheet, serta memodularisasi file dari 915 baris menjadi 4 file ringkas (`<= 235` baris/file).
- **Widget Test (`test/ui/history_screen_test.dart`):** Menambahkan verifikasi UI baru serta skenario panduan `Mentah` dan `Busuk` pada `HistoryDetailScreen`.

---

## Sabtu, 21 November 2026

### Integrasi Model SVM 4-Kelas (PCA 100) & Refactor Classifier Dinamis
- **Refaktor `OnDeviceSvmClassifier` bebas hardcode (`on_device_svm_classifier.dart`, `on_device_scan_service.dart`):** Menghapus seluruh konstanta dimensi tetap (`576`, `30`, `100`) sehingga `cnnDim`, `hsvDim`, `pcaDim`, dan `featureDim` dibaca dinamis langsung dari tensor model (`cnn_scaler_mean`, `hsv_scaler_mean`, `pca_components`).
- **Modularisasi & Validasi Tensor (`svm_prediction.dart`, `svm_model_validation.dart`, `svm_post_processing.dart`):** Memecah kode classifier ke modul terpisah (`<= 275` baris/file) serta menambahkan `validateShapes()` untuk memastikan kesesuaian ukuran tensor saat model dimuat.
- **Pembaruan Aset Model Jalur B Terbaru (`assets/models/`):** Mengganti `svm_pisang_meta.json`, `svm_pisang_weights.bin` (`3.1 MB`, 4 kelas `overripe`/`ripe`/`rotten`/`unripe`, `PCA = 100`, `5.434` *support vectors*), serta `mobilenet_v3_extractor.tflite`.
- **Sinkronisasi Gating Resep 4-Kelas (`ripeness_recipe_config.dart`):** Memperbaiki bug di mana hasil `Matang` (`<75%`) dari model 4-kelas sempat tergeser ke `Matang Banget` oleh aturan fallback 3-kelas lama.
- **Dokumentasi & Test (`hasil_testing/LAPORAN_AUDIT_TESTING_V2_4KELAS.md`, `test/services/on_device_svm_classifier_test.dart`, `test/services/recipe_gating_service_test.dart`):** Menambahkan laporan audit 12 sampel uji V2, test validasi dimensi dinamis (PCA 60 & 100), serta verifikasi penuh **`125 / 125` test lulus** dan `flutter analyze` bersih (`0` isu).

### Integrasi SPK PSO-Random Forest untuk Rekomendasi Tindakan (`Tahap 2`)
- **Aset & Mesin Inferensi SPK Offline (`assets/models/spk_pso_rf_model.json`, `lib/services/spk_decision_service.dart`):** Menambahkan model 26 pohon *PSO-Optimized Random Forest* ke aset Flutter dan membangun mesin inferensi pure-Dart offline dengan 8 fitur input (`prob_unripe/ripe/overripe/rotten * 100`, `green_ratio`, `brown_dark_ratio`, `target_days`, `usage_goal`) serta 4 kelas keputusan tindakan.
- **Penerusan Rasio Pigmen (`scan_outcome.dart`, `on_device_scan_service.dart`):** Menyimpan `greenRatio` dan `brownDarkRatio` dari `PigmentRatios` ke `ScanSuccess` agar dapat dikonsumsi langsung oleh SPK tanpa komputasi ulang.
- **Gating Tindakan & Pengaman Pangan (`recipe_gating_service.dart`, `recipe_gating_provider.dart`):** Menghubungkan `SpkDecisionService` ke `RecipeGatingService.resolveSpkActionPlan()` dengan pengaman pangan agar hasil pindai `rotten` selalu terkunci ke keputusan buang/kompos (kelas `3`).
- **UI Interaktif Layar Hasil (`spk_recommendation_card.dart`, `result_recipe_gating_section.dart`):** Menambahkan kartu rekomendasi SPK beserta pilihan interaktif `Rencana pakai` (`Hari ini`, `2–3 hari`, `> 4 hari`) dan `Tujuan` (`Konsumsi`, `Jual`, `Olahan`) yang menghitung ulang keputusan secara instan.
- **Verifikasi Paritas & Widget Test (`test/services/spk_decision_service_test.dart`, `test/ui/result_recipe_gating_section_test.dart`):** Uji paritas Dart vs Python (selisih `< 1e-5` pada 5 skenario), uji pengaman pangan, serta uji interaksi widget — seluruh **`136 / 136` test lulus** dan `flutter analyze` bersih (`0` isu).
- **Kalibrasi Latar Gelap Pisang Kuning (`lib/services/svm_post_processing.dart`, `on_device_image_preprocessor.dart`):** Menyempurnakan `applyOverripeYellowCalibration()` serta filter aspal/bayangan gelap (`v < 85 && s < 75`) agar pisang kuning bersih di latar gelap/aspal dikembalikan aman ke `ripe` (`Matang`), sementara pisang busuk gelap tetap tidak tersentuh.
- **Upgrade UX Halaman Hasil Pindai & Penyesuaian Tombol SPK (`result_success_view.dart`, `result_probability_accordion.dart`, `spk_recommendation_card.dart`, `result_recipe_gating_section.dart`):** Menyederhanakan layar hasil menjadi 4 blok logis tanpa duplikasi (menghapus tombol `Ide Resep` ganda serta kartu statis `Analisis Kematangan` & `Cara Menyimpan`), melipat rincian 4 skor AI ke accordion (`Lihat rincian skor AI`), memindahkan kartu SPK ke posisi utama dengan pilihan di bagian atas, serta menyesuaikan opsi & default SPK agar masuk akal per kondisi (`Mentah` tanpa opsi `Konsumsi`, `Matang Banget` tanpa `> 4 hari`/`Jual`, `Busuk` langsung ke `Buang / Kompos` + `Tips Daur Ulang`) — **`138 / 138` test lulus**.
- **Upgrade UI/UX Beranda Anti-Slop (`home_screen.dart`, `home_hero_scan_card.dart`, `home_quick_stats_row.dart`, `home_recent_scans_section.dart`, `home_recipes_section.dart`, `home_today_tip_card.dart`):** Menghapus 3 chip cepat terpotong (`Tips Bu...`, `Asisten...`, `Resep S...`) dan kartu duplikat `Pengingat Kesegaran`, mengganti 3 kotak statistik sempit (`Buah Favorit: Pisang`) dengan 1 strip metrik 3 kolom (`Total Pindai`, `Siap Santap`, `Mentah`) tanpa elipsis, menyelaraskan copywriting ke BananaLens (`Pindai Pisang`), menampilkan thumbnail foto asli di Riwayat Terakhir, serta menambahkan target kematangan pada kartu resep.
- **Penyelarasan Ekstraksi 30 Fitur HSV Sel 3 (`on_device_image_preprocessor.dart`):** Memperbarui susunan vektor HSV dari format lama (`12+6+6+3+3`) ke format model terbaru (`12 Hue + 5 Sat + 5 Val + 2 Mean(H,S) + 2 Std(H,S) + 4 Rasio Pigmen`, masing-masing dikali `hsvWeight = 2.5`) agar 100% identik dengan pipeline training Colab — **`138 / 138` test lulus**, `flutter analyze` bersih (`0` isu).
- **Upgrade UI/UX Halaman Riwayat Scan (`history_screen.dart`, `history_item_card.dart`):** Menambahkan chip filter `Matang Banget`, menampilkan persentase keyakinan (`% yakin`) serta penghitung jumlah hasil (`N hasil pindai`), memperbaiki pencarian kata kunci `'matang banget'`, menghapus timer kedip hint search dengan hint fokus pisang, memperbaiki bug selisih hari pergantian bulan pada `_formatDate`, serta memecah kartu item ke komponen terpisah (`<= 230` baris/file).

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
- **Stage-1 Banana Gate (ImageNet EfficientNet-Lite0 TFLite) & Penolakan Non-Pisang (`on_device_banana_gate.dart`, `imagenet_banana_gate.tflite`, `ml_kit_fruit_detector.dart`, `on_device_image_preprocessor.dart`, `on_device_scan_service.dart`):** Menambahkan model TFLite resmi Google `EfficientNet-Lite0 INT8` (1000 kelas ImageNet, kelas #954 = `banana`) di background `IsolateInterpreter` sebagai gerbang validasi Stage-1 sebelum Stage-2 SVM Jalur B, sehingga buah kuning/hijau non-pisang (mangga, alpukat, buah kuning raksasa) ikut ditolak sementara pisang satuan, 1 sisir, hijau mentah, maupun busuk tetap terdeteksi akurat. Memisahkan `_personSelfieKeywords` dari `_nonFruitKeywords` di ML Kit serta mempertahankan filter warna `nonBananaVividRatio >= 0.45`.
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
