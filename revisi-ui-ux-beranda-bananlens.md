# BananaLens --- Revisi UI/UX Beranda

**Status:** Draft rekomendasi untuk implementasi\
**Cakupan:** Halaman Beranda mobile-first\
**Tujuan:** Memperjelas informasi, memperkuat alur scan, dan menjaga
konsistensi visual tanpa melakukan redesign besar.

------------------------------------------------------------------------

## 1. Tujuan UX

1.  Membantu pengguna memulai scan pisang dengan cepat.
2.  Membuat statistik mudah dipahami melalui label dan periode yang
    jelas.
3.  Memudahkan pengguna membuka dan memahami hasil scan sebelumnya.
4.  Menampilkan resep yang relevan dengan kematangan pisang.
5.  Menjaga tampilan tetap ringkas, mudah dipindai, dan responsif.

## 2. Struktur Beranda yang disarankan

Urutan konten:

1.  Header: logo, sapaan, dan akses profil.
2.  Hero utama: Pindai Pisang, tombol Scan dan Galeri.
3.  Ringkasan pindai: statistik beserta periode data.
4.  Riwayat Terakhir: hasil scan terbaru dan tautan ke riwayat lengkap.
5.  Resep yang Cocok untuk Pisangmu: rekomendasi kontekstual.
6.  Tips Hari Ini: cuplikan tips dan tautan detail.
7.  Bottom navigation: Beranda, Tanya AI, Scan, Riwayat, Profil.

Pertahankan urutan ini selama belum ada data penggunaan yang menunjukkan
kebutuhan lain.

## 3. Header

### Revisi

-   Gunakan sapaan sesuai waktu lokal perangkat, misalnya "Selamat sore,
    Tegar!".
-   Jika nama belum tersedia, gunakan sapaan umum.
-   Pertahankan logo dan wordmark BananaLens.
-   Jadikan avatar/inisial profil sebagai tombol yang membuka halaman
    Profil.

### Panduan

-   Logo: sekitar 32 × 32 px.
-   Area sentuh profil: minimal 44 × 44 px.
-   Jarak logo ke nama: sekitar 8 px.
-   Pastikan header tidak terlalu tinggi sehingga hero tetap terlihat di
    layar awal.

## 4. Hero Pindai Pisang

### Konten

**Judul:** Pindai Pisang\
**Deskripsi:** Ketahui tingkat kematangan pisang dan temukan rekomendasi
olahan yang cocok.

### Aksi

-   Tombol utama: **Scan Pisang** --- membuka kamera.
-   Tombol sekunder: **Buka Galeri** --- membuka pemilih foto.

Label tombol harus menjelaskan tindakan yang akan terjadi. Jika
implementasi tetap menggunakan "Mulai Scan", pastikan perilakunya jelas
bagi pengguna.

### Interaksi dan keadaan

-   Saat membuka kamera, tampilkan keadaan loading bila diperlukan.
-   Jika izin kamera belum diberikan, jelaskan cara mengaktifkannya.
-   Jika kamera tidak tersedia, sediakan jalur ke Galeri.
-   Setelah foto diambil/dipilih, tampilkan preview sebelum analisis.
-   Sediakan aksi untuk mengambil ulang atau melanjutkan analisis.
-   Cegah tombol ditekan berulang saat proses berlangsung.

### Visual

-   Pertahankan kuning sebagai warna utama hero.
-   Pastikan teks dan tombol memiliki kontras yang memadai.
-   Ilustrasi pisang menjadi pendukung, bukan mengalahkan judul dan CTA.

## 5. Ringkasan Pindai

### Hal yang perlu dipastikan

Sebelum implementasi, tetapkan apakah statistik menunjukkan: - akumulasi
seluruh riwayat scan; - statistik pada periode tertentu; atau - jumlah
pisang dalam koleksi/pemantauan.

Jangan menampilkan angka tanpa konteks periode atau cakupan.

### Revisi UI

