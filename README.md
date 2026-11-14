# 🍎 FruitLens — Pemindai Buah Cerdas (Mobile, Visi Komputer & AI)

FruitLens adalah aplikasi mobile cerdas berbasis **Flutter**, **Visi Komputer (TensorFlow Lite)**, dan **Kecerdasan Buatan (Gemini API)** yang dirancang untuk mengenali jenis buah, mendeteksi tingkat kematangan, menyajikan informasi nutrisi lengkap, merekomendasikan resep olahan lezat, dan menyediakan asisten percakapan AI seputar buah.

Proyek ini merupakan integrasi tugas besar untuk 3 mata kuliah:
1. **Pemrograman Mobile 2**: Arsitektur Flutter, Riverpod, Database Lokal SQLite, Navigasi Stateful GoRouter, Kamera, dan Clean Architecture.
2. **Visi Komputer**: Klasifikasi citra jenis buah dan tingkat kematangan (mentah, matang, lewat matang, busuk) on-device menggunakan TensorFlow Lite.
3. **Kecerdasan Buatan**: Asisten chatbot AI percakapan, rekomendasi resep berbasis konteks kematangan, dan sistem filter alergi personal.

---

## ✨ Fitur Utama

- **Pindai Kamera & Galeri**: Ambil foto buah secara langsung dengan panduan framing atau pilih dari galeri perangkat.
- **Deteksi Kematangan & Gizi**: Analisis instan tingkat kematangan dengan indikator warna dan simbol (🟢 Mentah, 🟡 Matang, 🟠 Lewat Matang, 🔴 Busuk) serta rincian kalori, karbohidrat, gula, dan serat per 100 g.
- **Asisten Percakapan AI**: Chatbot pintar berbahasa Indonesia yang memahami konteks buah yang baru saja kamu pindai.
- **Rekomendasi Resep Cerdas**: Rekomendasi resep olahan sesuai tingkat kematangan (misal: pisang yang terlalu matang direkomendasikan menjadi smoothie atau pancake).
- **Peringatan Alergi Personal**: Deteksi otomatis dan peringatan jika buah atau bahan resep bertentangan dengan riwayat alergi di profil pengguna.
- **Riwayat Pindaian Offline**: Database SQLite lokal menyimpan riwayat lengkap secara aman di perangkat tanpa memerlukan koneksi internet.
- **Desain Bebas "AI Slop"**: Antarmuka modern Material 3 yang dirancang dengan prinsip desain manusiawi, tipografi berkontras tinggi, target sentuh nyaman (≥ 48dp), dan navigasi Center FAB yang menonjol.

---

## 🏗️ Arsitektur Aplikasi

FruitLens mengadopsi **Clean Architecture Ringan** dengan prinsip pemisahan tanggung jawab yang ketat:

```
lib/
├── app.dart                   # MaterialApp.router & konfigurasi tema
├── main.dart                  # Bootstrap ProviderScope
├── core/
│   ├── constants/             # Konstanta string UI bahasa Indonesia & threshold
│   ├── router/                # StatefulShellRoute GoRouter (5 Tab + Detail)
│   └── theme/                 # Token desain: AppColors, AppSpacing, AppRadius, RipenessColors
├── data/
│   ├── models/                # ScanOutcome, FruitInfo, Recipe, ScanResult, UserProfile
│   ├── repositories/          # FruitInfoRepository, HistoryRepository (SQLite), RecipeRepository
│   └── sources/               # Database SQLite helper & asset loaders
├── services/                  # ScanService (TFLite/Fake), ChatService (Gemini/Fake), AuthService, CameraAccess
├── providers/                 # State management Riverpod (AsyncNotifier)
└── ui/
    ├── screens/               # Home, Scan, Result, Chat, History, Profile, Auth, Recipes, Onboarding
    └── widgets/               # RipenessBadge, NutritionPanel, MainScaffoldWithNav
```

---

## 🚀 Cara Menjalankan Proyek

### Prasyarat:
- Flutter SDK (versi 3.24+ / 3.41+)
- Android SDK (minSdk 26 / Android 8.0 Oreo ke atas)
- Emulator Android atau Perangkat Fisik Android

### Langkah Instalasi:
1. **Clone repositori dan masuk ke folder proyek:**
   ```bash
   cd d:\project\FruitLens
   ```

2. **Pasang seluruh dependensi:**
   ```bash
   flutter pub get
   ```

3. **Salin template konfigurasi rahasia:**
   ```bash
   copy .env.example .env
   ```

4. **Jalankan pengujian otomatis (Unit & Widget Tests):**
   ```bash
   flutter test
   ```
   *(Seluruh 33 automated tests siap dan lulus 100%)*

5. **Jalankan aplikasi di emulator atau perangkat fisik:**
   ```bash
   flutter run
   ```

6. **Build file APK Rilis:**
   ```bash
   flutter build apk --release
   ```
   Biner rilis siap pakai berada di: `build/app/outputs/flutter-apk/app-release.apk` (Ukuran: **50.0 MB**).

---

## 👥 Pembagian Tim & Alur Kelompok

- **Jalur A (Aplikasi Flutter)**:
  - Frontend, State Management (Riverpod), UI/UX Anti-Slop, Database SQLite Offline, Sesi Akun Persisten, Navigasi, dan Komponen Resep.
- **Jalur B (Visi Komputer & AI)**:
  - Pelatihan model CNN/MobileNetV2 jenis buah & kematangan, ekspor `.tflite`, dan prompt Gemini API.
  - Kontrak integrasi lengkap antara Jalur A dan Jalur B tercatat di [`INTEGRATION_CONTRACT.md`](INTEGRATION_CONTRACT.md).

---

## 🧪 Skenario Pengujian untuk Demo Dosen

1. **Alur Pindai Buah & Hasil**:
   - Buka tab **Pindai** (tombol kamera hijau di tengah) atau pilih "Pilih dari galeri".
   - Aplikasi menganalisis buah dan menampilkan **Layar Hasil** lengkap dengan nama buah, status kematangan bersimbol, dan tabel gizi.
2. **Alur Chatbot Kontekstual**:
   - Pada Layar Hasil, tekan tombol **"Tanya AI"**.
   - Tab Chatbot akan terbuka dengan banner konteks buah aktif. Chatbot akan menjawab pertanyaan spesifik tentang buah tersebut.
3. **Alur Rekomendasi Resep & Alergi**:
   - Di tab **Profil**, tandai alergi (misal: "Stroberi" atau "Lateks").
   - Pindai buah terkait atau buka **Ide Resep**. Sistem otomatis menampilkan banner peringatan alergi kuning/merah.
4. **Alur Riwayat Offline**:
   - Matikan koneksi internet / nyalakan Mode Pesawat.
   - Buka tab **Riwayat**. Seluruh riwayat tetap tampil dan dapat dibuka detailnya, ditandai favorit, atau dihapus.
