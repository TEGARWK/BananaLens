# AGENTS.md — Aturan Utama Vibe Coding FruitLens

> File ini wajib dibaca AI di awal setiap sesi. Jika ada konflik, urutan otoritas:
> `AGENTS.md` > `ARCHITECTURE.md` > `DESIGN_RULES.md` > `prd.md` > `kebutuhan-sistem.md`.

## 1. Sumber Kebenaran

| File | Fungsi |
|---|---|
| `prd.md` | Apa & kenapa (fitur, layar, kriteria penerimaan) |
| `kebutuhan-sistem.md` | Spesifikasi teknis (FR/NFR, model data, arsitektur) |
| `ARCHITECTURE.md` | Konvensi kode Flutter, state management, struktur |
| `DESIGN_RULES.md` | Aturan UI/UX anti "AI slop" |
| `TEAM_ROLES.md` | Pembagian peran AI |
| `TASKS.md` | Papan tugas: 1 tugas = 1 hasil |

Jangan mengarang fitur di luar dokumen ini. Jika ada yang ambigu, **tanya user**, jangan menebak.

## 1b. Pembagian Jalur (kerja kelompok)

- **Jalur A — Aplikasi Flutter**: dikerjakan di repo ini (user + AI).
- **Jalur B — Visi Komputer & AI** (training model, `.tflite`, Gemini asli): dikerjakan **teman user**. AI **tidak** melatih model atau menulis implementasi Gemini asli kecuali diminta.
- AI di jalur A memakai `abstract class` + implementasi **Fake** berlabel `TODO-INTEGRASI`; kontrak ada di `INTEGRATION_CONTRACT.md`. Jangan mengubah kontrak sepihak.
- Fake tidak boleh dianggap fitur final; diganti di Fase 7 saat artefak jalur B tiba.

## 2. Aturan Emas: 1 Fase = 1 Hasil

1. Kerjakan **satu fase penuh** dari `TASKS.md` per siklus kerja (bukan satu tugas mikro). Selesaikan semua tugas dalam fase tersebut sampai tuntas.
2. Setiap fase menghasilkan **satu milestone deliverable yang utuh dan bisa diverifikasi** (misal: seluruh alur persiapan selesai, seluruh modul inti scan & model selesai, atau seluruh fitur AI selesai).
3. Sebelum coding, tulis ringkas: *fase apa yang dikerjakan, daftar tugas dalam fase tersebut, file yang disentuh, dan rencana verifikasi*.
4. Setelah seluruh tugas dalam satu fase selesai dan memenuhi Definition of Done, **berhenti** dan laporkan hasilnya per fase. Jangan melompat ke fase berikutnya tanpa persetujuan user.
5. Tugas dan fase dianggap selesai hanya jika **Definition of Done** (bagian 7) terpenuhi.

## 3. Penggunaan Skills (Global)

Sebelum mengerjakan tugas, **cek dan baca `SKILL.md`** skill yang relevan. Jangan improvisasi jika skill tersedia.

| Situasi | Skill yang dipakai |
|---|---|
| Memulai sesi / bingung skill mana | `using-agent-skills` |
| Requirement samar | `interview-me`, `idea-refine` |
| Menulis spesifikasi fitur | `spec-driven-development` |
| Memecah pekerjaan | `planning-and-task-breakdown` |
| Implementasi lintas file | `incremental-implementation` |
| Logika / bugfix | `test-driven-development`, `debugging-and-error-recovery` |
| Desain API / kontrak antar modul | `api-and-interface-design` |
| **Membuat UI / layar / widget** | `frontend-ui-engineering` + **`taste-skill`** (wajib, lihat bagian 5) |
| Rapikan kode | `code-simplification` |
| Review sebelum selesai | `code-review-and-quality` |
| Auth, API key, input user, privasi | `security-and-hardening` |
| Performa (inferensi TFLite, list) | `performance-optimization` |
| Commit / branch | `git-workflow-and-versioning` |
| CI/CD, build rilis | `ci-cd-and-automation`, `shipping-and-launch` |
| Dokumentasi / keputusan arsitektur | `documentation-and-adrs` |
| Library/API yang rawan usang (Riverpod, tflite_flutter, Firebase) | `source-driven-development` |
| Logging & error tracking | `observability-and-instrumentation` |
| Keputusan berisiko tinggi | `doubt-driven-development` |

Sebutkan skill yang dipakai di awal laporan tugas (`Skill: ...`).

## 4. Aturan Teknis Wajib

