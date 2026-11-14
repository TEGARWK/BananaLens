# ARCHITECTURE.md — Konvensi Kode Flutter FruitLens

## 1. Prinsip

1. **Separation of concerns**: UI hanya menampilkan state; logika di notifier; data di repository.
2. **Satu arah**: UI → Notifier → Repository → DataSource. Tidak boleh melompat lapisan.
3. **Immutable state**, dependency injection lewat Riverpod.
4. **Feature-first** di dalam lapisan agar mudah dicari.

## 2. State Management: Riverpod

- Paket: `flutter_riverpod` (+ `riverpod_annotation` / `riverpod_generator` bila dipakai konsisten di seluruh proyek; pilih satu gaya lalu tetap).
- Gunakan `Notifier` / `AsyncNotifier`, bukan `StateNotifier` lama atau `ChangeNotifier`.
- State berbentuk **immutable** (`freezed` atau class `const` dengan `copyWith`).
- Operasi async memakai `AsyncValue` → UI wajib menangani `loading`, `error`, `data` (dan kosong).
- `ref.watch` di `build`, `ref.read` di callback/event. Jangan `ref.read` di `build`.
- Provider untuk dependency (repository, service, database) diletakkan di `providers/` dan di-override pada test.
- Dilarang: state global mutable, singleton manual, `setState` untuk state bisnis.

## 3. Struktur Folder

Mengikuti `kebutuhan-sistem.md` bagian 9, dirinci per fitur:

```
lib/
├── main.dart                  # bootstrap saja (ProviderScope, runApp)
├── app.dart                   # MaterialApp, tema, router
├── core/
│   ├── theme/                 # color scheme, typography, spacing tokens
│   ├── constants/             # app_strings.dart, app_sizes.dart
│   ├── router/                # go_router config
│   ├── errors/                # Failure / AppException
│   └── utils/
├── data/
│   ├── models/                # ScanResult, FruitInfo, Recipe, UserProfile, ChatMessage
│   ├── repositories/          # implementasi akses data
│   └── sources/               # sqlite, firestore, gemini_api, local json
├── services/                  # scan_service (TFLite), chat_service, auth_service, notification_service
├── providers/                 # provider global & notifier per fitur
└── ui/
    ├── screens/<fitur>/       # home, scan, result, chat, history, profile, auth, onboarding
    └── widgets/               # widget reusable lintas layar
assets/
├── models/ (*.tflite, labels.txt)
├── data/ (fruits.json, recipes.json)
└── images/
test/                          # cermin struktur lib/
```

## 4. Aturan Lapisan

| Lapisan | Boleh | Dilarang |
|---|---|---|
| `ui/` | Baca provider, render, navigasi | Akses DB/API/TFLite, logika bisnis |
| `providers/` | Orkestrasi use case, ubah state | Import widget / `BuildContext` |
| `repositories/` | Gabung/transform data dari sources | Import UI / Riverpod |
| `sources/` & `services/` | Bicara ke SDK eksternal | Mengetahui UI atau state |
| `models/` | Data + serialisasi | Logika bisnis berat |

Repository didefinisikan sebagai **abstract class** (kontrak) + implementasi, agar mudah di-mock.

## 5. Clean Code

- **Penamaan**: jelas dan deskriptif (`ripenessLabel`, bukan `rl`). Class `UpperCamelCase`, file `snake_case.dart`, boolean berawalan `is/has/can`.
- **Fungsi kecil**: satu tanggung jawab, idealnya < 30 baris. Early return, hindari nesting > 3.
- **Widget kecil**: pecah menjadi widget class (bukan method `_buildX()`) agar bisa `const` dan di-test. `build` < 80 baris.
- **File < 300 baris**.
- **DRY secukupnya**: ekstrak setelah muncul ke-3 kali, jangan abstraksi prematur.
- **Tanpa magic number/string**: pakai konstanta/token (`AppSpacing.md`, `AppStrings.scanButton`, `kConfidenceThreshold = 0.6`).
- **Null safety ketat**: hindari `!`; gunakan pengecekan eksplisit atau pola `switch`/sealed class.
- **Error handling**: tangkap di lapisan data, ubah jadi `Failure` bertipe, tampilkan pesan ramah di UI. Jangan `catch (_) {}` kosong.
- **Komentar**: jelaskan *kenapa*, bukan *apa*. Wajib pada preprocessing & inferensi. Dokumentasi `///` untuk API publik.
- **Lint**: `flutter_lints` atau `very_good_analysis`; `analysis_options.yaml` ketat dan tidak boleh dilonggarkan demi lulus.
- **Format**: `dart format`, trailing comma konsisten.
- **Import**: relatif dalam paket tidak boleh; gunakan `package:` import, urut (dart, package, project).
- **Const** sebisa mungkin.

## 6. Navigasi & Tema

- Router: `go_router` dengan `StatefulShellRoute` untuk bottom navigation 5 tab.
- Tema Material 3 terpusat di `core/theme/`. Widget **tidak boleh** memakai warna/font/radius literal; ambil dari `Theme.of(context)` atau token.

## 7. TFLite & Data

- `ScanService` menjalankan preprocessing + inferensi di **isolate** (`Isolate.run` / `compute` atau `IsolateInterpreter`).
- `labels.txt` urutannya identik dengan output model; ada test yang memverifikasi jumlah label = dimensi output.
- Confidence < `kConfidenceThreshold` → hasil `ScanOutcome.uncertain`, bukan crash.
- Model data memakai sealed class untuk hasil: `ScanOutcome.success | uncertain | failure`.

## 8. Testing

| Jenis | Cakupan | Wajib untuk |
|---|---|---|
| Unit | notifier, repository, service, parser JSON | semua logika |
| Widget | layar utama (loading/error/kosong/sukses) | layar inti |
| Integration | alur scan → hasil → riwayat | MVP akhir |

Pola: Arrange-Act-Assert, mock via override provider, tidak ada test yang bergantung internet.

## 9. Keamanan & Konfigurasi

- Secret di `.env` (`flutter_dotenv` atau `--dart-define`), `.env` di `.gitignore`, sediakan `.env.example`.
- Validasi input form di UI **dan** notifier.
- Foto hanya lokal kecuali sinkronisasi diaktifkan (NFR-08).

## 10. Git

- Branch: `feat/<id-tugas>-<slug>`, `fix/...`.
- Commit kecil, pesan Conventional Commits (`feat(scan): ...`), **satu tugas = satu commit/PR**.

