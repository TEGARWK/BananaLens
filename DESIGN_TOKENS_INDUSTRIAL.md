# Design Tokens — BananaLens (Editorial Flat Neo-Grid: Ripe Banana & Roasted Cocoa)

> Sistem desain resmi **BananaLens** bergaya **Editorial Flat Neo-Grid** yang terinspirasi dari tata letak *Swiss Editorial Grid* (bersih, datar, tipografi tegas, blok warna kontras tinggi) dengan perpaduan aksen **Ripe Banana Gold** (`#F4C418`) dan **Roasted Cocoa Brown** (`#5C3A21`) — **tanpa** banyak *stroke* tebal dan **tanpa** bayangan keras (*hard offset shadow*) ala Saweria.

---

## 1. Prinsip Desain Inti (Anti-Saweria, Pro-Editorial)

1. **Flat Color-Blocking Over Heavy Strokes:** Hierarki visual dibangun melalui **kontras blok warna solid** (Kuning Pisang, Cokelat Kakao, Krem Hangat, dan Putih Bersih) serta perbedaan tonal permukaan—bukan menumpuk border `1.5–2px` di setiap tombol, chip, dan ikon.
2. **Zero Chunky Offset Shadows:** Seluruh *hard offset drop shadow* (`offset(3,4)`, `offset(0,4)`, `offset(2,2)`) dan *double inner border* dihapus total. Permukaan tetap rata (*flat*), tenang, dan modern.
3. **Warm Banana + Roasted Cocoa Pairing:** Menggantikan kombinasi kuning neon + hitam arang yang terlalu keras dengan **Ripe Banana Gold (`#F4C418`)** yang matang hangat dipadukan **Roasted Cocoa Brown (`#5C3A21`)** dan tinta **Deep Espresso (`#23170F`)** di atas kanvas **Warm Cream Paper (`#FAF7F0`)**.
4. **Crisp Architectural Geometry:** Sudut komponen menggunakan radius ketat dan rapi (`2dp` chip, `6dp` tombol/input, `8dp` kartu, `10dp` hero) menggantikan sudut terlalu membulat (`20–22dp`).
5. **Bold Editorial Typography:** Judul utama dan angka metrik (seperti `98%`, jumlah pindai) memakai **Space Grotesk ExtraBold (`w800`)** dengan *tracking* rapat, dipasangkan **Inter** untuk isi teks yang nyaman dibaca, dan **JetBrains Mono** hanya untuk *micro-label* metadata.

---

## 2. Color Tokens — Aturan Pembagian **60–30–10** (Tanpa Hitam)

### 2.1 Light Mode (*Warm Banana White + Yellow & Cocoa Brown + Leaf Green*)

| Porsi | Token Name | Hex / Value | Peran & Penempatan yang Tepat |
|---|---|---|---|
| **60% Primer** | `lBackground` | `#FFFDF7` | Kanvas utama layar (*Warm Banana White* — putih kekuningan hangat, lega). |
| **60% Primer** | `lSurface` | `#FFFFFF` | Permukaan kartu konten utama (*Pure Crisp White*). |
| **60% Primer** | `lPrimarySoft` | `#FFF6DC` | Permukaan lembut (*Soft Banana Cream*): input field, `SoftButton`, track bar. |
| **60% Primer** | `lBorder` | `#EADCC5` | Garis pemisah tipis `1px` (*Warm Sand Hairline*). |
| **30% Sekunder** | `lPrimary` | `#F4C418` | **Ripe Banana Gold** — Hero Scan Card, `PrimaryButton`, tombol utama. |
| **30% Sekunder** | `lAccent` / `lSurfaceDark` / `lText` / `lOnPrimary` | `#3B2112` | **Dark Chocolate Brown** — pengganti total warna hitam: blok Tips Hari Ini, bar metrik kiri, tombol "Mulai Scan", teks utama, judul, dan stroke ikon (kontras 14.2:1 di atas putih & 9.2:1 di atas kuning — WCAG AAA). |
| **30% Sekunder** | `lAccentWarm` | `#54321D` | *Deep Espresso Brown* — variasi coklat gelap sekunder. |
| **30% Sekunder** | `lMuted` | `#6E5240` | *Dark Cocoa Muted* — teks sekunder & metadata. |
| **10% Aksen** | `lLeafGreen` | `#A3D955` | **Fresh Light Leaf Green** — aksen kesegaran: blok *Mentah* di bar metrik, ikon *Resep Sehat*, 1 dari 3 pisang melayang, ikon *Pengingat Kesegaran*. |
| **10% Aksen** | `lLeafStrong` | `#5D9412` | Hijau daun lebih pekat untuk ikon/teks aksen di atas permukaan terang. |
| **10% Aksen** | `lLeafSoft` | `#EEF7DF` | Tint hijau lembut untuk strip rekomendasi harian & header kartu resep. |

### 2.2 Dark Mode (*Warm Cocoa Night — Tanpa Hitam Pekat*)

| Token Name | Hex / Value | Peran & Penggunaan |
|---|---|---|
| `dBackground` | `#24170E` | Latar utama mode gelap (*Dark Roasted Cocoa*). |
| `dSurface` | `#322015` | Latar kartu mode gelap (*Warm Chocolate*). |
| `dPrimarySoft` | `#3F2A1D` | Latar input & tombol sekunder (*Mocha Surface*). |
| `dPrimary` | `#F4C418` | **Ripe Banana Gold**. |
| `dOnPrimary` | `#4A2C18` | Teks cokelat tua di atas tombol/badge kuning. |
| `dAccent` | `#D49A6A` | **Warm Caramel** — aksen cokelat terang. |
| `dLeafGreen` | `#A3D955` | **Fresh Light Leaf Green** (10% aksen). |
| `dText` | `#FFF9EC` | Teks utama (*Warm Banana Cream*). |
| `dMuted` | `#C8B09A` | Teks sekunder (*Warm Latte*). |
| `dBorder` | `#4D3525` | Garis pemisah tipis `1px` mode gelap. |

