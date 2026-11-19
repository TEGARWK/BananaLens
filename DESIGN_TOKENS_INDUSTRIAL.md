# Design Tokens — BananaLens (Layered Tactile Industrial Minimalism)

> Referensi sistem desain resmi **BananaLens** bergaya **Instrument-Panel / Layered Tactile Industrial Minimalism** dengan aksen **Banana Volt Yellow** (`#F5D51E`), tipografi *pixel-matrix* + *geometric/mono*, serta komponen berlapis (*multi-stroke* & *hard offset depth*).

---

## 1. Prinsip Desain Inti

1. **Layered Tactile Physicality:** Komponen tidak datar polos—kartu, tombol, dan chip menggunakan kombinasi **border luar tegas + highlight stroke dalam + *hard offset depth plate*** agar terasa seperti tombol/panel instrumen fisik.
2. **Banana Volt Yellow Accent:** Kanvas utama memakai *warm alabaster* (`#F5F6F1`) dan tinta arang (`#181A16`), dipadukan aksen kuning cerah **Banana Volt Yellow** (`#F5D51E`) untuk aksi utama, status aktif, bingkai fokus, dan penanda instrumen.
3. **Pixel & Technical Typography:** Judul status utama (`Selamat Datang`, `Buat Profil Sehatmu`, `Lupa Kata Sandi?`) serta readout numerik memakai font *pixel-matrix* (`Silkscreen`), didukung `Space Grotesk` untuk heading, `Inter` untuk body, dan `JetBrains Mono` untuk label teknis.
4. **Purposeful Motion:** Setiap interaksi kunci memiliki umpan balik gerak yang halus dan terukur (*focus tilt* pada input aktif, *horizontal slide* antar mode/layar autentikasi, animasi *pop & sway* pada ilustrasi panduan, dan stempel sukses kuning saat login/register).
5. **Thumb-Zone & Touch-First:** Seluruh tombol utama memiliki tinggi minimal `48 dp` dan jarak antar target sentuh minimal `8 dp`.

---

## 2. Color Tokens (Palet Warna)

### 2.1 Light Mode (Primary — *Technical Paper*)

| Token Name | Hex / Value | Peran & Penggunaan |
|---|---|---|
| `bgCanvas` | `#F5F6F1` | Latar utama layar (*warm alabaster*). |
| `surfaceMuted` | `#EAECE2` | Latar komponen *recessed*: input field idle, tombol sekunder (`SoftButton`), track progress, dan chip netral. |
| `surfaceCard` | `#EBEDE3` | Latar *specimen card* (`IndustrialSpecimenCard`) dengan tekstur garis vertikal halus (*micro-ribbed*). |
| `surfaceElevated` | `#F9FAF6` | Latar bingkai ikon instrumen (`IndustrialBananaMark`) dan input saat aktif (*focused*). |
| `accentPrimary` | `#F5D51E` | **Banana Volt Yellow** — tombol primer, bingkai fokus input, bayangan layer kartu, badge aktif, dan *scan sweep*. |
| `accentPressed` | `#DEC010` | State tekan (*pressed*) / aksen kuning lebih dalam. |
| `accentDisabled` | `#F6EBB0` | State nonaktif pada elemen aksen kuning. |
| `inkPrimary` | `#181A16` | Teks utama, `onPrimary`, border instrumen (`1.5px–2px`), ikon, dan *hard offset depth* tombol utama. |
| `inkBorderMuted` | `#4A4E42` | Border luar kartu specimen (`1.5px`) agar tidak hanya hitam pekat. |
| `inkSecondary` | `#6B7062` | Label metadata sekunder, divider label, dan border tombol sekunder (`1.4px`). |
| `borderHairline` | `#D8DBD0` | Garis pemisah tipis (`1px`), border input idle, dan *depth lip* tombol sekunder. |
| `trackInactive` | `#D4D7CC` | Bagian *unfilled* pada dial dan progress bar. |

### 2.2 Dark Mode (*Night Instrument*)

