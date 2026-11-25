# BananaLens — Revisi UI/UX Halaman Tanya AI

**Status:** Draft untuk implementasi frontend  
**Cakupan:** Halaman Tanya AI, mobile-first

## 1. Tujuan UX
- Memudahkan pengguna memulai pertanyaan.
- Menonjolkan aksi kirim dengan warna utama BananaLens.
- Menyediakan area percakapan yang nyaman dibaca.
- Menjaga input mudah dijangkau, termasuk saat keyboard mobile terbuka.
- Mempertahankan akses ke riwayat dan percakapan baru.

## 2. Struktur halaman
1. AppBar: ikon AI, nama asisten, status, riwayat chat, percakapan baru.
2. Area percakapan:
   - Empty state: pesan sambutan dan kartu pembuka percakapan.
   - Active state: rangkaian pesan pengguna dan AI.
3. Composer/input chat di bagian bawah.
4. Bottom navigation konsisten dengan halaman lain.

## 3. AppBar dan warna ikon
- Ikon AI: background kuning `#FFC914`, ikon cokelat `#3B2417`.
- Tombol kirim: background kuning `#FFC914`, ikon cokelat `#3B2417`.
- Pertahankan identitas cokelat dan krem pada elemen pendukung.
- Pastikan kontras memadai.
- Tombol riwayat membuka daftar percakapan.
- Tombol percakapan baru memulai sesi baru tanpa menghapus percakapan lama.
- Tambahkan label aksesibilitas/tooltip untuk tombol ikon.

## 4. Kartu pembuka percakapan
Pindahkan rekomendasi pertanyaan dari bagian bawah ke area atas, tepat setelah pesan sambutan AI.

**Judul:** “Mau tanya apa hari ini?”

Kartu yang disarankan:
1. **Kematangan Pisang** — “Bagaimana mengetahui pisang sudah matang?”
2. **Resep Pisang** — “Apa yang bisa dibuat dari pisang matang?”
3. **Tips Penyimpanan** — “Bagaimana menyimpan pisang agar awet?”
4. **Tanya Hasil Scan** — “Bantu saya memahami hasil deteksi.”

Sesuaikan prompt dengan kemampuan AI dan fitur yang benar-benar tersedia.

### Layout dan interaksi
- Mobile: dua kolom.
- Desktop: hingga empat kolom jika ruang mencukupi.
- Gunakan ikon sederhana, judul ringkas, dan deskripsi pendek.
- Rekomendasi: menekan kartu langsung mengirim prompt agar hanya perlu satu aksi.
- Setelah percakapan dimulai, kartu pembuka tidak lagi tampil.
- Jangan tampilkan kartu rekomendasi berulang di tengah percakapan.

## 5. Area percakapan
- Pesan pengguna di sisi kanan; pesan AI di sisi kiri.
- Gunakan warna latar konsisten dengan palet BananaLens.
- Jawaban panjang harus mudah dipindai dengan paragraf, heading, dan bullet seperlunya.
- Hindari membungkus jawaban panjang dalam kartu yang terlalu padat.

**Empty state:** tampilkan pesan sambutan dan kartu pembuka; hindari ruang kosong besar tanpa arahan.

**Active state:** tampilkan pesan sesuai urutan, pertahankan konteks jika backend mendukung, dan pastikan pesan terbaru tidak tertutup composer.

## 6. Input / composer
- Placeholder: **“Tanyakan seputar pisang...”**
- Tinggi sekitar 48–52 px; radius 10–12 px.
- Tombol kirim kuning dengan ikon cokelat.
- Composer tetap di bagian bawah area chat.

Perilaku:
- Pesan kosong tidak dapat dikirim.
- Enter mengirim pesan; Shift + Enter membuat baris baru jika multiline didukung.
- Cegah pengiriman berulang yang tidak disengaja.
- Composer tetap terlihat saat keyboard mobile terbuka.
- Saat AI memproses, tampilkan indikator loading.
- Tombol berhenti hanya ditampilkan jika fitur stop-generation tersedia.

