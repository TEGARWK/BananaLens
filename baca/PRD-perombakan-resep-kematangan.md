# Penambahan Fitur: Resep Berbasis Hasil Scan Kematangan

## 1. Ringkasan

Ditambahkan fitur **Resep** yang muncul setelah scan kematangan buah. Rekomendasi ditentukan oleh **hasil scan** (jenis buah, kelas kematangan, persentase). **Fitur chat AI assistant yang sudah ada TIDAK dihapus dan TIDAK diubah.**

**Alasan:**
- Resep berbasis hasil scan itu bounded, langsung terasa gunanya, dan bisa dikontrol kualitasnya.
- Konten resep di-pre-generate dan disimpan di DB, jadi cepat dan hemat biaya saat runtime.

---

## 2. Yang Tidak Boleh Disentuh (Chat AI Assistant)

Fitur chat AI assistant yang sudah ada **dipertahankan apa adanya**:

- Jangan hapus atau ubah UI, route, state, service, endpoint, prompt, dan tabel/model chat.
- Jangan hapus konfigurasi/client LLM (Gemini). Boleh dipakai bersama untuk script pre-generate resep, tapi jangan ubah perilaku chat.
- Fitur Resep bersifat terpisah dari chat (modul/service sendiri), tidak bergantung pada alur chat.

---

## 3. Fitur Baru: Resep Berdasarkan Hasil Scan

Setelah scan, user melihat hasil: jenis buah, kelas kematangan (**mentah / matang / busuk**), dan persentase kematangan. Dari hasil itu, tampilkan konten sesuai aturan gating di bawah.

### 3.1 Aturan Gating (dijalankan di kode, bukan oleh LLM)

| Kondisi | Perilaku |
|---|---|
| `busuk` | Pesan statis: **buang saja, jangan dikonsumsi**. Tidak ada resep. Keamanan pangan tidak boleh diserahkan ke LLM. |
| `mentah` + `edible_when_unripe = false` | Pesan statis: **tunggu dulu sampai matang**, plus estimasi hari (rule-based dari persentase). Tidak ada resep. |
| `mentah` + `edible_when_unripe = true` | Tampilkan **dua opsi** ke user: **"Tunggu matang"** (dengan estimasi hari) atau **"Masak sekarang"** (resep untuk bucket mentah). |
| `matang` | Tampilkan resep sesuai bucket matang (lihat 3.2). |

### 3.2 Bucket Kematangan

Persentase kematangan dipakai untuk memecah kelas `matang` menjadi bucket supaya rekomendasi terasa relevan, bukan generik:

- **Matang pas** → cocok dimakan langsung/diolah ringan (contoh: salad buah, oatmeal topping, jus).
- **Matang banget** → cocok untuk olahan yang memanfaatkan buah lunak/manis (contoh: banana bread, pancake, smoothie, pisang goreng).

Kelas `mentah` juga punya bucket sendiri untuk resep olahan mentah (hanya untuk buah yang `edible_when_unripe = true`).

> **Threshold persentase untuk tiap bucket harus dibuat konfigurasi (konstanta/config), bukan hardcode tersebar.** Sesuaikan dengan output model scan yang sudah ada; agent harus cek format dan rentang persentase yang dikeluarkan model saat ini sebelum menentukan nilai awal, lalu konfirmasi ke developer.

### 3.3 Buah Mentah yang Bisa Dimasak

Beda buah beda nasib. Contoh buah yang mentahnya bisa diolah: pisang kepok/tanduk (keripik, pisang rebus), pepaya muda (sayur), mangga muda (rujak, sambal, asinan), nangka muda (gudeg, sayur). Buah yang mentahnya tidak layak/tidak enak (misal alpukat keras) → `edible_when_unripe = false`.

Flag ini adalah **data statis per jenis buah** di database, bukan keputusan LLM di setiap request.

---

## 4. Model Data (usulan, sesuaikan dengan skema yang sudah ada)

**Tabel/entitas buah (`fruits` atau yang sudah ada):**
- `edible_when_unripe` : boolean (default `false`)

