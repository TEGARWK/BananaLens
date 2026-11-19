# 🍌 BananaLens — Pemindai Kematangan Pisang Cerdas (Mobile, Visi Komputer & AI)

**BananaLens** adalah aplikasi mobile Android berbasis **Flutter** yang difokuskan khusus untuk **deteksi kematangan buah pisang**. Aplikasi ini menggabungkan **On-Device Computer Vision** (Google ML Kit + TensorFlow Lite `MobileNetV3Small` + Masked HSV + PCA + RBF SVM + Kalibrasi Pigmen Warna + Deteksi *Out-of-Distribution*), **Kecerdasan Buatan** (Google Gemini API untuk Chatbot & Generator Resep Pisang), serta penyimpanan ***Offline-First*** (SQLite + sinkronisasi opsional Firebase Auth & Cloud Firestore).

Proyek ini merupakan integrasi tugas besar untuk 3 mata kuliah di **Politeknik Negeri Indramayu**:
1. **Pemrograman Mobile 2**: Arsitektur Flutter (*Clean Architecture* ringan), Riverpod, GoRouter, Kamera/Galeri, SQLite *offline-first*, dan integrasi Firebase.
2. **Visi Komputer**: Validasi objek pisang *on-device* via Google ML Kit, filter spektrum pigmen non-pisang, deteksi *out-of-distribution* (OOD) berbasis RBF kernel similarity, serta klasifikasi kematangan pisang 3 kelas (`Mentah`, `Matang`, `Busuk`) 100% *on-device* di background `Isolate` menggunakan `MobileNetV3Small`, fitur warna HSV, PCA, RBF SVM, dan kalibrasi pigmen klorofil & *overripe*.
3. **Kecerdasan Buatan**: Asisten chatbot pisang kontekstual, gating keamanan pangan deterministik, serta generator resep olahan pisang berbasis tingkat kematangan dan preferensi selera dengan cadangan 12 resep lokal.

---

## ✨ Fitur Utama

