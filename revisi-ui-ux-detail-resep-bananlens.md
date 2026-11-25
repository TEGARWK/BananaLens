# BananaLens — Revisi UI/UX Detail Resep

**Status:** Rekomendasi implementasi frontend  
**Cakupan:** `RecipeDetailScreen` / route `/recipe-detail`  
**Konteks:** Resep lokal dan resep AI sama-sama berisi nama, bahan, dan langkah. Belum tersedia gambar resep.

## 1. Tujuan
- Membuat detail resep mudah dibaca dan digunakan saat memasak.
- Menjaga satu pola UI untuk resep lokal maupun AI.
- Menampilkan sumber resep secara jelas.
- Tidak mewajibkan gambar resep.
- Memisahkan peningkatan UI dari kebutuhan data/backend.

## 2. Prinsip desain
- Gunakan satu halaman detail untuk resep lokal dan AI.
- Bedakan sumber dengan badge **Resep Lokal** dan **Resep AI**.
- Jangan tampilkan foto makanan yang belum terverifikasi sesuai resep.
- Jika tidak ada gambar, gunakan placeholder/ilustrasi netral BananaLens.
- Tampilkan hanya metadata yang tersedia; jangan mengarang waktu, kesulitan, porsi, atau durasi langkah.

## 3. Struktur halaman
1. AppBar: tombol kembali dan aksi yang memang tersedia.
2. Header: judul resep, badge sumber, deskripsi jika tersedia.
3. Ringkasan metadata: waktu, kesulitan, porsi—hanya jika tersedia.
4. Catatan keamanan—hanya jika relevan dan tervalidasi.
5. Bahan-bahan.
6. Langkah pembuatan.
7. Aksi tambahan yang didukung, misalnya simpan atau mulai memasak.

## 4. Identitas sumber
### Resep lokal
- Badge **Resep Lokal** atau **Resep BananaLens**.
- Gunakan istilah “terkurasi” hanya jika status `is_reviewed` memang tersedia dan sesuai.
- Gunakan placeholder netral bila tidak ada gambar.

### Resep AI
- Badge **Resep AI**.
- Jangan mengklaim resep dibuat berdasarkan scan tertentu kecuali hubungan itu tersedia pada data.
- Gunakan placeholder netral; jangan memakai gambar resep lain sebagai representasi hasil AI.
- Jika tersedia aksi generate variasi, tampilkan loading dan error state.

## 5. Bahan-bahan
- Tampilkan nama, kuantitas, dan satuan sesuai data.
- Gunakan checkbox dengan area sentuh yang nyaman.
- Progress seperti “3 dari 7 bahan disiapkan” hanya jika jumlah bahan dapat dihitung akurat.
- Aksi “Salin daftar bahan” hanya jika clipboard benar-benar diimplementasikan.
- Pengaturan porsi dinamis memerlukan jumlah dan satuan terstruktur. Jangan mengalikan teks bebas.
- Jangan menambah bahan atau kuantitas yang tidak ada pada resep.

## 6. Langkah pembuatan
### Mode baca (dasar)
- Tampilkan seluruh langkah dalam urutan asli dengan nomor yang jelas.
- Jaga lebar teks dan jarak antar langkah agar mudah dibaca.
- Jangan mengubah instruksi resep secara diam-diam.

### Mode memasak (opsional)
- **Mulai Memasak** membuka satu langkah per layar.
- Tampilkan “Langkah X dari Y”, progress, dan tombol Sebelumnya/Berikutnya.
- Langkah terakhir menyediakan aksi Selesai.
- Dapat digunakan untuk resep lokal dan AI selama langkah tersedia.
- Pengguna dapat kembali ke mode baca tanpa kehilangan posisi.

## 7. Timer
- Tampilkan timer hanya jika durasi disebutkan eksplisit dalam data langkah.
- Jangan menebak durasi dari instruksi.
- Timer lokal sederhana dapat menjadi peningkatan frontend.
- Jika belum didukung, jangan tampilkan tombol timer dekoratif.

## 8. Catatan keamanan
- Tampilkan hanya jika ada catatan relevan dan bersumber.
- Gunakan tampilan informatif, bukan seperti error.
- Jangan membuat klaim keamanan pangan hanya dari nama atau kategori resep.
- Untuk resep AI, pertimbangkan validasi/peringatan yang sesuai sebelum menyajikan instruksi sebagai panduan memasak.

## 9. Keadaan UI
- **Loading:** skeleton atau indikator saat detail dimuat.
- **Data tidak tersedia:** pesan jelas dan aksi kembali.
- **Metadata opsional kosong:** sembunyikan bagian tersebut, jangan tampilkan nilai palsu.
- **Generate variasi AI:** pertahankan resep saat ini selama proses; jika gagal, tampilkan pesan dan opsi coba lagi.
- **Checklist bahan:** pertahankan state selama pengguna berada di halaman; persistensi setelah keluar hanya jika didukung.

## 10. Design tokens awal

| Token | Nilai |
|---|---|
| Primary | `#FFC914` |
| Dark / teks utama | `#3B2417` |
| Background | `#FFF9ED` |
| Surface | `#FFFFFF` |
| Border | `#F5E7D0` |
| Radius kartu | 12–16 px |
| Spacing | Kelipatan 4 px |
| Teks isi | 14–16 px |
| Teks sekunder | 12–14 px |

Gunakan badge dengan teks; jangan mengandalkan warna saja.

## 11. Prioritas implementasi
### P0 — Wajib
- Satu layout detail untuk resep lokal dan AI.
- Badge sumber yang benar.
- Hilangkan asumsi bahwa gambar tersedia.
- Rapikan hierarki judul, bahan, dan langkah.
- Tampilkan metadata hanya jika tersedia.
- Pastikan navigasi kembali berfungsi.

### P1 — Disarankan
- Checklist bahan dengan progress.
- Salin daftar bahan jika didukung.
- Loading, error, dan data kosong yang konsisten.
- Aksi generate variasi AI dengan state jelas, jika tersedia di halaman ini.

### P2 — Pengembangan lanjutan
- Mode memasak satu langkah per layar.
- Timer untuk durasi langkah eksplisit.
- Pengaturan porsi dinamis setelah data mendukung jumlah dan satuan.
- Gambar resep tervalidasi atau fitur pembuatan gambar terpisah.

## 12. Data/backend yang perlu diperiksa
Verifikasi apakah model resep menyediakan:
- sumber resep (lokal atau AI);
- bahan dan langkah sebagai daftar terstruktur;
- waktu, kesulitan, porsi, dan durasi langkah;
- catatan keamanan;
- identitas resep tersimpan untuk bookmark/riwayat.

Jangan mengasumsikan field tersebut tersedia. Jika belum, tandai sebagai kebutuhan terpisah.

## 13. Kriteria penerimaan
- Resep lokal dan AI menggunakan layout konsisten.
- Sumber resep ditampilkan benar.
- Tidak ada gambar makanan yang tidak sesuai atau tidak terverifikasi.
- Bahan dan langkah tampil sesuai isi serta urutan data.
- Metadata yang tidak tersedia tidak ditampilkan sebagai nilai buatan.
- Checklist berfungsi tanpa mengubah data resep.
- Loading, data kosong, dan error ditangani.
- Tampilan nyaman pada mobile dan desktop.