### Flutter
- **State management: Riverpod**, satu-satunya. Dilarang `setState` untuk state bisnis (hanya boleh untuk state UI lokal murni seperti animasi/controller). Dilarang campur Provider/Bloc/GetX.
- **Clean architecture ringan** sesuai `ARCHITECTURE.md`: UI → Provider/Notifier → Repository → Data Source. UI tidak boleh memanggil database/API/TFLite langsung.
- **Clean code**: lihat `ARCHITECTURE.md` bagian Clean Code.
- Setiap fitur wajib menangani state: **loading, error, kosong, sukses**.
- Semua teks UI **Bahasa Indonesia**, disimpan di satu tempat (konstanta/l10n), bukan tersebar.
- Jangan hardcode API key. Baca dari `.env` dan pastikan `.env` ada di `.gitignore`.
- Inferensi TFLite dijalankan di **isolate** agar UI tidak freeze.
- Beri komentar singkat pada logika preprocessing dan inferensi model.

### Larangan
- Dilarang menambah dependency tanpa alasan; sebutkan alasan dan cek versi terbaru di pub.dev.
- Dilarang `// ignore:` / `dynamic` / `!` berlebihan untuk membungkam analyzer.
- Dilarang menghapus atau melewati test agar "hijau".
- Dilarang menaruh logika di `build()`.
- Dilarang file > 300 baris atau widget `build` > 80 baris; pecah.
- Dilarang data dummy/mock tertinggal di kode produksi tanpa label `TODO` di `TASKS.md`.
- Dilarang membuat placeholder "Lorem ipsum" di UI akhir.

## 5. UI: Wajib Taste, Dilarang AI Slop

Setiap tugas yang menyentuh tampilan **wajib**:
1. Baca `DESIGN_RULES.md`.
2. Baca skill taste: `C:\Users\tegar\.agents\skills\taste-skill\SKILL.md`
   (atau `minimalist-skill` / `soft-skill` / `imagegen-frontend-mobile` / `redesign-skill` di folder yang sama bila lebih cocok).
3. Terapkan token desain dari tema pusat; jangan hardcode warna/ukuran di widget.
4. Lakukan *self-check* anti-slop (`DESIGN_RULES.md` bagian 6) sebelum melapor selesai.

## 6. Format Laporan Setiap Fase

```
Fase: <ID & Nama Fase dari TASKS.md>
Daftar Tugas Selesai:
- [x] <ID Tugas>: <Ringkasan deliverable>
Skill yang Digunakan: <daftar skill>
Hasil Milestone: <1-2 kalimat deliverable utama fase>
File diubah/dibuat:
- path — alasan
Cara menguji:
1. ...
Verifikasi dijalankan: flutter analyze ✅ | flutter test ✅ | run manual ✅/❌
Status Fase: SELESAI ✅
Catatan untuk fase berikutnya: ...
```

## 7. Definition of Done (per fase)

- [ ] Seluruh kriteria penerimaan tugas dalam fase terkait di `prd.md` dan `TASKS.md` terpenuhi
- [ ] `flutter analyze` bersih (0 warning/error)
- [ ] `dart format .` sudah dijalankan
- [ ] Test komprehensif ditulis dan seluruh test lulus
- [ ] State loading/error/kosong/sukses tertangani
- [ ] Tidak ada API key / secret di kode
- [ ] Sesuai `ARCHITECTURE.md` dan `DESIGN_RULES.md`
- [ ] `TASKS.md` diperbarui (seluruh tugas dalam fase berubah status menjadi DONE)
- [ ] `CHANGELOG.md` diperbarui dengan format Hari, Tanggal dan ringkasan perubahan
- [ ] Laporan format bagian 6 diberikan

## 8. Perilaku AI

- **Jujur**: jika tidak bisa menjalankan/menguji sesuatu, katakan. Jangan mengklaim "sudah dites" tanpa menjalankan.
- **Tanya dulu** bila requirement ambigu; jangan mengisi kekosongan dengan asumsi diam-diam.
- **Ringkas**: jawaban singkat, fokus pada hasil.
- **Tidak over-engineering**: solusi paling sederhana yang memenuhi kriteria.
- **Jaga dokumen**: jangan hapus komentar/dokumentasi yang tidak terkait perubahan.
- **Keamanan**: jangan menjalankan perintah destruktif (hapus massal, force push) tanpa izin.
- Gunakan Bahasa Indonesia untuk komunikasi; kode, nama variabel, dan komentar kode dalam Bahasa Inggris.

## 9. Prompt Awal Sesi (salin ke chat)

```
Baca AGENTS.md, ARCHITECTURE.md, DESIGN_RULES.md, TEAM_ROLES.md, TASKS.md.
Ambil FASE berstatus TODO teratas, selesaikan seluruh tugas di dalam fase tersebut
sesuai peran di TEAM_ROLES.md dan aturan 1 Fase = 1 Hasil, lalu laporkan
dengan format di AGENTS.md bagian 6 dan berhenti.
```

