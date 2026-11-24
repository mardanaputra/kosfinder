# Panduan Kerja Agen AI (AGENTS.md) - KosFinder

Dokumen ini adalah aturan kerja wajib bagi Agen AI yang bekerja pada repositori proyek **KosFinder**.

---

## 1. Konteks Proyek & Dokumen Acuan
KosFinder adalah aplikasi pencarian dan pengelolaan kos berbasis mobile (Android) yang dibangun menggunakan Flutter dan backend Supabase.

Setiap pekerjaan agen wajib merujuk dan patuh pada dokumen spesifikasi berikut:
- [`docs/PRD.md`](file:///docs/PRD.md): Sumber kebenaran kebutuhan fungsional (User Story, Acceptance Criteria) dan non-fungsional (NFR).
- [`docs/ARCHITECTURE.md`](file:///docs/ARCHITECTURE.md): Arsitektur teknis, struktur lapisan kode, skema database, dan alur navigasi.
- [`docs/TASKS.md`](file:///docs/TASKS.md): Daftar perincian task, status pengerjaan, dan urutan implementasi.

---

## 2. Cara Kerja Agen
1. **Satu Task Per Permintaan**: Kerjakan hanya satu task yang sedang ditugaskan. Jangan melompati atau mencampur aduk task.
2. **Batasan File**: Dilarang memodifikasi file di luar lingkup task yang sedang aktif.
3. **Rencana Sebelum Eksekusi**: Untuk perubahan besar atau struktural, paparkan rencana kerja terlebih dahulu dan minta persetujuan Software Engineer (SE / Pengguna).
4. **Solusi Paling Sederhana (KISS & YAGNI)**: Pilih implementasi paling sederhana, bersih, dan mudah dibaca yang memenuhi Acceptance Criteria. Hindari *over-engineering* atau abstraksi yang tidak diperlukan.
5. **Larangan Penambahan Package**: Dilarang menambahkan package/dependency baru ke `pubspec.yaml` tanpa izin dan persetujuan eksplisit dari SE.

---

## 3. Standar Teknologi
- **Framework**: Flutter (Android).
- **State Management**: Provider.
- **Backend & Database**: Supabase (Supabase Auth & PostgreSQL).

---

## 4. Keamanan & Akses Data
1. **Kerahasiaan Kredensial**: Dilarang keras menuliskan API key, password, URL rahasia, atau kredensial langsung (*hardcoded*) di dalam kode sumber maupun riwayat commit Git.
2. **Larangan Service Role Key**: Kunci `service_role` tidak boleh digunakan atau dimasukkan ke dalam aplikasi mobile. Aplikasi klien hanya boleh menggunakan `anon` / `publishable key`.
3. **Penegakan Hak Akses di Backend**: Keamanan data mutlak ditegakkan di backend database menggunakan **Row Level Security (RLS)** Supabase, bukan hanya menyembunyikan elemen visual di antarmuka (UI).

---

## 5. Aturan Git & Commit
1. **Satu Task, Satu Commit**: Setiap penyelesaian satu task atau satu dokumen menghasilkan satu commit tersendiri.
2. **Format Pesan Commit**: Pesan commit wajib menyebutkan ID task atau dokumen terkait, misalnya:
   - `docs: tambah PRD`
   - `T01: setup supabase client (US04-AC1)`
   - `T05: filter kos berdasarkan harga (US02-AC1)`
3. **Persetujuan SE**: Commit hanya dilakukan setelah mendapat persetujuan dari SE.

---

## 6. Definition of Done (DoD)
Sebuah task dinyatakan **Selesai (Done)** apabila memenuhi seluruh kriteria berikut:
- [ ] Kode bebas dari error dan warning (`flutter analyze` bersih).
- [ ] Seluruh unit test terkait berhasil dijalankan dan lulus (`flutter test` lulus).
- [ ] Fitur telah diverifikasi atau dijalankan pada device/emulator sesuai Acceptance Criteria.
- [ ] Agen wajib melaporkan secara transparan apa saja yang **sudah diuji** dan apa yang **belum diuji**.

---

## 7. Informasi Pengembang (Halaman About)
Halaman About/Tentang Aplikasi wajib menampilkan identitas pengembang:
- **NIM**: `2455011006`
- **Nama**: `Suniaramana Mardana Putra`