**Tabel resep (`recipes`):**
- `id`
- `fruit_id` (FK ke jenis buah)
- `ripeness_bucket` : enum (`unripe`, `ripe`, `very_ripe`)
- `name`
- `type` : enum (`food`, `drink`)
- `ingredients` : JSON/array
- `steps` : JSON/array (singkat)
- `safety_notes` : text nullable (wajib terisi untuk resep buah mentah yang butuh pengolahan khusus)
- `is_reviewed` : boolean (hanya resep yang sudah direview yang boleh tampil)
- `created_at`, `updated_at`

Resep disimpan per kombinasi **(jenis buah × bucket)**. Satu kombinasi boleh punya beberapa resep.

---

## 5. Kontrak Output Resep (JSON)

```json
{
  "fruit": "pisang",
  "ripeness_bucket": "very_ripe",
  "recipes": [
    {
      "name": "Banana Bread",
      "type": "food",
      "ingredients": ["3 pisang sangat matang", "200 g tepung terigu", "..."],
      "steps": ["Haluskan pisang.", "Campur bahan kering.", "..."],
      "safety_notes": null
    }
  ]
}
```

Aturan: schema tetap, tanpa teks bebas di luar field. Frontend render sebagai card, bukan chat bubble.

---

## 6. Peran LLM (Gemini) yang Baru

Untuk fitur Resep, LLM (Gemini) dipakai sebagai generator konten di belakang layar, bukan lewat chat:

1. **Pre-generate**: jumlah kombinasi (buah × bucket) terbatas. Generate sekali lewat script/seed/admin job, simpan ke DB.
2. **Runtime tidak memanggil LLM** untuk kasus normal. Aplikasi hanya membaca resep dari DB (cepat, biaya mendekati nol).
3. **Output wajib JSON terstruktur** sesuai bagian 5, divalidasi terhadap schema sebelum disimpan.
4. **Review manual wajib sebelum tayang** (`is_reviewed = true`), terutama resep buah mentah. Resep yang butuh pengolahan khusus (misal getah pepaya/nangka muda, perlu direbus dulu agar aman) harus punya langkah keamanan eksplisit di `steps`/`safety_notes`.
5. LLM tidak pernah dipakai untuk memutuskan apakah buah aman dimakan. Itu urusan gating di kode.

---

## 7. Alur UI

1. User scan → halaman hasil menampilkan jenis buah, kelas, persentase.
2. Di bawahnya, bagian **Resep** menyesuaikan gating (bagian 3.1):
   - Busuk → kartu peringatan "Buang saja".
   - Mentah (tidak bisa dimasak) → kartu "Tunggu dulu" + estimasi hari.
   - Mentah (bisa dimasak) → dua tombol/tab: "Tunggu matang" / "Masak sekarang".
   - Matang → daftar kartu resep sesuai bucket.
3. Tap kartu resep → detail (bahan, langkah, catatan keamanan bila ada).

---

## 8. Edge Case

- Jenis buah belum punya resep yang sudah direview → tampilkan state kosong yang jelas ("Resep belum tersedia"), jangan fallback ke LLM realtime.
- Persentase di perbatasan antar bucket → ikuti threshold di config, konsisten.
- Jenis buah tidak dikenali/di luar daftar → tidak ada bagian resep, tampilkan hasil scan saja.
- Estimasi hari "tunggu" bersifat rule-based dan perkiraan kasar; beri label "perkiraan".

---

## 9. Acceptance Criteria

- [ ] Fitur chat AI assistant yang sudah ada tetap berfungsi dan tidak berubah.
- [ ] Build dan test berjalan tanpa error.
- [ ] Gating `busuk`, `mentah` (dua varian), dan `matang` berjalan sesuai tabel 3.1.
- [ ] Threshold bucket berada di satu tempat konfigurasi.
- [ ] Resep dibaca dari DB, tidak ada panggilan LLM saat runtime normal.
- [ ] Hanya resep dengan `is_reviewed = true` yang tampil.
- [ ] Resep buah mentah yang butuh pengolahan khusus memiliki catatan keamanan eksplisit.
- [ ] Output resep mengikuti schema JSON pada bagian 5.

---

## 10. Di Luar Scope (versi ini)

- Tips mempercepat pematangan (misal simpan bareng apel).
- Mengubah atau menambah fitur pada chat AI assistant yang sudah ada.
- Personalisasi resep berdasarkan preferensi/alergi user.
