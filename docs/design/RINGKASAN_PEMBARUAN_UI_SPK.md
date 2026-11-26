# Ringkasan Pembaruan UI/UX, SPK Kontekstual, & Nutrisi Dinamis — BananaLens

> **Tanggal:** Selasa, 24 November 2026  
> **Branch:** `main` (`https://github.com/TEGARWK/BananaLens.git`)  
> **Commit Tercatat:** `005eade`, `819f901`, `44e04cc`

---

## 1. Sistem Desain Baru: 60–30–10 Editorial Datar (Tanpa Hitam)

Seluruh tampilan aplikasi diselaraskan meninggalkan gaya *neo-brutalist* lama (bayangan offset keras & garis tepi gelap tebal) menuju gaya **editorial datar** yang bersih, hangat, dan mudah dibaca dengan aturan warna **60–30–10**:

| Proporsi | Peran | Palet & Kode Hex | Penempatan Utama |
| :--- | :--- | :--- | :--- |
| **60% Primer** | Kanvas & Ruang Bernapas (Putih–Krem Pisang) | `#FFFDF7` (Warm Banana White)<br>`#FFFFFF` (Crisp White)<br>`#FFF6DC` (Soft Banana Cream)<br>`#EADCC5` (Warm Sand Hairline `1px`) | Latar layar, kartu konten, input field, chip tidak aktif, dan garis pemisah tipis. |
| **30% Sekunder** | Identitas Brand (Kuning Pisang & Coklat Gelap — *pengganti total hitam*) | `#F4C418` (Ripe Banana Gold)<br>`#3B2112` (Dark Chocolate — kontras 14.2:1 di putih & 9.2:1 di kuning, WCAG AAA)<br>`#54321D` (Deep Espresso)<br>`#6E5240` (Dark Cocoa Muted) | **Kuning**: tombol utama (CTA), hero scan, tab/chip aktif, aksen kamera scan.<br>**Coklat Gelap**: seluruh teks utama, judul, tombol kirim chat, blok *Tips Hari Ini*, dan teks di atas kuning. |
| **10% Aksen** | Kesegaran Organik (Hijau Daun Pisang) | `#A3D955` (Fresh Light Leaf)<br>`#5D9412` (Strong Leaf Green)<br>`#EEF7DF` (Soft Leaf Tint) | Status *online*, badge `AKUN AKTIF`, badge `Sangat Cocok`, status *Mentah*, checklist bahan resep, ikon *Manfaat Kesehatan* & *Daya Simpan*, serta bar nutrisi *Serat*. |

*Mode gelap (*Dark Chocolate Night*) juga diselaraskan menggunakan dasar coklat gelap hangat (`#21130B` / `#2E1B10` / `#3B2315`) tanpa warna hitam pekat.*

---

## 2. Pembaruan UI di Seluruh Layar Utama

### A. Beranda & Tema Global
- Pembersihan total sisa warna hitam/charcoal (`#2B2B2E`, `#4A4A50`, `Colors.black`) pada `app_colors.dart`, `harvest_colors.dart`, `fruit_vector_icon.dart`, `nutrition_panel.dart`, dan `result_probability_accordion.dart`.
- Memperdalam coklat ke **Dark Chocolate (`#3B2112`)** agar tegas dan elegan.

### B. Bottom Navigation Bar (`main_scaffold_with_nav.dart`)
- Menghapus bayangan keras dan border tebal pada tombol Scan tengah & tab aktif.
- Tab aktif memakai pil datar **Krem Pisang (`#FFF6DC`)** dengan ikon/teks **Coklat Gelap (`#3B2112`)**.
- Tombol Scan tengah tampil datar **Kuning Pisang (`#F4C418`)** dan berubah ke **Coklat Gelap + ring kuning** saat tab Scan aktif.

### C. Tanya AI (`chat_screen.dart`, `chat_bubble.dart`, `chat_composer.dart`, `chat_context_banner.dart`, `chat_history_sheet.dart`)
- Memecah `chat_screen.dart` menjadi widget modular (< 300 baris per file).
- **AppBar**: ikon brand coklat gelap + sparkle kuning, titik status online hijau daun (`ONLINE · ASISTEN AI`, aman dari overflow di layar sempit `360dp`), serta tombol Riwayat & Chat Baru datar.
- **Gelembung Chat**: pesan AI berlatar putih bergaris `1px` dengan indikator hijau daun; pesan User berlatar kuning datar dengan teks coklat gelap.
- **Banner Konteks Pindai**: beraksen hijau daun lembut (`#EEF7DF`) dengan garis aksen kiri `3.5px`.
- **Input & Riwayat**: tombol kirim coklat gelap dengan panah kuning, indikator *Mengetik...* hijau daun, dan bottom sheet riwayat chat bergaya datar.

### D. Halaman Scan (`scan_screen.dart`)
- Seluruh elemen fokus Scan kini berwarna **Kuning Pisang (`#F4C418`)**: 4 sudut viewfinder membulat halus, garis laser naik-turun, tombol shutter dalam, ikon flash aktif, dan indikator pil atas.
- **Perbaikan bug tombol `"X"` (Tutup)**: sebelumnya `context.pop()` tidak merespons saat Scan dibuka dari navbar; kini menggunakan `_closeScanner()` (`context.canPop() ? context.pop() : context.go('/')`) sehingga selalu kembali ke Beranda.

### E. Hasil Pindai (`result_success_view.dart`, `result_state_views.dart`, `ripeness_chip.dart`, `fruitlens_app_bar.dart`, `nutrient_tile.dart`)
- Bingkai foto hasil pindai & animasi laser saat loading memakai 4 sudut membulat **Kuning Pisang**.
- Menghapus border gelap keras pada `RipenessChip`, `NutrientTile`, dan ikon `FruitLensAppBar`.
- Ikon kartu **Manfaat Kesehatan** memakai aksen 10% hijau daun.

