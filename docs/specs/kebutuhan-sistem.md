# Kebutuhan Sistem: FruitLens (nama sementara)

> Aplikasi mobile pemindai buah berbasis Visi Komputer dan AI.
> Proyek tugas besar gabungan: Pemrograman Mobile 2, Visi Komputer, dan Kecerdasan Buatan.

## 0. Asumsi (ubah sesuai kondisi kelompok)

- Framework: **Flutter (Dart)**
- Model on-device: **TensorFlow Lite**
- Backend: **Firebase** (Auth, Firestore, Storage)
- AI chatbot: **Gemini API** (atau LLM API lain)
- Platform target: **Android** (iOS opsional)
- Dataset awal: Fruits-360 (Kaggle) + foto tambahan sendiri untuk kematangan

---

## 1. Ringkasan Sistem

Pengguna memotret buah. Sistem mendeteksi **jenis buah** dan **tingkat kematangan**, menampilkan **informasi nutrisi**, memberi **rekomendasi resep**, dan menyediakan **chatbot AI** untuk tanya jawab seputar buah. Hasil scan tersimpan sebagai riwayat.

### Pemetaan ke mata kuliah

| Mata Kuliah | Bentuk Implementasi |
|---|---|
| Pemrograman Mobile 2 | Kamera, navigasi, state management, database lokal, REST API, Firebase, notifikasi |
| Visi Komputer | Preprocessing citra, klasifikasi/deteksi buah, klasifikasi kematangan, inferensi TFLite |
| Kecerdasan Buatan | Model deep learning (CNN/transfer learning), chatbot LLM, rekomendasi resep dan saran personal |

---

## 2. Kebutuhan Fungsional

Prioritas: **M** = Must, **S** = Should, **C** = Could

### 2.1 Autentikasi dan Profil
| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-01 | Pengguna dapat registrasi dan login dengan email/password | M |
| FR-02 | Pengguna dapat login dengan Google | S |
| FR-03 | Pengguna dapat logout | M |
| FR-04 | Pengguna dapat mengisi profil: nama, usia, berat badan, tujuan (diet/bulking/sehat), alergi | S |
| FR-05 | Pengguna dapat mengubah profil | S |

### 2.2 Scan Buah
| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-06 | Aplikasi meminta izin kamera dan menangani kasus ditolak | M |
| FR-07 | Pengguna dapat mengambil foto lewat kamera | M |
| FR-08 | Pengguna dapat memilih foto dari galeri | M |
| FR-09 | Sistem mendeteksi jenis buah dan menampilkan nama + confidence | M |
| FR-10 | Sistem mengklasifikasi kematangan: mentah / matang / terlalu matang / busuk | M |
| FR-11 | Jika confidence di bawah ambang (default 60%), tampilkan pesan "tidak yakin" dan saran foto ulang | M |
| FR-12 | Sistem dapat mendeteksi beberapa buah dalam satu gambar (bounding box) | C |
| FR-13 | Scan real-time dari preview kamera (live detection) | C |

### 2.3 Informasi Buah
| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-14 | Tampilkan info nutrisi per 100 g (kalori, karbohidrat, gula, serat, vitamin utama) | M |
| FR-15 | Tampilkan manfaat kesehatan dan tips penyimpanan | S |
| FR-16 | Tampilkan peringatan jika buah cocok/tidak cocok dengan alergi atau tujuan di profil | S |
| FR-17 | Kalkulator kalori berdasarkan berat yang diinput pengguna | C |

### 2.4 Fitur AI
| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-18 | Chatbot menjawab pertanyaan seputar buah dalam Bahasa Indonesia | M |
| FR-19 | Chatbot menerima konteks hasil scan terakhir (jenis, kematangan) | S |
| FR-20 | Sistem merekomendasikan resep berdasarkan buah dan kematangan | S |
| FR-21 | Riwayat percakapan chatbot tersimpan per pengguna | C |

### 2.5 Riwayat dan Koleksi
| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-22 | Setiap hasil scan tersimpan lokal: foto, jenis, kematangan, confidence, waktu | M |
| FR-23 | Pengguna dapat melihat daftar dan detail riwayat | M |
| FR-24 | Pengguna dapat menghapus riwayat | M |
| FR-25 | Pengguna dapat mencari dan memfilter riwayat (jenis buah, tanggal) | S |
| FR-26 | Pengguna dapat menandai buah/resep sebagai favorit | S |
| FR-27 | Riwayat disinkronkan ke cloud (Firestore) ketika online | C |

### 2.6 Pendukung
| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-28 | Scan tetap berfungsi tanpa internet (model on-device) | M |
| FR-29 | Notifikasi pengingat buah tersimpan yang mendekati busuk | C |
| FR-30 | Dark mode | C |
| FR-31 | Onboarding singkat saat pertama kali membuka aplikasi | S |

---

## 3. Kebutuhan Non-Fungsional

| ID | Kategori | Kebutuhan |
|---|---|---|
| NFR-01 | Performa | Waktu inferensi satu gambar ≤ 2 detik pada perangkat Android menengah |
| NFR-02 | Akurasi | Akurasi klasifikasi jenis buah ≥ 90% pada data uji; kematangan ≥ 80% |
| NFR-03 | Ukuran | Model TFLite ≤ 25 MB; APK ≤ 100 MB |
| NFR-04 | Kompatibilitas | Android 8.0 (API 26) ke atas |
| NFR-05 | Usability | Alur scan selesai dalam ≤ 3 ketuk dari beranda |
| NFR-06 | Reliabilitas | Aplikasi tidak crash saat izin ditolak, tidak ada internet, atau gambar buram |
| NFR-07 | Keamanan | API key tidak di-hardcode di repositori (gunakan `.env` / secret config) |
| NFR-08 | Privasi | Foto hanya disimpan di perangkat kecuali pengguna mengaktifkan sinkronisasi |
| NFR-09 | Bahasa | Antarmuka Bahasa Indonesia |
| NFR-10 | Kode | Struktur modular dan mudah dibaca, memakai pola arsitektur yang konsisten |

