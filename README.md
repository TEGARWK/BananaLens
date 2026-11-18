# 🍎 FruitLens — Pemindai Buah Cerdas (Mobile, Visi Komputer & AI)

**FruitLens** adalah aplikasi mobile Android berbasis **Flutter** yang menggabungkan **On-Device Computer Vision** (Google ML Kit + TensorFlow Lite `MobileNetV3Small` + Masked HSV + PCA + RBF SVM + Kalibrasi Pigmen Warna), **Kecerdasan Buatan** (Google Gemini API untuk Chatbot & Generator Resep), serta penyimpanan ***Offline-First*** (SQLite + sinkronisasi opsional Firebase Auth & Cloud Firestore).

Proyek ini merupakan integrasi tugas besar untuk 3 mata kuliah di **Politeknik Negeri Indramayu**:
1. **Pemrograman Mobile 2**: Arsitektur Flutter (*Clean Architecture* ringan), Riverpod, GoRouter, Kamera/Galeri, SQLite *offline-first*, dan integrasi Firebase.
2. **Visi Komputer**: Validasi objek buah via Google ML Kit dan klasifikasi kematangan 3 kelas (`Mentah`, `Matang`, `Busuk`) 100% *on-device* di background `Isolate` menggunakan `MobileNetV3Small`, fitur warna HSV, PCA, RBF SVM, serta kalibrasi pigmen klorofil & *overripe*.
3. **Kecerdasan Buatan**: Asisten chatbot buah kontekstual, gating keamanan pangan deterministik, serta generator resep AI berbasis kematangan dan preferensi selera dengan fallback resep lokal.

---

## ✨ Fitur Utama

- **Pindai Kamera & Galeri (*On-Device Offline*):** Ambil foto langsung atau pilih dari galeri; inferensi berjalan di background `Isolate` tanpa koneksi internet, lengkap dengan grafik probabilitas 3 kelas (`Mentah`, `Matang`, `Busuk`) dan banner peringatan bila keyakinan `< 60%`.
- **Kalibrasi Pigmen Klorofil & *Overripe*:** Penyesuaian pasca-SVM untuk menjaga akurasi pada pisang hijau mentah berlatar beragam serta pisang kuning berbintik *sugar spots* agar tetap masuk kategori `Matang Banget` (layak olah), sementara pisang busuk merata tetap ditandai `Busuk`.
- **Gating Keamanan Pangan & Rekomendasi Resep AI:**
  - **Busuk:** Menampilkan peringatan `"Buang saja, jangan dikonsumsi"` dan tombol **Tips Daur Ulang** (kompos), tanpa memanggil AI.
  - **Mentah:** Menampilkan estimasi hari tunggu matang dan opsi olahan yang sesuai.
  - **Matang / Matang Banget:** Tombol **Rekomendasi Resep** membuka daftar resep buatan **Gemini AI** dengan 6 pilihan selera (`Semua`, `Makanan`, `Minuman`, `Manis`, `Gurih`, `Praktis`), penanda `AI`, *skeleton loading*, dan cadangan otomatis ke **12 resep lokal** saat offline atau kuota habis.
- **Asisten Percakapan AI Kontekstual:** Chatbot berbahasa Indonesia (`GeminiChatService`) yang memahami konteks buah hasil pindaian terakhir.
- **Informasi Gizi & Peringatan Alergi Personal:** Rincian kalori, karbohidrat, gula, dan serat per 100 g untuk 10 jenis buah (`fruits.json`), serta peringatan otomatis jika cocok dengan alergi di **Pengaturan Akun**.
- **Riwayat Offline & Sinkronisasi Cloud:** Tersimpan otomatis di SQLite lokal (`fruitlens.db`) lengkap dengan favorit dan pencarian, serta sinkronisasi opsional ke Cloud Firestore saat login.
- **Tema Ganda & UX Ramah Awam:** Mendukung tema *Fresh Harvest* (terang) dan *Night Harvest* (gelap), bahasa UI yang mudah dipahami, dan *skeleton loading* (`ShimmerBox`).

---

## 🏗️ Arsitektur Aplikasi

FruitLens mengadopsi **Clean Architecture Ringan** (`UI → Provider/Notifier → Repository/Service → Data Source`):

