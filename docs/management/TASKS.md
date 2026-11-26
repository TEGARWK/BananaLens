# TASKS.md — Papan Tugas (1 Fase = 1 Hasil)

Aturan: AI mengerjakan **satu fase penuh** per siklus kerja sampai seluruh tugas dalam fase berstatus `DONE`, lalu berhenti dan melapor.
Status: `TODO` → `DOING` → `REVIEW` → `DONE` (atau `BLOCKED`).

## Pembagian Jalur Kerja (kelompok)

| Jalur | Pemilik | Cakupan | Dikerjakan AI di repo ini? |
|---|---|---|---|
| **A — Aplikasi Flutter** | User (+ AI) | UI, state, navigasi, kamera, riwayat, auth, profil, layar chatbot, data statis | **Ya** |
| **B — Visi Komputer & AI** | Teman | Dataset, training, ekspor `.tflite`, `labels.txt`, `ChatService` Gemini asli, system prompt, evaluasi | **Tidak** (hanya diserahkan lewat `INTEGRATION_CONTRACT.md`) |

Prinsip: jalur A **tidak menunggu** jalur B. Aplikasi memakai `abstract class` + implementasi **Fake** (berlabel `TODO-INTEGRASI`) sampai artefak jalur B siap, lalu diganti di **Fase 7**.
Kontrak antarmuka: lihat [INTEGRATION_CONTRACT.md](INTEGRATION_CONTRACT.md).

## Jalur A — Aplikasi

### Fase 1 — Persiapan ✅
| ID | Peran | Tugas | Hasil | Status |
|---|---|---|---|---|
| T-01 | Tech Lead | Inisialisasi proyek Flutter, dependency inti, lint ketat, `.env.example` | analyze bersih | DONE |
| T-02 | Tech Lead | Struktur folder + `ProviderScope` + `go_router` | router berjalan | DONE |
| T-03 | UI/UX + Frontend | Tema Material 3 + token desain | halaman preview tema | DONE |
| T-04 | Frontend | Bottom navigation 5 tab + FAB Scan | navigasi antar tab berfungsi | DONE |

### Fase 2 — Kontrak & Fake Services (menggantikan "Model")
| ID | Peran | Tugas | Hasil | Skill | Status |
|---|---|---|---|---|---|
| T-10 | Tech Lead | Finalisasi `INTEGRATION_CONTRACT.md` (label, input/output model, API ChatService) untuk dikirim ke teman | Dokumen disetujui user | `api-and-interface-design`, `documentation-and-adrs` | DONE |
| T-11 | Mobile Engineer | Model `ScanOutcome` (sealed), `ScanService` abstract + `FakeScanService` + provider + test | Scan palsu terdeteksi lewat provider, test lulus | `api-and-interface-design`, `test-driven-development` | DONE |
| T-12 | AI/LLM + Mobile | `ChatService` abstract + `FakeChatService` + provider + test | Balasan palsu lewat provider, test lulus | `api-and-interface-design`, `test-driven-development` | DONE |
| T-13 | Backend/Data | `labels.txt` sementara (10 buah) + `fruits.json` + `FruitInfoRepository` + test | Query nutrisi by label | `test-driven-development` | DONE |

### Fase 3 — Inti Aplikasi
| ID | Peran | Tugas | Hasil | Skill | Status |
|---|---|---|---|---|---|
| T-20 | Frontend + Mobile | Layar kamera + izin + galeri (`camera`, `image_picker`) | Ambil/pilih foto, izin ditolak tertangani | `frontend-ui-engineering`, taste-skill | DONE |
| T-21 | Mobile Engineer | `ScanNotifier` (loading/error/uncertain/sukses) memakai `ScanService` | Foto → hasil via Fake | `test-driven-development` | DONE |
| T-22 | Frontend | Layar hasil scan (foto, kematangan, confidence, nutrisi, state tidak yakin) | Hasil tampil lengkap | `frontend-ui-engineering`, taste-skill | DONE |

### Fase 4 — Fitur Pendukung
| ID | Peran | Tugas | Hasil | Skill | Status |
|---|---|---|---|---|---|
| T-30 | Backend/Data | SQLite + `HistoryRepository` (CRUD) + test | CRUD riwayat teruji | `test-driven-development` | DONE |
| T-31 | Frontend | Layar riwayat + detail + hapus + konfirmasi | Daftar & hapus berfungsi | `frontend-ui-engineering`, taste-skill | DONE |
| T-32 | Backend/Data | Firebase Auth + `AuthService` + notifier | Register/login/logout, sesi persisten | `security-and-hardening` | DONE |
| T-33 | Frontend | Layar login/register + validasi | Form jalan, error jelas | `frontend-ui-engineering`, taste-skill | DONE |
| T-34 | Frontend + Backend | Profil (usia, berat, tujuan, alergi) | Profil tersimpan & dapat diubah | `frontend-ui-engineering` | DONE |