-   Judul bagian: **Ringkasan Pindai**.
-   Tambahkan keterangan periode, misalnya "Sepanjang waktu" atau "Hari
    ini", sesuai definisi data.
-   Pertahankan tiga metrik utama: Total Pindai, Siap Santap, dan
    Mentah.
-   Jika kartu statistik dapat difilter, buat seluruh kartu interaktif
    dan arahkan ke Riwayat dengan filter yang sesuai.
-   Pastikan angka berasal dari data tersimpan dan tidak dihitung dari
    data contoh pada produksi.

### Opsional

Tambahkan visual distribusi kematangan hanya jika datanya tersedia dan
membantu pengambilan keputusan. Hindari grafik dekoratif yang tidak
menambah pemahaman.

## 6. Riwayat Terakhir

### Informasi pada item

-   Thumbnail hasil scan.
-   Nama/jenis pisang jika tersedia.
-   Waktu scan.
-   Status kematangan.
-   Confidence model AI, dengan label yang eksplisit.

Contoh format: **Hari ini · 16.30 · Keyakinan 89%**.

Jangan menyebut confidence sebagai persentase kematangan. Jika
confidence tidak tersedia, jangan tampilkan nilai pengganti.

### Interaksi

-   Mengetuk item membuka detail hasil scan.
-   "Lihat semua" membuka halaman Riwayat.
-   Detail hasil dapat memuat foto, status, confidence, waktu, dan
    rekomendasi yang terkait.
-   Aksi hapus/simpan hanya ditampilkan jika fitur tersebut benar-benar
    tersedia.

### Status dan warna

Gunakan warna status secara konsisten: - Mentah: hijau. - Setengah
matang: kuning kehijauan. - Matang: kuning. - Matang banget: oranye. -
Terlalu matang/tidak layak: merah kecokelatan.

Sediakan label teks; jangan mengandalkan warna saja. Sesuaikan istilah
dengan klasifikasi yang benar-benar didukung model.

## 7. Resep Rekomendasi

### Revisi konten

Judul yang disarankan: **Resep yang Cocok untuk Pisangmu**.

Tambahkan keterangan seperti "Rekomendasi berdasarkan hasil scan" hanya
jika rekomendasi memang menggunakan hasil scan pengguna.

### Kartu resep

-   Foto/ilustrasi resep.
-   Nama resep, maksimal dua baris.
-   Durasi.
-   Tingkat kesulitan.
-   Status kematangan yang cocok, bila datanya tersedia.

Jumlah bahan dapat ditampilkan di halaman detail resep agar kartu
Beranda tidak terlalu padat.

### Perilaku

-   Kartu membuka detail resep.
-   "Lihat semua" membuka daftar resep.
-   Jangan mengklaim resep dipersonalisasi jika tidak menggunakan hasil
    scan atau data pengguna.
-   Pastikan rekomendasi sesuai dengan kategori kematangan yang didukung
    basis data resep.

## 8. Tips Hari Ini

### Revisi

-   Tampilkan judul, ringkasan singkat, dan tombol "Baca selengkapnya".
-   Batasi ringkasan menjadi sekitar 2--3 baris.
-   Gunakan kategori bila tersedia, misalnya penyimpanan atau
    pematangan.
-   Pastikan isi tips memiliki dasar yang dapat dipercaya, terutama
    untuk panduan penyimpanan makanan.

## 9. Bottom Navigation

Menu: - Beranda - Tanya AI - Scan - Riwayat - Profil

### Rekomendasi

-   Perlakukan Scan sebagai aksi utama yang langsung membuka kamera,
    bukan halaman kosong.
-   Tampilkan state aktif yang jelas.
-   Gunakan ikon dan label yang konsisten.
-   Pastikan area sentuh minimal 44 × 44 px.
-   Tambahkan ruang bawah pada konten agar tidak tertutup navigasi saat
    di-scroll.
-   Pastikan navigasi tetap berfungsi pada seluruh halaman.