## 7. Loading dan error state
**Loading:** tampilkan “AI sedang berpikir...” atau indikator titik; hindari perubahan layout mendadak.

**Error:** tampilkan pesan singkat dan tombol “Coba lagi” jika sesuai. Jangan menghapus pesan pengguna yang gagal diproses. Jelaskan kendala koneksi/konteks sesuai kondisi sistem.

## 8. Riwayat percakapan
- Tombol riwayat membuka daftar percakapan.
- Membuka percakapan lama menampilkan pesan terdahulu.
- Sesi baru tidak menghapus percakapan lama.
- Judul percakapan dapat dibuat dari pesan pertama jika didukung.
- Jangan mengklaim konteks tersimpan jika backend belum mendukungnya.

## 9. Bottom navigation
Pertahankan menu: Beranda, Tanya AI, Scan, Riwayat, Profil.
- State aktif Tanya AI terlihat jelas.
- Scan tetap menjadi aksi utama sesuai keputusan navigasi aplikasi.
- Area sentuh minimal 44 × 44 px.
- Sediakan ruang bawah agar konten tidak tertutup navigasi.
- Pastikan keyboard dan composer tidak bertabrakan dengan bottom navigation.

## 10. Design tokens awal

| Token | Nilai |
|---|---|
| Primary | `#FFC914` |
| Dark / ikon | `#3B2417` |
| Background | `#FFF9ED` |
| Surface | `#FFFFFF` |
| Border | `#F5E7D0` |
| Radius kartu | 12–16 px |
| Radius tombol/input | 10–12 px |
| Spacing | Kelipatan 4 px |
| Teks isi | 14–16 px |
| Teks sekunder | 12–14 px |

Periksa kontras teks, ikon, dan badge sebelum finalisasi.

## 11. Responsif dan aksesibilitas
- Rancang mobile-first; uji lebar 320–430 px.
- Pada desktop, batasi lebar area percakapan agar teks nyaman dibaca.
- Pastikan kontrol dapat digunakan dengan keyboard.
- Berikan label aksesibilitas untuk tombol ikon.
- Jangan mengandalkan warna saja untuk menyampaikan status.
- Periksa layout saat keyboard mobile terbuka.

## 12. Prioritas implementasi

### P0 — Wajib
- Ubah ikon AI dan tombol kirim menjadi kuning dengan ikon cokelat.
- Pindahkan prompt rekomendasi ke atas dalam kartu dua kolom di mobile.
- Pastikan kartu prompt menjalankan aksi yang jelas.
- Pastikan composer tidak tertutup keyboard.
- Implementasikan loading dan error state dasar.
- Pastikan riwayat dan percakapan baru berperilaku benar.

### P1 — Disarankan
- Rapikan format pesan AI yang panjang.
- Tambahkan empty state dan active state konsisten.
- Tingkatkan aksesibilitas tombol ikon.
- Optimalkan layout desktop.

## 13. Kriteria penerimaan
- Ikon AI dan tombol kirim menggunakan warna yang disepakati.
- Kartu rekomendasi tampil di atas composer saat percakapan kosong.
- Menekan kartu mengirim prompt yang sesuai.
- Kartu rekomendasi tidak muncul lagi setelah percakapan dimulai.
- Pesan pengguna dan AI mudah dibedakan.
- Loading dan error state jelas.
- Composer dapat digunakan saat keyboard mobile terbuka.
- Riwayat dan sesi baru tidak menghilangkan percakapan lama.
- Layout nyaman pada mobile dan desktop.

## 14. Hal yang perlu dikonfirmasi saat implementasi
1. Prompt kartu langsung dikirim atau dimasukkan ke input? Rekomendasi: langsung dikirim.
2. Apakah backend mendukung riwayat dan pemulihan konteks?
3. Apakah generasi jawaban dapat dihentikan? Tampilkan tombol berhenti hanya jika didukung.
