# Dokumen Arsitektur (ARCHITECTURE.md) - KosFinder (Versi 1)

## 1. Pola Arsitektur & Komponen
Menggunakan arsitektur berlapis sederhana: **Screen - Provider - Repository - Supabase**.

```
[Screen / UI Layer]  <--->  [Provider (State)]  <--->  [Repository]  <--->  [Supabase Client / Backend]
```

- **Screen (UI)**: Menampilkan antarmuka deklaratif Flutter, merespons input interaksi pengguna, mendengarkan perubahan data melalui Provider (`context.watch`), dan memicu aksi (`context.read`). (*US01 - US08*)
- **Provider (State Management)**: Subclass `ChangeNotifier` (`KosProvider`, `AuthProvider`) yang menyimpan state UI (daftar kos, filter aktif, status loading, error message, dan status sesi login). Mengisolasi business logic dari tampilan. (*US01 - US08*)
- **Repository (Data Access)**: `KosRepository` dan `AuthRepository` membungkus pemanggilan ke Supabase SDK, serialisasi/deserialisasi model Dart (`KosModel`), serta menangani exception jaringan/database. (*US01 - US08*)
- **Supabase**: Backend-as-a-Service yang menangani otentikasi pengguna (`GoTrue / auth.users`) dan penyimpanan data relasional PostgreSQL dengan penegakan Row Level Security (RLS). (*US01 - US08*)

---

## 2. Daftar Layar & Alur Navigasi
1. **HomeScreen**:
   - Menampilkan search bar teks area, tombol lembar filter, daftar kartu kos (ikon placeholder, nama, area, tipe, harga, ketersediaan), dan ikon navigasi ke menu Akun/Kos Saya. (*US01, US02*)
2. **DetailScreen**:
   - Menampilkan detail informasi kos lengkap, badge ketersediaan kamar ("Tersedia X Kamar" / "Penuh"), daftar fasilitas, dan nomor telepon kontak pemilik (teks). (*US03*)
3. **AuthScreen**:
   - Form registrasi dan login pemilik kos menggunakan email dan password. (*US04*)
4. **MyKosScreen**:
   - Menampilkan daftar kos milik akun pemilik yang sedang login. Dilengkapi tombol "Tambah Kos", serta tombol ubah dan hapus pada masing-masing item. (*US06, US07, US08*)
5. **KosFormScreen**:
   - Form input terpadu untuk aksi Tambah Kos Baru (*US05*) dan Ubah Kos (*US07*).
6. **AboutScreen**:
   - Menampilkan informasi identitas pengembang:
     - **NIM**: `2455011006`
     - **Nama**: `Suniaramana Mardana Putra`

### Alur Navigasi
- **Pencari Kos (Guest)**: `HomeScreen` $\rightarrow$ pilih item $\rightarrow$ `DetailScreen`. Akses drawer/info $\rightarrow$ `AboutScreen`.
- **Pemilik Kos (Owner)**:
  - `HomeScreen` $\rightarrow$ ikon Profil $\rightarrow$ `AuthScreen` $\rightarrow$ login sukses $\rightarrow$ `MyKosScreen`.
  - `MyKosScreen` $\rightarrow$ tekan Tambah Kos $\rightarrow$ `KosFormScreen` (Mode Tambah).
  - `MyKosScreen` $\rightarrow$ tekan tombol Edit $\rightarrow$ `KosFormScreen` (Mode Edit).
  - `MyKosScreen` $\rightarrow$ tekan Hapus $\rightarrow$ Muncul Dialog Konfirmasi $\rightarrow$ Hapus Data.

---

## 3. Rencana Database & Aturan Akses (RLS)