### Fase 5 — Chatbot & Resep (sisi aplikasi)
| ID | Peran | Tugas | Hasil | Skill | Status |
|---|---|---|---|---|---|
| T-40 | Frontend | Layar chatbot (bubble, mengetik, chip saran, konteks scan, error + coba lagi) memakai `ChatService` | Chat jalan end-to-end dengan Fake | `frontend-ui-engineering`, taste-skill | DONE |
| T-41 | Backend/Data + Frontend | `recipes.json` + rekomendasi per kematangan & alergi + layar resep | Resep relevan tampil | `test-driven-development` | DONE |

### Fase 6 — Polishing & Rilis
| ID | Peran | Tugas | Hasil | Skill | Status |
|---|---|---|---|---|---|
| T-50 | Frontend | Splash + onboarding 3 slide | Tampil sekali | `frontend-ui-engineering`, taste-skill | DONE |
| T-51 | QA | Skenario gagal: izin ditolak, offline, gambar buram, API down | Laporan uji | `test-driven-development`, `debugging-and-error-recovery` | DONE |
| T-52 | Code Reviewer | Review terhadap `ARCHITECTURE.md` | Daftar temuan + perbaikan | `code-review-and-quality` | DONE |
| T-53 | Security | Audit secret, izin, privasi foto | Laporan audit | `security-and-hardening` | DONE |
| T-54 | DevOps | Build APK rilis + CI analyze/test | APK ≤ 100 MB | `ci-cd-and-automation` | DONE |

### Fase 7 — Integrasi Jalur B (Opsi A: Hybrid MobileNetV3 + SVM via FastAPI)
Syarat mulai: artefak `baca/svm_pisang_hybrid.pkl` dan kontrak `INTEGRATION_CONTRACT.md` (Opsi A) telah disetujui user.
| ID | Peran | Tugas | Hasil | Skill | Status |
|---|---|---|---|---|---|
| T-60A | Backend/AI | Siapkan server Python FastAPI (`backend/main.py` & `backend/requirements.txt`) yang memuat `MobileNetV3Small` + `baca/svm_pisang_hybrid.pkl` dengan endpoint `GET /` (health check) dan `POST /predict` | Server FastAPI lokal siap dijalankan di port `8000` | `api-and-interface-design` | DONE |
| T-60B | Mobile Engineer | Tambahkan dependency `http` di `pubspec.yaml`, izin `INTERNET` dan `android:usesCleartextTraffic="true"` di `android/app/src/main/AndroidManifest.xml` | Konfigurasi HTTP lokal Android siap tanpa blokir cleartext | `security-and-hardening` | DONE |
| T-60C | Mobile Engineer | Perluas `ScanSuccess` (`lib/data/models/scan_outcome.dart`) dengan `classProbabilities` opsional, serta buat `ServerConfigNotifier` (`lib/providers/server_config_provider.dart`) berbasis `SharedPreferences` (default `10.0.2.2:8000`, mode fallback, tes koneksi `GET /`) | Model data & state konfigurasi IP server tersimpan persisten | `api-and-interface-design`, `test-driven-development` | DONE |
| T-60D | Mobile Engineer | Buat `FastApiScanService` (`lib/services/fastapi_scan_service.dart`) sesuai kontrak `ScanService` (multipart `POST /predict`, timeout 15 dtk, pemetaan ke `ScanSuccess`/`ScanUncertain`/`ScanFailure`) dan hubungkan di `lib/providers/service_providers.dart` | Aplikasi mengirim foto ke FastAPI & memetakan hasil model Hybrid SVM | `incremental-implementation`, `test-driven-development` | DONE |
| T-60E | Frontend | Tambahkan dialog/sheet Pengaturan IP Server (dengan tombol "Tes Koneksi" & badge Online/Offline) di `ScanScreen` & `ProfileScreen`, serta kartu **"Rincian Probabilitas 4 Kelas SVM"** (progress bar Mentah, Matang, Terlalu Matang, Busuk) di `ResultScreen` | IP dapat diubah langsung dari HP saat demo & grafik 4 kelas SVM tampil dengan tema Fresh/Night Harvest | `frontend-ui-engineering`, taste-skill | DONE |
| T-60F | QA | Tulis unit test `test/fastapi_scan_service_test.dart` (memakai `MockClient`) dan pastikan seluruh test yang ada tetap hijau + `flutter analyze` bersih | Seluruh 40 test lulus (0 error/warning) | `test-driven-development` | DONE |
| T-61 | AI/LLM + Mobile | Pasang `GeminiChatService` asli, key dari `.env`, ganti Fake (opsional/terpisah dari SVM) | Chat nyata + fallback error | `security-and-hardening` | BLOCKED (menunggu B-05) |
| T-62 | QA | Uji end-to-end di emulator/perangkat fisik dengan server FastAPI menyala & skenario server mati | Laporan uji akhir | `test-driven-development` | TODO |
| T-63 | Technical Writer | Laporan, README, panduan demo | Dokumen final | `documentation-and-adrs` | DONE |