| Token Name | Hex / Value | Peran & Penggunaan |
|---|---|---|
| `dBackground` | `#121310` | Latar utama mode gelap. |
| `dSurface` | `#1B1D18` | Latar kartu specimen mode gelap. |
| `dPrimarySoft` | `#262821` | Latar input & tombol sekunder mode gelap. |
| `dPrimary` | `#F5D51E` | Aksen kuning utama (*Banana Volt Yellow*). |
| `dOnPrimary` | `#181A16` | Teks di atas tombol/badge kuning. |
| `dText` | `#F2F3EE` | Teks utama mode gelap. |
| `dMuted` | `#9A9F90` | Teks metadata mode gelap. |
| `dBorder` | `#31342B` | Garis pemisah & border mode gelap. |

### 2.3 Semantic & Feedback Tokens

| Token Name | Hex / Value | Peran & Penggunaan |
|---|---|---|
| `statusSuccess` | `#4E7A27` | Status aman / buah matang optimal. |
| `statusWarning` | `#C77D1A` | Peringatan perhatian / keyakinan rendah. |
| `statusDanger` | `#C43E2B` (Light) / `#FF6B57` (Dark) | Error banner (`1.5px` border) & peringatan kritis. |
| `overlayScrim` | `rgba(24, 26, 22, 0.25)` | Latar redup singkat untuk stempel overlay sukses autentikasi. |

---

## 3. Typography Tokens (Tipografi)

| Token Name | Font Family | Ukuran & Weight | Letter Spacing & Case | Penggunaan |
|---|---|---|---|---|
| `displayPixel` | `Silkscreen` (`tabular-nums`) | `19–36 sp`, Bold (`w700`) | `1.2 px`, Sentence/Display | Judul status Auth (`Selamat Datang`, `Buat Profil Sehatmu`, `Lupa Kata Sandi?`), stempel sukses (`16 sp`), dan readout angka (`36 sp`). |
| `headlineLarge` | `Space Grotesk` | `26–32 sp`, Bold (`w700–w800`) | `-0.4 to -0.6 px` | Wordmark `BananaLens` di Splash dan heading besar. |
| `headlineSmall` | `Space Grotesk` | `19 sp`, Bold (`w700–w800`) | `-0.25 px` | Judul slide Onboarding. |
| `titleLarge` / `titleMedium` | `Space Grotesk` | `15–17 sp`, Bold (`w700`) | `-0.1 to -0.2 px` | Judul AppBar dan sub-judul kartu. |
| `bodyLarge` / `bodyMedium` | `Inter` | `13.5–14.5 sp`, Regular/Medium | `0 px` | Teks input, deskripsi slide, dan teks tombol link. |
| `bodySmall` | `Inter` | `12 sp`, Regular | `0 px` | Sub-judul deskriptif di Auth & Lupa Kata Sandi. |
| `labelLarge` / `labelMedium` | `JetBrains Mono` | `11.5–12.5 sp`, Bold (`w600–w700`) | `1.0–1.1 px` | Label tombol CTA dan link sekunder. |
| `labelSmall` | `JetBrains Mono` | `10.5 sp`, Bold (`w600–w700`) | `1.0–1.4 px`, **UPPERCASE** | Label field input (`EMAIL`, `KATA SANDI`), tag chip (`MOD-AUTH // MASUK`), dan badge splash. |

---

## 4. Spacing Tokens (Skala Spasi & Ergonomi Mobile)

| Token Name | Nilai (`dp`) | Penggunaan |
|---|---|---|
| `s4` (`xs`) | `4` | Jarak mikro antar elemen rapat. |
| `s8` (`sm`) | `8` | Gap minimum antar target sentuh dan jarak vertikal kecil. |
| `s12` | `12` | Padding tag chip & divider autentikasi. |
| `s16` (`md`) | `16` | Padding internal kartu/tombol & jarak antar field form. |
| `s20` | `20` | Margin horizontal layar (`screenPadding`) dan padding `AuthHeader`. |
| `s24` (`lg`) | `24` | Jarak antar blok utama dan padding vertikal kartu panduan. |
| `s32` | `32` | Ruang napas atas/bawah di Splash Screen. |
| `touchMin` | `48` | Tinggi minimum area sentuh (`PrimaryButton`, `SoftButton`, field input). |

---

## 5. Radius Tokens (Hirarki Sudut)