### Tabel: `public.kos`
| Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `UUID PRIMARY KEY` | Default `gen_random_uuid()` |
| `owner_id` | `UUID NOT NULL` | FK merujuk ke `auth.users(id)` ON DELETE CASCADE |
| `name` | `TEXT NOT NULL` | Nama kos |
| `area` | `TEXT NOT NULL` | Nama area / lokasi kos |
| `type` | `TEXT NOT NULL` | Nilai dibatasi: `'Putra'`, `'Putri'`, atau `'Campur'` |
| `price_per_month` | `BIGINT NOT NULL` | Harga sewa bulanan dalam Rupiah (angka $> 0$) |
| `available_rooms` | `INT NOT NULL` | Jumlah sisa kamar tersedia ($\ge 0$) |
| `facilities` | `TEXT[] NOT NULL` | Daftar fasilitas baku (Wi-Fi, AC, Kamar Mandi Dalam, Kasur, Lemari, Parkir Motor) |
| `contact_number` | `TEXT NOT NULL` | Nomor telepon/WhatsApp pemilik kos |
| `created_at` | `TIMESTAMPTZ` | Default `now()` |
| `updated_at` | `TIMESTAMPTZ` | Default `now()` |

### Kebijakan Row Level Security (RLS)
Keamanan mutlak ditegakkan di PostgreSQL Supabase (`ALTER TABLE kos ENABLE ROW LEVEL SECURITY;`):
1. **SELECT (Semua Pengguna / Publik)**:
   - *Policy*: `Publik dapat melihat semua data kos`.
   - *Aturan*: Siapa saja (termasuk anonim/guest) dapat membaca data seluruh kos (`USING (true)`). (*US01, US02, US03*)
2. **INSERT (Pemilik Terotentikasi)**:
   - *Policy*: `Pemilik dapat menambah kos miliknya`.
   - *Aturan*: Hanya user yang sudah login (`authenticated`) yang dapat menambah data dengan `WITH CHECK (auth.uid() = owner_id)`. (*US05*)
3. **UPDATE (Pemilik Sah Saja)**:
   - *Policy*: `Pemilik hanya dapat mengubah kos miliknya`.
   - *Aturan*: Baris hanya dapat diubah jika `auth.uid() = owner_id`. Upaya pemilik B mengubah kos pemilik A otomatis diblokir oleh backend. (*US07*)
4. **DELETE (Pemilik Sah Saja)**:
   - *Policy*: `Pemilik hanya dapat menghapus kos miliknya`.
   - *Aturan*: Baris hanya dapat dihapus jika `auth.uid() = owner_id`. (*US08*)

---

## 4. Cara Konfigurasi Lingkungan
Kredensial URL Supabase dan Public Anon Key **tidak di-hardcode** dalam berkas kode sumber apa pun:
- Dibaca menggunakan konstanta Dart `String.fromEnvironment()`:
  ```dart
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  ```
- Diberikan saat build atau run melalui opsi `--dart-define`:
  ```bash
  flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=ey...
  ```
- Menjaga kerahasiaan kredensial dan kebersihan riwayat commit Git.

---

## 5. Cara Rilis Aplikasi
1. **Build APK Rilis**:
   ```bash
   flutter build apk --release \
     --dart-define=SUPABASE_URL=<PROJECT_URL> \
     --dart-define=SUPABASE_ANON_KEY=<ANON_KEY>
   ```
2. **Lokasi File Output**:
   - Berkas biner APK berada di: `build/app/outputs/flutter-apk/app-release.apk`.
3. **Publikasi ke GitHub Releases**:
   - Buka halaman rilis repository: `https://github.com/mardanaputra/kosfinder/releases/new`.
   - Buat tag baru (contoh: `v1.0.0`), sertakan judul dan ringkasan fitur rilis.
   - Unggah berkas `app-release.apk` dan klik **Publish release**.

---

## 6. Daftar Package dan Justifikasi
Mengikuti prinsip kesederhanaan (*KISS & YAGNI*), aplikasi hanya memerlukan 2 package utama:

| Package | Alasan Kebutuhan & User Story Terkait |
| :--- | :--- |
| `provider` | State management standar untuk mengelola data reaktif, session login, dan filter antar halaman tanpa kompleksitas berlebih. (*US01 - US08*) |
| `supabase_flutter` | SDK resmi Supabase untuk menangani autentikasi akun pemilik, koneksi PostgreSQL, dan penegakan operasi CRUD berbasis RLS. (*US01 - US08*) |