## 10. Design tokens awal

  Token               Nilai
  ------------------- ----------------
  Background          `#FFF9ED`
  Primary             `#FFC914`
  Dark / text utama   `#3B2417`
  Border              `#F5E7D0`
  Success             `#2F7D46`
  Warning             `#C66A28`
  Error               `#B93832`
  Radius kartu        12--16 px
  Radius tombol       10--12 px
  Spacing             Kelipatan 4 px
  Teks isi            14--16 px
  Teks sekunder       12--14 px
  Judul bagian        18--24 px

Nilai ini merupakan titik awal. Periksa kontras teks dan warna status
sebelum finalisasi.

## 11. Responsif dan aksesibilitas

-   Rancang mobile-first dan uji pada lebar sekitar 320 px hingga 430
    px.
-   Pada desktop, gunakan container dengan lebar maksimum dan susun
    bagian dalam beberapa kolom bila sesuai.
-   Jangan sekadar mengecilkan semua komponen untuk desktop.
-   Gunakan ukuran teks yang terbaca dan jangan mengandalkan warna
    sebagai satu-satunya penanda.
-   Pastikan tombol memiliki label yang jelas, fokus keyboard terlihat,
    dan gambar memiliki teks alternatif yang sesuai.
-   Periksa bahwa bottom navigation tidak menutupi konten.

## 12. Prioritas implementasi

### P0 --- Wajib

-   Tetapkan definisi statistik dan periode data.
-   Perjelas aksi Scan dan Galeri.
-   Perjelas label confidence AI.
-   Pastikan item riwayat dan tombol navigasi berfungsi.
-   Tangani loading, error, dan izin kamera.

### P1 --- Disarankan

-   Kontekstualkan rekomendasi resep.
-   Tambahkan empty state untuk pengguna baru.
-   Tambahkan status kamera bila relevan.
-   Perbaiki detail interaksi kartu dan badge.

### P2 --- Pengembangan lanjutan

-   Grafik distribusi kematangan.
-   Koleksi/pemantauan pisang.
-   Pengingat penggunaan pisang.
-   Rekomendasi berdasarkan beberapa hasil scan.

Fitur P2 memerlukan validasi kebutuhan dan dukungan data sebelum
dirancang lebih lanjut.

## 13. Empty state dan error state yang perlu dirancang

-   Belum ada riwayat scan: jelaskan manfaat scan pertama dan tampilkan
    CTA.
-   Belum ada resep yang cocok: tampilkan alternatif atau jelaskan bahwa
    rekomendasi belum tersedia.
-   Kamera ditolak/tidak tersedia: tampilkan instruksi dan tombol
    Galeri.
-   Analisis gagal: jelaskan masalah secara singkat dan sediakan aksi
    coba lagi.
-   Koneksi bermasalah: jelaskan apakah analisis membutuhkan koneksi dan
    apakah foto sudah tersimpan.

## 14. Kriteria penerimaan

Beranda dapat dianggap siap ditinjau ketika: - Pengguna memahami fungsi
tombol Scan dan Galeri tanpa menebak. - Statistik memiliki label dan
cakupan data yang jelas. - Confidence AI tidak tertukar dengan tingkat
kematangan. - Item riwayat membuka detail yang benar. - Resep dan tips
membuka halaman tujuan yang sesuai. - Semua keadaan loading, kosong, dan
error utama telah dirancang. - Tampilan tetap nyaman pada ukuran mobile
dan desktop. - Navigasi tidak menutupi konten dan seluruh kontrol dapat
diakses.

## 15. Keputusan yang masih perlu dikonfirmasi

1.  Statistik Beranda menghitung seluruh riwayat, periode tertentu, atau
    koleksi pisang?
2.  Apakah hasil scan menyimpan confidence model AI?
3.  Apakah rekomendasi resep sudah benar-benar menggunakan hasil scan
    terakhir?
4.  Apakah tombol Scan langsung membuka kamera atau melalui halaman
    pemindaian?
5.  Apakah fitur pemantauan pisang termasuk cakupan produk saat ini?

Keputusan ini perlu dikonfirmasi sebelum detail UI dan kontrak data
difinalisasi.