---

## 4. Arsitektur

```
┌──────────────────────── Aplikasi Flutter ────────────────────────┐
│  UI (Screens/Widgets)                                            │
│        │                                                         │
│  State Management (Provider / Riverpod / Bloc)                   │
│        │                                                         │
│  Domain / Services                                               │
│   ├─ ScanService ──► TFLite (model jenis + model kematangan)     │
│   ├─ ChatService ──► Gemini API (HTTP)                           │
│   ├─ FruitInfoRepository ──► JSON/SQLite lokal (nutrisi, resep)  │
│   ├─ HistoryRepository ──► SQLite (sqflite/drift)                │
│   └─ AuthService ──► Firebase Auth                               │
│        │                                                         │
│  Sinkronisasi opsional ──► Firestore + Storage                   │
└──────────────────────────────────────────────────────────────────┘
```

### Alur scan

1. Pengguna ambil/pilih gambar
2. Preprocessing: resize (mis. 224×224), normalisasi piksel
3. Inferensi TFLite model jenis buah, lalu model kematangan
4. Ambil label dengan confidence tertinggi
5. Cari info nutrisi dan resep dari data lokal berdasarkan label
6. Tampilkan hasil dan simpan ke riwayat

---

## 5. Teknologi

| Lapisan | Pilihan |
|---|---|
| Framework | Flutter 3.x |
| State management | Riverpod atau Provider (pilih satu) |
| Kamera/gambar | `camera`, `image_picker` |
| Inferensi | `tflite_flutter` |
| Database lokal | `sqflite` atau `drift` |
| Backend | Firebase Auth, Firestore, Storage |
| HTTP | `dio` atau `http` |
| Chatbot | Gemini API (`google_generative_ai`) |
| Notifikasi | `flutter_local_notifications` |
| Pelatihan model | Python, TensorFlow/Keras, Google Colab |
| Model dasar | MobileNetV2 / EfficientNet-Lite (klasifikasi), YOLOv8n (deteksi, opsional) |

---

## 6. Model Data

### ScanResult (SQLite)
| Field | Tipe | Keterangan |
|---|---|---|
| id | INTEGER PK | auto increment |
| image_path | TEXT | lokasi foto di perangkat |
| fruit_label | TEXT | contoh: `apple` |
| ripeness_label | TEXT | `unripe` / `ripe` / `overripe` / `rotten` |
| confidence | REAL | 0.0 – 1.0 |
| created_at | TEXT | ISO 8601 |
| is_favorite | INTEGER | 0/1 |
| synced | INTEGER | 0/1 |

### FruitInfo (JSON/SQLite, data statis)
| Field | Tipe |
|---|---|
| label | TEXT |
| name_id | TEXT (nama Indonesia) |
| calories | REAL |
| carbs | REAL |
| sugar | REAL |
| fiber | REAL |
| vitamins | TEXT |
| benefits | TEXT |
| storage_tips | TEXT |
| allergen_note | TEXT |

### Recipe (JSON/SQLite, data statis)
| Field | Tipe |
|---|---|
| id | INTEGER |
| title | TEXT |
| fruit_label | TEXT |
| suitable_ripeness | TEXT (daftar) |
| ingredients | TEXT |
| steps | TEXT |

### UserProfile (Firestore)
`uid, name, age, weight, goal, allergies[], created_at`

### ChatMessage (opsional)
`id, role (user/model), content, timestamp`

---

## 7. Integrasi Eksternal

- **Gemini API**: input pertanyaan + konteks scan; output teks. Perlu penanganan timeout, error jaringan, dan batas kuota.
- **Firebase**: Auth untuk login, Firestore untuk profil dan sinkronisasi riwayat.

System prompt chatbot (draf):
> Kamu adalah asisten buah dalam aplikasi FruitLens. Jawab singkat, ramah, dalam Bahasa Indonesia, hanya seputar buah, nutrisi, penyimpanan, dan resep. Jika pertanyaan di luar topik, arahkan kembali dengan sopan. Jangan memberi diagnosis medis.

---

## 8. Batasan dan Di Luar Cakupan

- Tidak ada pembayaran atau e-commerce
- Tidak mengenali buah di luar daftar kelas yang dilatih
- Bukan alat diagnosis medis
- iOS tidak menjadi target utama
- Daftar kelas awal dibatasi **10–15 buah populer** (apel, pisang, jeruk, mangga, alpukat, tomat, strawberry, anggur, semangka, nanas, dll.)

---

## 9. Struktur Folder yang Disarankan

```
lib/
├── main.dart
├── core/            # tema, konstanta, util
├── data/
│   ├── models/
│   ├── repositories/
│   └── sources/     # sqlite, firestore, api
├── services/        # scan_service, chat_service, auth_service
├── providers/       # state management
└── ui/
    ├── screens/     # home, scan, result, chat, history, profile
    └── widgets/
assets/
├── models/          # *.tflite, labels.txt
├── data/            # fruits.json, recipes.json
└── images/
```

---

## 10. Kriteria Penerimaan Global

- [ ] Scan foto buah menghasilkan jenis + kematangan + nutrisi
- [ ] Hasil tersimpan dan muncul di riwayat
- [ ] Chatbot menjawab pertanyaan dengan benar dan tetap pada topik
- [ ] Scan berjalan dalam mode pesawat (offline)
- [ ] Tidak crash pada skenario: izin ditolak, gambar kosong, internet putus
- [ ] Laporan evaluasi model tersedia (akurasi, confusion matrix)
