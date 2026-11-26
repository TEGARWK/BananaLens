# Update Proposal PM2 — Perubahan Terbaru FruitLens

> Dokumen ini adalah **tambalan (delta)** untuk `proposal-pm2-bahan-mentah.md`. Isi bagian lama yang disebut di kolom "Ganti/Tambah di" dengan teks di bawah ini.
> Status verifikasi (dijalankan 2026-11-18): `flutter analyze` → *No issues found*; `flutter test` → **102 test lulus** (di proposal lama tertulis 87).

---

## 1. Ringkasan Perubahan

| Area | Kondisi di proposal lama | Kondisi sekarang | Ganti/Tambah di |
|---|---|---|---|
| Fitur resep | Resep statis dari `recipes.json` (7 resep) | Resep **dibuat Gemini AI** setelah tombol "Rekomendasi Resep" ditekan, dengan **cadangan lokal** (`recipes.json` kini 12 resep) saat offline/kuota habis | Bab 3 (fitur 7), 4.3, 5.x |
| Keamanan pangan | Tidak ada aturan khusus | **Gating deterministik** setelah scan: busuk → peringatan buang; mentah → saran menunggu + perkiraan hari; tidak ada panggilan AI sebelum tombol ditekan | Bab 3, 4.3 |
| Pilihan selera | Tidak ada | Pengguna memilih **Semua / Makanan / Minuman / Manis / Gurih / Praktis** agar resep AI lebih kreatif & beragam | Bab 3 |
| UX pengguna awam | Teks cenderung teknis | Teks error & label diubah ke bahasa awam (Indonesia), **skeleton loading** (`ShimmerBox`) di layar yang memuat data | Bab 3, 6.x |
| Layar & rute | 15 layar | Rute baru `/scan-recipes` (daftar resep hasil scan) dan `/account-settings` (Pengaturan Akun: data diri, tujuan kesehatan, alergi) | Bab 3 alur penggunaan |
| Pengujian | 87 test | **102 test** lulus, analyze bersih | Bab 4.5, 6.1, 6.3 |

---

## 2. Teks Pengganti — Tabel Fitur (Bab 3), Fitur No. 7

| 7 | **Rekomendasi Resep Cerdas (AI + Cadangan Lokal)** | Setelah scan, tombol **"Rekomendasi Resep"** membuka `ScanRecipesScreen`: resep hasil Gemini AI tampil di atas (diberi penanda **AI**), diikuti resep pilihan dari cadangan lokal. Pengguna dapat memilih selera (Semua/Makanan/Minuman/Manis/Gurih/Praktis) dan memuat ulang untuk variasi baru. Jika offline atau kuota habis, otomatis memakai cadangan lokal disertai pemberitahuan ramah. | **Pelengkap** | **Terimplementasi** |

### Aturan keamanan pangan setelah scan (deterministik, tanpa AI)
| Hasil scan | Perilaku aplikasi |
|---|---|
| Busuk | Peringatan statis "sebaiknya dibuang"; tombol resep tidak ditampilkan |
| Mentah & tidak aman dimakan mentah (`edible_when_unripe = false`) | Saran menunggu matang + perkiraan hari |
| Mentah & boleh dimakan mentah (`edible_when_unripe = true`) | Pengguna boleh menunggu atau melihat resep buah mentah |
| Matang / Matang Banget | Tombol **Rekomendasi Resep** aktif |
| Buah tidak ada di database | Bagian resep disembunyikan |

Alasan desain: keputusan keselamatan tidak diserahkan ke LLM, dan **0 panggilan AI** terjadi sebelum pengguna menekan tombol sehingga kuota API hemat.

---

## 3. Teks Pengganti — Modul LLM (Bab 4.3, poin 2)

Modul LLM kini punya **dua fungsi terpisah**:

1. **Asisten Chat** (`GeminiChatService`) — tidak berubah.
2. **Generator Resep** (`GeminiRecipeService`, implementasi `LiveRecipeGenerator`, memakai `Dio` ke endpoint REST Gemini, terpisah total dari chat):
   - Output resep terstruktur (`Recipe`) sesuai tingkat kematangan buah hasil scan dan preferensi pengguna (`RecipePreference`).
   - Agar tidak monoton: suhu sampling tinggi (`temperature 1.15`, `topP 0.95`), rotasi sudut tema (`_themeAngles`), dan daftar judul yang baru muncul agar tidak diulang (`_recentNames`).
   - Ketahanan: jika model utama (`gemini-3.5-flash-lite`) mengalami error sementara (503/500/429), otomatis mencoba model cadangan (`gemini-2.5-flash-lite`, `gemini-3.5-flash`). Bila semua gagal/offline, `RecipeGatingService` memakai cadangan lokal (SQLite/JSON).
   - Cadangan lokal disaring sesuai pilihan Makanan/Minuman; bila hasil saringan kosong, ditampilkan seluruh cadangan.

Arsitektur: `ScanRecipesScreen` → `scanRecipesProvider` (Riverpod `.family` pada `ScanRecipesArgs`, hasil di-cache per pilihan selera) → `RecipeGatingService` → `LiveRecipeGenerator` / `RecipeRepository`.

---

## 4. Tambahan Alur Penggunaan (Bab 3, langkah 6)

- Di `ResultScreen`: bagian gating menampilkan pesan sesuai kematangan (lihat tabel di atas).
- Menekan **"Rekomendasi Resep"** → `/scan-recipes`: skeleton loading → daftar resep AI (penanda ✨ AI) → "Resep Pilihan Lainnya" (cadangan).
- Chip selera di atas daftar; ikon muat ulang untuk membuat variasi baru.
- **Pengaturan Akun** (`/account-settings`): data diri, tujuan kesehatan, peringatan alergi buah, tema.

---

## 5. Angka yang Perlu Diperbarui di Proposal Lama

- Jumlah test: `87` → **`102`** (Bab 4.4 diagram folder, 4.5, 6.1 Fase 7, 6.3 poin 3).
- Jumlah resep lokal: `7` → **`12`** (Bab 2 "Data Pendukung").
- Jumlah file test: 32 file `*_test.dart` di folder `test/`.
- Fase 7 (Bab 6.1): tambahkan aktivitas "Resep AI + gating keamanan pangan + preferensi selera + penyederhanaan bahasa UI + skeleton loading".
- Risiko (Bab 6.4, no. 3): tambahkan bahwa kuota/offline pada **resep AI** kini ditangani cadangan lokal otomatis, bukan sekadar pesan gagal.

---

## 6. Catatan Kejujuran untuk Laporan

- Status `T-61`/`B-05` di `TASKS.md` masih tertulis `BLOCKED/TODO` padahal `BE-05` (Gemini asli) sudah `DONE` — sebaiknya `TASKS.md` disinkronkan sebelum laporan dikumpulkan.
- Fitur resep AI & gating **belum tercatat** sebagai tugas di `TASKS.md`; tambahkan agar konsisten dengan laporan.
- Verifikasi di perangkat fisik untuk resep AI (kualitas variasi) belum saya jalankan; yang terverifikasi hanya analyze & test otomatis.
- Peringatan model: akurasi kematangan masih khusus **Pisang 3 kelas**; keterbatasan ini tetap berlaku.