## Jalur B — Visi Komputer & AI (dikerjakan teman, diserahkan ke repo di folder `baca/`)

| ID | Pemilik | Tugas | Serahan ke jalur A | Status |
|---|---|---|---|---|
| B-01 | Teman | Daftar kelas final + dataset (`unripe`, `ripe`, `overripe`, `rotten`) | Kelas di dalam `svm_pisang_hybrid.pkl` | DONE |
| B-02 | Teman | Feature Extractor `MobileNetV3Small` (`224x224`, 576 fitur) | Dipanggil via TensorFlow Keras di `main.py` | DONE |
| B-03 | Teman | Latih model kematangan pisang Hybrid SVM | `baca/svm_pisang_hybrid.pkl` (tersedia di repo) | DONE |
| B-04 | Teman | Panduan & skrip server FastAPI (`baca/model.md`) | Kontrak HTTP JSON `GET /` & `POST /predict` | DONE |
| B-05 | Teman | `ChatService` Gemini + system prompt + guardrail | Kode/prompt sesuai kontrak | TODO |

## Backlog (Could)
Dark mode penuh, notifikasi pengingat, favorit, sinkronisasi Firestore, deteksi multi-buah, live detection.

## Catatan / Tugas Temuan
<!-- AI menambahkan tugas baru di sini; jangan dikerjakan sebelum disetujui user. -->

### Roadmap Backend & Database (Hybrid Architecture)
Dokumentasi lengkap dan spesifikasi arsitektur tercatat di [RENCANA_BACKEND_DAN_DATABASE.md](RENCANA_BACKEND_DAN_DATABASE.md):
- [x] **BE-01:** Rencana arsitektur sistem Backend & Database disetujui dosen (FastAPI + Firebase BaaS + SQLite Offline-First).
- [x] **BE-02:** Pemantapan FastAPI AI Microservice (`backend/main.py`, `backend/requirements.txt`, `backend/Dockerfile`, `backend/README.md`).
- [x] **BE-03:** Konfigurasi Firebase Auth & migrasi provider dari `LocalAuthService` ke `FirebaseAuthService` (termasuk fallback offline cerdas & 67 test lulus).
- [x] **BE-04:** Integrasi Cloud Firestore & jembatan sinkronisasi data riwayat SQLite (`synced` flag) terverifikasi (70 test lulus).
- [x] **BE-05:** Integrasi Google Gemini API asli untuk konseling gizi dan rekomendasi resep (`GeminiChatService` + fallback `FakeChatService` + 72 test lulus).
- [x] **BE-06:** Pengujian terpadu end-to-end (Auth + Scan SVM + Offline Sync + Gemini) terverifikasi lengkap (72/72 test Flutter lulus, 5/5 test Python FastAPI OK, 0 error/warning).

Rencana lengkap tercatat di [RENCANA_PENINGKATAN_UI_UX.md](RENCANA_PENINGKATAN_UI_UX.md):
- [x] **T-UX-01:** Perjelas keyakinan jenis buah vs persentase kematangan di `ResultScreen` agar sinkron dengan output SVM.
- [x] **T-UX-02:** Terjemahkan nama buah ke Bahasa Indonesia (`Pisang`) dan format waktu relatif ("Hari ini, 23.54") di `HistoryScreen`.
- [x] **T-UX-03:** Tombol aksi kontekstual cerdas (ganti "Ide Resep" jadi "Panduan Kompos/Daur Ulang" jika buah Busuk).
- [x] **T-UX-04:** Pencegahan salah hapus item riwayat (konfirmasi dialog / pemisahan touch target).
- [x] **T-UX-05:** Animasi transisi halus (*smooth tween 600ms*) pada progress bar 4 kelas SVM di `ResultScreen`.
- [x] **T-UX-06:** Haptic feedback lembut saat scan buah berhasil terdeteksi.