```text
lib/
├── app.dart                      # MaterialApp.router & konfigurasi tema
├── main.dart                     # Bootstrap dotenv, Firebase opsional, ProviderScope
├── firebase_options.dart         # Konfigurasi proyek Firebase Android
├── core/
│   ├── constants/                # app_constants.dart, app_strings.dart, ripeness_recipe_config.dart
│   ├── router/                   # GoRouter (5 tab shell + auth, scan-recipes, account-settings, detail)
│   ├── theme/                    # Fresh Harvest & Night Harvest tokens
│   └── utils/                    # fruit_name_helper.dart
├── data/
│   ├── models/                   # ScanOutcome, ScanResult, FruitInfo, Recipe, UserProfile, ChatTurn
│   ├── repositories/             # HistoryRepository, FruitInfoRepository, RecipeRepository
│   └── sources/                  # AppDatabase (SQLite helper & asset loaders)
├── providers/                    # Riverpod Notifier/AsyncNotifier (Scan, Chat, Auth, History, RecipeGating)
├── services/                     # OnDeviceScanService, MlKitFruitValidator, OnDeviceSvmClassifier,
│                                 # GeminiChatService, GeminiRecipeService, RecipeGatingService, Firebase
└── ui/
    ├── screens/                  # Home, Scan, Result, ScanRecipes, RecipesList/Detail, Chat, History, Profile, AccountSettings, Auth
    └── widgets/                  # Komponen modular reusable, RipenessBadge, NutritionPanel, ShimmerBox
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
   git clone https://github.com/TEGARWK/FruitLens.git
   cd FruitLens
   ```
2. **Pasang seluruh dependensi:**
   ```bash
   flutter pub get
   ```
3. **Salin template konfigurasi `.env`:**
   ```bash
   copy .env.example .env
   ```
   *(Isi `GEMINI_API_KEY` di `.env` untuk mengaktifkan Chatbot & Generator Resep Gemini asli; jika kosong, aplikasi otomatis memakai fallback lokal).*
4. **Jalankan analisis statis & seluruh automated test:**
   ```bash
   flutter analyze
   flutter test
   ```
   *(Status terverifikasi: `flutter analyze` bersih dan **104 / 104** automated tests lulus).*
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

- **Jalur A — Aplikasi Flutter:** Arsitektur, state management Riverpod, UI/UX, kamera/izin, pipeline *on-device* + kalibrasi warna, SQLite *offline-first*, Firebase Auth/Firestore, gating resep & UX awam.
- **Jalur B — Visi Komputer & AI:** Dataset, training model `MobileNetV3Small` + `HSV` + `PCA` + `RBF SVM`, ekspor artefak model, dan evaluasi akurasi.
- **Dokumen Penting di Repo:**
  - [`CHANGELOG.md`](CHANGELOG.md) — Catatan perubahan berkala proyek
  - [`hasil_testing/LAPORAN_TESTING_MOBILE.md`](hasil_testing/LAPORAN_TESTING_MOBILE.md) — Laporan pengujian aplikasi mobile & screenshot
  - [`INTEGRATION_CONTRACT.md`](INTEGRATION_CONTRACT.md) — Kontrak integrasi Jalur A & Jalur B
  - [`ARCHITECTURE.md`](ARCHITECTURE.md) & [`DESIGN_RULES.md`](DESIGN_RULES.md) — Panduan arsitektur & desain UI

---

## 🧪 Skenario Pengujian Demo

1. **Pindai Buah Offline (Mode Pesawat):** Buka tab **Pindai** (ikon kamera hijau di tengah), foto pisang mentah/matang/busuk → hasil kematangan, grafik probabilitas 3 kelas, dan gizi per 100 g tampil serta tersimpan otomatis ke SQLite.
2. **Gating Keamanan Pangan & Resep AI:** Pada hasil pindai **Matang / Matang Banget**, tekan **Rekomendasi Resep**, pilih selera (`Manis`, `Gurih`, `Minuman`, dll.) → resep buatan Gemini AI tampil dengan badge `AI`, dan otomatis memakai 12 resep lokal jika offline. Pada pisang **Busuk**, muncul peringatan buang dan **Tips Daur Ulang**.
3. **Chatbot Kontekstual & Alergi:** Tekan **Tanya AI** dari layar hasil untuk berkonsultasi dengan konteks buah aktif, atau atur alergi di **Profil → Pengaturan Akun** untuk melihat peringatan otomatis saat scan.
4. **Riwayat Offline & Sinkronisasi:** Tab **Riwayat** tetap bisa diakses, dicari, difavoritkan, dan dihapus saat offline, lalu tersinkronisasi ke Cloud Firestore ketika login dan online.