- **Pindai Pisang Kamera & Galeri (*On-Device Offline*):** Ambil foto langsung atau pilih dari galeri; inferensi berjalan di background `Isolate` tanpa koneksi internet, lengkap dengan grafik probabilitas 3 kelas (`Mentah`, `Matang`, `Busuk`) dan banner peringatan bila keyakinan `< 60%`.
- **Stage-1 Banana Gate (*2-Stage Cascade On-Device*):** Menggabungkan Google ML Kit, filter spektrum pigmen (`nonBananaVividRatio >= 0.45`), dan model TFLite resmi Google **EfficientNet-Lite0 INT8 ImageNet** (`imagenet_banana_gate.tflite`, kelas #954 = `banana`) di background `IsolateInterpreter` untuk menolak mangga, alpukat, jeruk, terong, wajah, dan benda non-pisang sebelum diteruskan ke Stage-2 SVM kematangan pisang.
- **Kalibrasi Pigmen Klorofil & *Overripe*:** Penyesuaian pasca-SVM untuk menjaga akurasi pada pisang hijau mentah berlatar beragam serta pisang kuning berbintik *sugar spots* agar masuk kategori `Matang Banget` (layak olah), sementara pisang busuk merata tetap ditandai `Busuk`.
- **Gating Keamanan Pangan & Rekomendasi Resep Pisang AI:**
  - **Busuk:** Menampilkan peringatan `"Buang saja, jangan dikonsumsi"` dan tombol **Tips Daur Ulang** (kompos), tanpa memanggil AI.
  - **Mentah:** Menampilkan estimasi hari tunggu matang dan opsi olahan pisang mentah (misal keripik/pisang goreng).
  - **Matang / Matang Banget:** Tombol **Ide Resep** membuka daftar resep olahan pisang buatan **Gemini AI** dengan 6 pilihan selera (`Semua`, `Makanan`, `Minuman`, `Manis`, `Gurih`, `Praktis`), penanda `AI`, *sliding shimmer loading*, dan cadangan otomatis ke **12 resep pisang lokal** saat offline atau kuota habis.
- **Asisten Percakapan AI Khusus Pisang:** Chatbot berbahasa Indonesia (`GeminiChatService`) yang memahami konteks kematangan pisang hasil pindaian terakhir, tips penyimpanan, gizi, hingga ide olahan.
- **Informasi Gizi Pisang & Peringatan Alergi Personal:** Rincian kalori, karbohidrat, gula, dan serat pisang per 100 g, serta peringatan otomatis jika cocok dengan daftar alergi relevan olahan pisang (*Pisang / Lateks*, *Susu / Laktosa*, *Kacang-kacangan*, *Gluten / Gandum*, *Telur*, *Cokelat*) di **Pengaturan Akun**.
- **Riwayat Offline & Sinkronisasi Cloud:** Tersimpan otomatis di SQLite lokal (`fruitlens.db` v5) lengkap dengan favorit, pencarian, dan 3 ikon status pisang industrial (`banana_unripe.png`, `banana_ripe.png`, `banana_rotten.png`), serta sinkronisasi opsional ke Cloud Firestore saat login.
- **Desain BananaLens (*Layered Tactile Industrial Minimalism*):** Tema ganda terang & gelap dengan aksen *Banana Volt Yellow* (`#F5D51E`), ilustrasi khusus pisang di splash screen, onboarding, dan auth, serta animasi *skeleton loading* (`ShimmerBox`).

---

## 🏗️ Arsitektur Aplikasi

BananaLens mengadopsi **Clean Architecture Ringan** (`UI → Provider/Notifier → Repository/Service → Data Source`):

```text
lib/
├── app.dart                      # MaterialApp.router & konfigurasi tema BananaLens
├── main.dart                     # Bootstrap dotenv, Firebase opsional, ProviderScope
├── firebase_options.dart         # Konfigurasi proyek Firebase Android
├── core/
│   ├── constants/                # app_constants.dart, app_strings.dart, ripeness_recipe_config.dart
│   ├── router/                   # GoRouter (5 tab shell + auth, scan-recipes, account-settings, detail)
│   ├── theme/                    # BananaLens light & dark tokens (HarvestColors)
│   └── utils/                    # fruit_name_helper.dart
├── data/
│   ├── models/                   # ScanOutcome, ScanResult, FruitInfo, Recipe, UserProfile, ChatTurn
│   ├── repositories/             # HistoryRepository, FruitInfoRepository, RecipeRepository
│   └── sources/                  # AppDatabase (SQLite v5 & asset loaders)
├── providers/                    # Riverpod Notifier/AsyncNotifier (Scan, Chat, Auth, History, RecipeGating)
├── services/                     # OnDeviceScanService, MlKitFruitValidator, OnDeviceImagePreprocessor,
│                                 # OnDeviceSvmClassifier, GeminiChatService, GeminiRecipeService,
│                                 # RecipeGatingService, AuthService, CloudSyncService
└── ui/
    ├── screens/                  # Splash, Onboarding, Home, Scan, Result, ScanRecipes, RecipesList/Detail,
    │                             # Chat, History, Profile, AccountSettings, Auth
    └── widgets/                  # Komponen modular reusable, RipenessBadge, NutritionPanel, ShimmerBox
assets/
├── data/                         # fruits.json, recipes.json (12 resep khusus pisang)
├── images/                       # Ilustrasi onboarding, auth, launcher, dan 3 ikon pisang industrial
└── models/                       # mobilenet_v3_extractor.tflite, svm_pisang_meta.json, svm_pisang_weights.bin
backend/                          # Opsional FastAPI microservice (main.py, Dockerfile, test_api.py)
hasil_testing/                    # Laporan pengujian mobile & screenshot uji nyata
```

---

## 🚀 Cara Menjalankan Proyek

### Prasyarat
- Flutter SDK (`3.41+` / Dart `^3.11.5`)
- Android SDK (`minSdk 26` / Android 8.0 Oreo ke atas)
- Emulator Android atau perangkat fisik Android

### Langkah Instalasi & Pengujian
1. **Clone repositori dan masuk ke folder proyek:**
   ```bash
   git clone https://github.com/TEGARWK/BananaLens.git
   cd BananaLens
   ```
2. **Pasang seluruh dependensi:**
   ```bash
   flutter pub get
   ```
3. **Salin template konfigurasi `.env`:**
   ```bash
   copy .env.example .env
   ```
   *(Isi `GEMINI_API_KEY` di `.env` untuk mengaktifkan Chatbot & Generator Resep Gemini asli; jika kosong, aplikasi otomatis memakai fallback 12 resep pisang lokal).*
4. **Jalankan analisis statis & seluruh automated test:**
   ```bash
   flutter analyze
   flutter test
   ```
   *(Status terverifikasi: `flutter analyze` bersih dan **109 / 109** automated tests lulus).*
5. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```
6. **Build APK Rilis (opsional):**
   ```bash
   flutter build apk --release
   ```

---

## 👥 Pembagian Tim & Dokumentasi Terkait

- **Jalur A — Aplikasi Flutter:** Arsitektur, state management Riverpod, UI/UX BananaLens, kamera/izin, pipeline *on-device* + kalibrasi warna + filter non-pisang/OOD, SQLite *offline-first*, Firebase Auth/Firestore, gating resep & UX awam.
- **Jalur B — Visi Komputer & AI:** Dataset pisang, training model `MobileNetV3Small` + `HSV` + `PCA` + `RBF SVM`, ekspor artefak model, dan evaluasi akurasi.
- **Dokumen Penting di Repo:**
  - [`CHANGELOG.md`](CHANGELOG.md) — Catatan perubahan berkala proyek
  - [`hasil_testing/LAPORAN_TESTING_MOBILE.md`](hasil_testing/LAPORAN_TESTING_MOBILE.md) — Laporan pengujian aplikasi mobile & screenshot
  - [`INTEGRATION_CONTRACT.md`](INTEGRATION_CONTRACT.md) — Kontrak integrasi Jalur A & Jalur B
  - [`ARCHITECTURE.md`](ARCHITECTURE.md) & [`DESIGN_RULES.md`](DESIGN_RULES.md) — Panduan arsitektur & desain UI

---

## 🧪 Skenario Pengujian Demo

1. **Pindai Pisang Offline (Mode Pesawat):** Buka tab **Pindai**, foto pisang mentah/matang/busuk → hasil kematangan, grafik probabilitas 3 kelas, dan gizi pisang per 100 g tampil serta tersimpan otomatis ke SQLite.
2. **Penolakan Objek & Buah Non-Pisang:** Pindai buah selain pisang (jeruk, alpukat, mangga, terong) atau benda non-buah → aplikasi menolak sebagai `Bukan Pisang / Tidak Dikenali` dan meminta foto ulang pisang.
3. **Gating Keamanan Pangan & Resep Pisang AI:** Pada hasil pindai **Matang / Matang Banget**, tekan **Ide Resep**, pilih selera (`Manis`, `Gurih`, `Minuman`, dll.) → resep olahan pisang buatan Gemini AI tampil dengan badge `AI`, dan otomatis memakai 12 resep pisang lokal jika offline. Pada pisang **Busuk**, muncul peringatan buang dan **Tips Daur Ulang**.
4. **Chatbot Pisang Kontekstual & Alergi:** Tekan **Tanya AI** dari layar hasil untuk berkonsultasi mengenai pisang yang baru dipindai, atau atur alergi olahan pisang di **Profil → Pengaturan Akun**.
5. **Riwayat Offline & Sinkronisasi:** Tab **Riwayat** tetap bisa diakses, dicari, difavoritkan, dan dihapus saat offline, lalu tersinkronisasi ke Cloud Firestore ketika login dan online.
