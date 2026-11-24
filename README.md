# KosFinder 🏠

Aplikasi pencarian dan pengelolaan kos berbasis mobile (Android) yang dibangun menggunakan **Flutter** dan didukung backend **Supabase** (Auth & PostgreSQL dengan Row Level Security).

---

## 👨‍💻 Identitas Pengembang
- **Nama**: Suniaramana Mardana Putra
- **NIM**: 2455011006
- **Kelas**: TRPL 5A
- **Mata Kuliah**: Workshop Mobile / Pemrograman Mobile
- **Institusi**: Universitas Pendidikan Ganesha

---

## 🚀 Fitur Aplikasi (Versi 0.1.0)

### 1. Pencari Kos (Guest / Tanpa Login)
- **Katalog Kos**: Menampilkan daftar kos lengkap dengan nama, area, tipe gender, harga sewa bulanan, dan badge ketersediaan kamar.
- **Pencarian Area**: Mencari kos berdasarkan nama lokasi/area secara fleksibel (*case-insensitive*) dengan penanganan status kosong.
- **Penyaringan Lanjutan (Filter)**:
  - Batas harga sewa bulanan maksimal (slider & preset cepat).
  - Tipe kos (Putra, Putri, Campur).
  - Checklist fasilitas baku (*Wi-Fi, AC, Kamar Mandi Dalam, Kasur, Lemari, Parkir Motor*).
  - Reset filter dengan satu sentuhan.
- **Detail Rincian Kos**: Informasi lengkap kos, status ketersediaan ("Tersedia X Kamar" atau "Penuh"), daftar fasilitas, serta nomor telepon/WhatsApp pemilik kos dalam format teks.
- **Halaman About**: Informasi aplikasi dan identitas lengkap pengembang (NIM & Nama).

### 2. Pemilik Kos (Terotentikasi via Supabase Auth)
- **Registrasi & Login**: Autentikasi email dan password aman menggunakan Supabase Auth.
- **Menu "Kos Saya"**: Dashboard khusus untuk melihat daftar properti kos milik akun yang sedang login.
- **Tambah Kos Baru**: Form pendaftaran kos dengan validasi ketat di sisi klien.
- **Ubah Data Kos**: Mengubah detail kos dan memperbarui kuota ketersediaan kamar.
- **Pembaruan Cepat Ketersediaan (Bonus Slice 5)**: Stepper instan (+ / -) pada kartu properti untuk menambah/mengurangi sisa kamar secara langsung.
- **Hapus Kos Permanen**: Penghapusan data kos (*hard delete*) terlindungi dialog konfirmasi dan otorisasi backend Supabase RLS.

---

## 🛡️ Batasan Versi 1 (Out-of-Scope)
Mengacu pada `docs/PRD.md`, Versi 1 **tidak mencakup**:
- Pembayaran sewa online / payment gateway.
- Fitur chat interaktif / pesan instan dalam aplikasi.
- Sistem ulasan (*review*) dan rating bintang.
- Rekomendasi pintar berbasis AI.
- Verifikasi identitas / KTP pemilik.
- Upload foto atau input URL gambar eksternal (menggunakan placeholder lokal bawaan).
- Peta interaktif (*Google Maps / OSM*).
- Fitur bookmark / favorit bagi pencari kos.
- Integrasi *direct dialer* otomatis.

---

## 🏛️ Arsitektur & Keamanan
- **Pola Arsitektur**: *Screen - Provider - Repository - Supabase Client*.
- **Row Level Security (RLS)**: Mutasi data (`INSERT`, `UPDATE`, `DELETE`) dilindungi oleh policy database Supabase `auth.uid() = owner_id`. Upaya memodifikasi data pemilik lain otomatis ditolak di level PostgreSQL.
- **Keamanan Kredensial**: Kunci API dan URL dibaca secara dinamis melalui `--dart-define` saat build, tanpa ada secret key yang di-hardcode di kode maupun repositori Git.

---

## 🛠️ Cara Menjalankan & Membangun Aplikasi

### Prasyarat
- Flutter SDK $\ge 3.11$
- Android Studio / VS Code & Android SDK
- Akun dan Proyek Supabase yang sudah mengaktifkan skema `supabase/migrations/001_init.sql`

### 1. Menjalankan di Perangkat / Emulator (Debug)
Jalankan perintah berikut di terminal dengan mengganti nilai kredensial Supabase Anda:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummyanonkey12345
```

### 2. Menjalankan Unit & Widget Test
```bash
flutter test --no-pub
```

### 3. Build APK Rilis (Release Mode)
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummyanonkey12345
```
Berkas biner APK release akan dihasilkan di:
`build/app/outputs/flutter-apk/app-release.apk`