### F. Riwayat & Detail Riwayat (`history_screen.dart`, `history_item_card.dart`, `history_detail_screen.dart`, `history_detail_hero_card.dart`, `history_detail_guidance_card.dart`, `history_detail_sheets.dart`)
- Filter chip, kartu item, dialog hapus, foto layar penuh, dan sheet rincian akurasi diselaraskan ke gaya datar.
- **Menambahkan kartu SPK interaktif** langsung di halaman **Detail Riwayat** (tidak hanya di Hasil Pindai).
- Mengganti kartu statis *Saran Konsumsi & Daya Simpan* yang tumpang tindih dengan SPK menjadi kartu ringkas **Manfaat Kesehatan** (seragam dengan Hasil Pindai), sementara peringatan keamanan pangan untuk pisang *Busuk* tetap dipertahankan.

### G. Profil, Pengaturan Akun, & Pemilih Tema (`profile_screen.dart`, `profile_header_card.dart`, `profile_history_card.dart`, `profile_menu_section.dart`, `theme_picker_sheet.dart`, `account_preference_tiles.dart`, `account_settings_sections.dart`)
- Menghapus seluruh bayangan offset & border tebal pada avatar, menu pengaturan, dialog keluar, modal info engine AI, bottom sheet tema, serta pemilih tujuan kesehatan.
- Menambahkan badge hijau daun untuk `AKUN AKTIF` dan ikon centang hijau daun pada opsi terpilih.

### H. Rekomendasi Resep (`scan_recipes_screen.dart`, `recipes_list_screen.dart`, `recipe_detail_screen.dart`)
- Chip preferensi/filter, tombol refresh AI, banner sumber resep, dan nomor langkah memasak dibuat datar rapi.
- Checklist bahan di **Detail Resep** berubah menjadi **Hijau Daun** saat dicentang, dan kartu *Tips Nutrisi Segar* memakai latar hijau daun lembut.

---

## 3. Peningkatan SPK Kontekstual (Hybrid PSO–Random Forest)

Sebelumnya, meskipun 26 pohon Random Forest di `spk_pso_rf_model.json` menghitung ulang skor tiap tombol diklik, teks outputnya hanya 4 template statis sehingga beberapa kombinasi tombol terlihat menampilkan teks yang sama persis.

**Solusi yang diterapkan tanpa mengubah model `.json`:**
- Menambahkan [spk_context_interpreter.dart](lib/services/spk_context_interpreter.dart) yang memetakan kombinasi **Kematangan × Rencana Pakai × Tujuan** di atas keputusan murni PSO-RF menjadi saran spesifik (9 kombinasi unik untuk *Matang*, 6 untuk *Mentah*, 4 untuk *Matang Banget*, dan 1 untuk *Busuk*).
- Memperbarui [spk_recommendation_card.dart](lib/ui/widgets/spk_recommendation_card.dart) dengan:
  - Header **`REKOMENDASI SPK`** + indikator live **`PSO-RF · XX%`**.
  - Badge **Status Kesesuaian**: 🟢 `Sangat Cocok`, 🟡 `Perlu Penyesuaian`, 🔴 `Tidak Disarankan` berdampingan dengan badge kelas asli PSO-RF.
  - Transisi halus `AnimatedSwitcher` agar setiap klik tombol langsung terasa responsif.

---

## 4. Estimasi Gizi Dinamis Sesuai Tingkat Kematangan

Menambahkan [ripeness_nutrition_helper.dart](lib/core/utils/ripeness_nutrition_helper.dart) yang menyesuaikan kandungan gizi per 100 g pisang berdasarkan konversi pati resisten menjadi gula sederhana selama pematangan (diterapkan di **Hasil Pindai** dan **Detail Riwayat**):

| Kematangan | Kalori | Karbohidrat | Gula Alami | Serat Pangan |
| :--- | :---: | :---: | :---: | :---: |
| **Mentah** (`unripe`) | 82 kkal | 21.5 g | 3.5 g | 3.8 g |
| **Matang** (`ripe`) | 89 kkal | 22.8 g | 12.2 g | 2.6 g |
| **Matang Banget** (`overripe`) | 96 kkal | 24.5 g | 16.5 g | 1.8 g |
| **Busuk** (`rotten`) | *Tidak ditampilkan (tidak layak konsumsi)* | — | — | — |

---

## 5. Riwayat Commit & Verifikasi

| Commit | Ringkasan |
| :--- | :--- |
| `005eade` | Redesign seluruh layar (Tema 60–30–10 Coklat Gelap, Beranda, Navbar, Tanya AI, Scan + fix tombol `X`, Hasil Pindai, Riwayat + SPK, Profil & Pengaturan) |
| `819f901` | Penambahan `SpkContextInterpreter` (badge kesesuaian + skor live PSO-RF) & redesign 3 layar Rekomendasi Resep |
| `44e04cc` | Estimasi nutrisi dinamis sesuai kematangan (`RipenessNutritionHelper`), perapian `NutrientTile`, & penyederhanaan kartu Manfaat Kesehatan di Detail Riwayat |

**Verifikasi Teknis:**
- `dart format` ✅
- `flutter analyze` ✅ *(0 warning, 0 error)*
- `flutter test` ✅ *(seluruh unit test & widget test terkait Tema, Beranda, Tanya AI, Scan, Navbar, Hasil Pindai, Riwayat, Profil, Resep, SPK, dan Nutrisi lulus)*