### 2.3 Semantic & Ripeness Tokens

| Token Name | Light Hex | Dark Hex | Peran & Penggunaan |
|---|---|---|---|
| `unripe` (Mentah) | `#4F7D2A` | `#8BC34A` | Hijau daun alami yang serasi dengan palet cokelat-krem. |
| `ripe` (Matang) | `#E6B00E` | `#F4C418` | Kuning pisang matang optimal. |
| `overripe` (Terlalu Matang) | `#B86B27` | `#E0964F` | Karamel hangat untuk transisi sangat matang. |
| `rotten` / `error` (Busuk) | `#C43E2B` | `#FF6B57` | Merah bata tegas untuk peringatan keamanan pangan & error. |

---

## 3. Typography Tokens (Tipografi)

| Token Name | Font Family | Ukuran & Weight | Letter Spacing | Penggunaan |
|---|---|---|---|---|
| `pixelDisplayStyle` / `displaySmall` | `Space Grotesk` (`tabular-nums`) | `32–36 sp`, ExtraBold (`w800`) | `-0.8 to -0.9 px` | Angka KPI besar (`98%`, total pindai) dan judul hero bergaya editorial. |
| `headlineLarge` | `Space Grotesk` | `26 sp`, ExtraBold (`w800`) | `-0.6 px` | Judul utama layar & wordmark `BananaLens`. |
| `headlineMedium` | `Space Grotesk` | `22 sp`, ExtraBold (`w800`) | `-0.4 px` | Judul bagian utama dan nama buah pada hasil pindai. |
| `titleLarge` / `titleMedium` | `Space Grotesk` | `15–17 sp`, Bold (`w700`) | `-0.1 to -0.2 px` | Judul AppBar dan judul kartu. |
| `bodyLarge` / `bodyMedium` | `Inter` | `13.5–14.5 sp`, Regular/Medium | `0 px` | Teks isi, deskripsi resep, dan input form. |
| `bodySmall` | `Inter` | `12 sp`, Regular | `0 px` | Keterangan pendukung dan metadata waktu. |
| `labelLarge` | `Space Grotesk` | `13 sp`, Bold (`w700`) | `0.6 px` | Label tombol CTA (`PrimaryButton`, `SoftButton`, `AccentButton`). |
| `labelMedium` / `labelSmall` | `JetBrains Mono` | `10.5–11.5 sp`, SemiBold/Bold | `0.8–0.9 px` | *Eyebrow tag*, kode kategori (`HASIL // PINDAI`), label persentase. |

---

## 4. Radius, Scanner Corner & Stroke Tokens (Minimalist Flat)

| Token / Motif | Nilai / Spesifikasi | Penggunaan |
|---|---|---|
| **`ScannerCornerPainter` (`ScannerCornerStyle`)** | Variasi alami agar tidak repetitif: **`all4`** (`┌ ┐ └ ┘`) untuk elemen fokal scan (Hero Scan, Foto Hasil, Splash), **`diagonal2`** (`┌ ┘`) untuk kartu umum & tips, **`topLeft1` / `topRight1`** (`┌` / `┐`) untuk strip grid & kartu resep, **`none`** untuk blok metrik nyambung. | Memberi nuansa optical scanner yang organik & editorial tanpa mengulang 4 sudut di setiap kotak. |
| **Joined Swiss-Grid Strip** | Kontainer menyatu (`IntrinsicHeight` + `VerticalDivider 1px`) tanpa celah antar-sel (contoh: strip 3 aksi cepat & bar metrik 2-tone Cokelat–Kuning). | Meniru ritme kotak-kotak menyambung yang rapi pada referensi editorial. |
| `rSharp` | `2 dp` | `IndustrialTagChip`, bar progres — **0px stroke, 0px shadow**. |
| `rButton` | `6 dp` | `PrimaryButton`, `SoftButton`, `AccentButton`, input field — **0px stroke (idle), 0px shadow**. |
| `rCard` | `8 dp` | `IndustrialSpecimenCard`, dialog — **4 sudut scanner L-bracket, 0px full stroke, 0px shadow**. |
| `rHero` | `10 dp` | `HomeHeroScanCard` / panel blok warna penuh — **4 sudut scanner L-bracket, 0px shadow**. |
| `rSheet` | `16 dp` | Bottom sheet — **0px shadow, top radius 16dp**. |
| `rPill` | `999 dp` | Hanya untuk indikator lingkaran kecil (avatar/dot). |

---

## 5. Checklist Implementasi

- [x] **Zero Saweria Artifacts:** Tidak ada lagi *hard offset shadow* (`offset(3,4)` / `offset(0,4)`), *double stroke*, maupun tekstur *micro-ribbed* pada komponen inti.
- [x] **Yellow + Cocoa Brown System:** Warna primer `#F4C418` dan aksen cokelat `#5C3A21` / `#8C5A34` terpusat di `AppColors`, `HarvestColors`, dan `AppTheme`.
- [x] **WCAG AAA Contrast:** Kuning + Espresso (`> 11:1`) dan Cokelat Kakao + Krem (`> 9.5:1`) lolos kontras aksesibilitas.
- [x] **Touch Targets:** Seluruh tombol dan input mempertahankan tinggi minimum `48 dp`.
