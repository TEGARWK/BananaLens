# DESIGN_RULES.md — Aturan Tampilan (Anti AI Slop)

> Wajib dibaca sebelum menyentuh UI. Gunakan skill **taste-skill** + `frontend-ui-engineering`.
> Lokasi skill taste: `C:\Users\tegar\.agents\skills\taste-skill\SKILL.md`
> (varian: `minimalist-skill`, `soft-skill`, `imagegen-frontend-mobile`, `redesign-skill`).

## 1. Identitas Visual FruitLens

Dari `prd.md` bagian 10: hijau segar + aksen oranye, latar terang bersih, Material 3, tombol Scan menonjol di tengah.
Karakter: **segar, bersih, hangat, informatif**, seperti aplikasi buatan desainer, bukan template.

## 2. Token Desain (satu tempat: `core/theme/`)

- **Warna**: seed hijau (mis. sekitar `#2E7D32`–`#3F9B4A`, tentukan sekali), aksen oranye, netral hangat (bukan abu biru murni). Semantik kematangan: mentah, matang, terlalu matang, busuk, masing-masing punya warna **dan ikon**.
- **Tipografi**: maksimal 2 keluarga font; hierarki jelas (display, title, body, label). Pilih font dengan karakter, hindari default Roboto polos untuk judul.
- **Spacing**: skala 4/8 (`AppSpacing.xs…xl`). **Radius**: skala konsisten (`AppRadius`).
- **Elevasi**: bayangan lembut, rendah, konsisten.
- Mode gelap disiapkan lewat `ColorScheme` yang sama (FR-30, Could).

## 3. Prinsip

1. **Hierarki dulu**: satu aksi utama per layar, jelas secara visual.
2. **Ruang napas**: padding lega, jangan padat.
3. **Konten nyata**: foto buah, data nutrisi, copy Indonesia yang natural. Tanpa lorem ipsum.
4. **Konsistensi**: komponen yang sama tampil sama di semua layar.
5. **Fungsi di atas dekorasi**: setiap elemen punya alasan.
6. **Aksesibilitas**: kontras ≥ WCAG AA, target sentuh ≥ 48dp, status tidak hanya lewat warna, mendukung font scaling, `Semantics` pada ikon/gambar.
7. **Gerak bermakna**: transisi 150–300 ms, easing natural, tampilkan loading yang informatif (skeleton/shimmer), hormati reduce-motion.

## 4. Larangan "AI Slop"

- ❌ Gradasi ungu-biru / neon generik, glassmorphism berlebihan
- ❌ Semua elemen berupa kartu bertumpuk dengan bayangan sama
- ❌ Emoji sebagai pengganti ikon (kecuali konten yang memang emoji); pakai set ikon konsisten
- ❌ Ikon dekoratif tak bermakna, ilustrasi stok generik
- ❌ Teks marketing klise ("Revolusioner", "Tingkatkan pengalamanmu")
- ❌ Layout simetris membosankan dengan semua elemen rata tengah
- ❌ Warna/ukuran hardcode di widget
- ❌ Angka/nama palsu ("John Doe", "99.9%")
- ❌ Tombol/aksi yang tidak berfungsi
- ❌ Bottom nav dengan 5 ikon identik tanpa penekanan pada Scan
- ❌ Empty state berupa teks polos saja

## 5. Pedoman Per Layar (ringkas)

| Layar | Fokus desain |
|---|---|
| Onboarding | 3 slide, satu pesan per slide, ilustrasi/foto buah berkarakter |
| Beranda | Tombol scan dominan, tips harian informatif, riwayat terbaru ringkas |
| Scan | Preview penuh, overlay panduan framing, shutter besar, galeri sekunder |
| Hasil | Foto + nama + badge kematangan jelas; nutrisi sebagai grid/ bar yang mudah dipindai; 3 aksi utama |
| Chatbot | Bubble dibedakan jelas, chip saran, indikator mengetik |
| Riwayat | Thumbnail, hierarki nama/kematangan/tanggal; swipe hapus + konfirmasi |
| Profil | Form bersih, validasi inline |

Setiap layar punya desain untuk: **loading, error, kosong, sukses**.

## 6. Checklist Self-Check (wajib sebelum lapor selesai)

- [ ] Hanya memakai token tema (tidak ada warna/font/radius literal)
- [ ] Ada satu titik fokus per layar
- [ ] Empty/error/loading state dirancang, bukan sekadar teks
- [ ] Kontras & ukuran sentuh lolos
- [ ] Copy Indonesia natural, tanpa klise
- [ ] Tidak ada item di daftar larangan bagian 4
- [ ] Tampil baik di layar kecil (360dp) dan besar, serta font scale 1.3
- [ ] Bila memungkinkan, jalankan app/screenshot dan tinjau hasil nyata

## 7. Alur Kerja UI

1. Baca skill taste → tentukan arah visual singkat (3 kalimat).
2. (Opsional) buat referensi desain via skill/tool desain (Stitch, Figma) bila user menghendaki.
3. Bangun komponen di `ui/widgets/`, rakit di `ui/screens/`.
4. Tinjau hasil nyata, perbaiki, lalu jalankan checklist bagian 6.