### Rencana & Aturan Eksekusi Opsi A (Integrasi Hybrid MobileNetV3Small + SVM `.pkl` ke Aplikasi Utama FruitLens)
> **Status:** Menunggu konfirmasi user sebelum menulis/mengubah kode program (`.dart`, `.py`, `.yaml`, `.xml`).

1. **Prinsip Utama (Opsi A):**
   - **Tidak membuang aplikasi FruitLens:** Seluruh layar yang sudah dibangun dengan tema *Fresh Harvest* & *Night Harvest* (Beranda, Kamera/Scan, Hasil Scan & Nutrisi, Resep Sehat, Riwayat SQLite, Chatbot AI, Profil) **tetap dipertahankan 100%**.
   - **Mengadopsi penuh kecerdasan & fitur unggulan dari `baca/model.md`:**
     1. Ekstraksi fitur `MobileNetV3Small` (224×224 → 576 fitur) + klasifikasi `svm_pisang_hybrid.pkl` dijalankan melalui backend Python FastAPI lokal.
     2. Pengaturan **Alamat IP Server Laptop (`IP:Port`)** langsung dari UI aplikasi (disimpan di `SharedPreferences`), dilengkapi tombol **"Tes Koneksi Server"** (`GET /`) agar mudah berganti Wi-Fi/Hotspot saat demo tanpa *rebuild* APK.
     3. Visualisasi **"Rincian Probabilitas 4 Kelas SVM"** (`Mentah`, `Matang`, `Terlalu Matang`, `Busuk`) berupa *progress bar* berwarna sesuai token `HarvestColors` di halaman `ResultScreen`.

2. **Daftar File yang Akan Dibuat (Setelah Disetujui User):**
   - `backend/main.py`: Server FastAPI yang memuat `MobileNetV3Small` dan `../baca/svm_pisang_hybrid.pkl`, menyediakan endpoint `GET /` dan `POST /predict`.
   - `backend/requirements.txt`: Daftar paket Python (`fastapi`, `uvicorn`, `tensorflow`, `scikit-learn`, `joblib`, `pillow`, `python-multipart`).
   - `lib/providers/server_config_provider.dart`: State management Riverpod untuk menyimpan `serverAddress` (default `10.0.2.2:8000`), status tes koneksi, dan opsi mode fallback demo.
   - `lib/services/fastapi_scan_service.dart`: Implementasi `ScanService` yang mengirim file gambar lewat HTTP Multipart ke `http://<IP:Port>/predict`.
   - `lib/ui/widgets/server_config_sheet.dart`: Bottom sheet / dialog bertema *Fresh Harvest* untuk mengubah IP Server & mengetes koneksi.
   - `test/fastapi_scan_service_test.dart`: Unit test pengujian `FastApiScanService` (sukses, confidence rendah/uncertain, server error/timeout) menggunakan `MockClient`.

3. **Daftar File yang Akan Diubah (Setelah Disetujui User):**
   - `pubspec.yaml`: Menambahkan `http` untuk komunikasi REST/Multipart ke FastAPI.
   - `android/app/src/main/AndroidManifest.xml`: Menambahkan `<uses-permission android:name="android.permission.INTERNET"/>` dan `android:usesCleartextTraffic="true"`.
   - `lib/data/models/scan_outcome.dart`: Menambahkan field opsional `final Map<String, double>? classProbabilities;` pada `ScanSuccess` (kompatibel penuh dengan kode & test lama).
   - `lib/providers/service_providers.dart`: Mengarahkan `scanServiceProvider` ke `FastApiScanService` (dengan pembacaan IP dari `serverConfigProvider`).
   - `lib/core/constants/app_strings.dart`: Menambahkan teks UI Bahasa Indonesia untuk pengaturan IP server, status koneksi, dan judul rincian probabilitas 4 kelas SVM.
   - `lib/ui/screens/scan_screen.dart` & `lib/ui/screens/profile_screen.dart`: Menambahkan tombol akses cepat Pengaturan IP Server (`Icons.dns_outlined` / `Icons.wifi_rounded`).
   - `lib/ui/screens/result_screen.dart`: Menampilkan kartu **"Rincian Probabilitas 4 Kelas SVM"** dengan *progress bar* untuk keempat kelas (`unripe`, `ripe`, `overripe`, `rotten`) bila `classProbabilities` tersedia.