| Token Name | Nilai (`dp`) | Penggunaan |
|---|---|---|
| `rSharp` | `4` | `IndustrialTagChip`, indikator step Onboarding, progress bar Splash. |
| `rButton` / `md` | `12–14` | `PrimaryButton`, `SoftButton`, `AppTextField`, bingkai `IndustrialBananaMark`. |
| `rCard` | `20` | `IndustrialSpecimenCard`, kartu stempel sukses Auth, card splash emblem. |
| `rHero` | `22` | Kartu hero utama. |
| `rSheet` | `28` | Bottom sheet. |
| `rPill` | `999` | Elemen kapsul / pill penuh. |

---

## 6. Layered Border, Stroke & Shadow Tokens

| Komponen / Token | Layering & Spesifikasi Stroke / Shadow |
|---|---|
| **`PrimaryButton`** | Fill `#F5D51E` + outer border `1.5px #181A16` + inner highlight border `1.2px rgba(255,255,255,0.55)` + hard offset plate `(0, 4)` `#181A16` + soft drop shadow `(0, 6)` blur `10`. |
| **`SoftButton`** | Fill `#EAECE2` + outer border `1.4px #6B7062` + bottom depth lip `(0, 3)` `#D8DBD0`. |
| **`IndustrialSpecimenCard`** | Fill `#EBEDE3` + tekstur vertikal *micro-ribbed* + outer border `1.5px #4A4E42` + inner highlight `1.2px` putih + hard offset plate `(3, 4)` `#F5D51E`. |
| **`IndustrialBananaMark`** | Fill `#F9FAF6` + outer border `1.5px #181A16` + inner accent border `1.2px #F5D51E` + hard offset plate `(2.5, 2.5)` `#F5D51E`. |
| **`IndustrialTagChip`** | Fill `#F5D51E` (atau `#EAECE2`) + border `1.4px #181A16` (atau `#6B7062`) + hard offset shadow `(2, 2)`. |
| **`AppTextField` (Focused)** | Outer frame `2.5px #F5D51E` + solid bottom lip `(0, 3)` `#F5D51E` + inner border `1.5px #181A16` + fill `#EBEDE3`/`#F9FAF6`. |
| **`AuthErrorBanner`** | Fill `errorContainer` + border `1.5px #C43E2B` + radius `14dp`. |

---

## 7. Motion & Interaction Tokens

| Interaksi | Spesifikasi Animasi |
|---|---|
| **Active Input Field (`AppTextField`)** | `TweenAnimationBuilder` `220ms` (`Curves.easeOutCubic`): rotasi miring halus `-0.014 rad` dan skala `1.012` saat fokus aktif. |
| **Login ↔ Register (`AuthScreen` & `AuthHeader`)** | `AnimatedSize` + `AnimatedSwitcher` `280ms` (`Curves.easeOutCubic` / `easeInCubic`): *horizontal slide* kiri/kanan sesuai arah perpindahan mode. |
| **Login ↔ Lupa Sandi (`app_router.dart`)** | `CustomTransitionPage` `300ms` (`Curves.easeOutCubic`): *horizontal slide* masuk dari kanan dan keluar ke kiri. |
| **Onboarding Illustration** | `_AnimatedIllustrationFrame` `850ms` per slide: *pop-in* (`easeOutBack`), *vertical lift* `14dp`, dan *sway tilt* halus (`-0.035 rad` → `0`). |
| **Login/Register Success Overlay** | `showAuthSuccessOverlay` `750ms`: stempel kuning `Berhasil Masuk` / `Akun Dibuat` dengan `easeOutBack` pop-in dan fade-out otomatis. |
| **Splash Choreography** | `3400ms`: *dial radial ticks*, L-bracket *viewfinder*, sapuan scan kuning vertikal, dan progress bar berbingkai (mendukung *reduced motion*). |

---

## 8. Checklist Implementasi (Flutter & Mobile UX)

- [x] **No Hardcoded Brand Values:** Warna, radius, dan tipografi terpusat di `AppColors`, `AppDimens`, `AppTheme`, dan `HarvestColors`.
- [x] **Kontras Terjamin:** Teks link sekunder (`Sudah punya akun? Masuk di sini`, `Lupa kata sandi?`, `Daftar di sini`) menggunakan `colorScheme.onSurface` + underline agar selalu terbaca jelas di latar terang.
- [x] **Touch Targets:** Semua tombol CTA dan input memenuhi minimal `48 dp`.
- [x] **Reduced Motion Safe:** Animasi splash dan panduan menghormati `MediaQuery.disableAnimationsOf(context)`.
