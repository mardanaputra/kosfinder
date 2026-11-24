# Product Requirements Document (PRD) - KosFinder (Versi 1)

## 1. Masalah & Tujuan Terukur
### Masalah
- Informasi sewa kos tersebar di media sosial dan grup chat tanpa format terstandar, menyulitkan pencari membandingkan harga, tipe, dan fasilitas.
- Pemilik kos kesulitan memperbarui informasi ketersediaan kamar secara cepat saat kamar terisi atau kosong.

### Tujuan Terukur
- Pencari kos dapat menemukan dan menyaring kos (area, harga, tipe, fasilitas) dalam waktu $\le 10$ detik.
- Pemilik kos dapat memperbarui status sisa kamar dalam $\le 3$ langkah/klik.
- 100% hak akses mutasi data (tambah, ubah, hapus) ditegakkan di backend database (Supabase RLS).

---

## 2. Pengguna
1. **Pencari Kos (Guest / Tamu)**: Mahasiswa atau masyarakat pencari kos. Mengakses aplikasi tanpa registrasi/login dan tanpa fitur akun/simpan di V1.
2. **Pemilik Kos**: Pengelola properti kos. Melakukan registrasi & login via email/password untuk mempublikasikan dan mengelola kos miliknya sendiri.

---

## 3. Scope Versi 1
### A. Yang Masuk (In-Scope)
- **Pencari**:
  - Melihat daftar seluruh kos yang tersedia.
  - Mencari kos berdasarkan teks nama area/lokasi.
  - Menyaring daftar berdasarkan harga bulanan maksimal, tipe kos (Putra, Putri, Campur), dan checklist fasilitas.
  - Melihat halaman detail kos (informasi lengkap, kontak teks pemilik, status ketersediaan, ikon placeholder).
- **Pemilik**:
  - Registrasi & Login akun pemilik menggunakan Supabase Auth.
  - Menambah data kos baru.
  - Melihat halaman "Kos Saya" khusus properti miliknya.
  - Mengubah data kos dan memperbarui jumlah sisa kamar.
  - Menghapus kos milik sendiri secara permanen (*hard delete*) dengan dialog konfirmasi.
  - Logout akun.

### B. Yang TIDAK Masuk (Out-of-Scope)
- Pembayaran online / dompet digital.
- Fitur chat interaktif / pesan instan dalam aplikasi.
- Sistem ulasan (*review*) dan rating bintang.
- Rekomendasi pintar / algoritma AI.
- Verifikasi identitas (KTP/dokumen) pemilik kos.
- Fitur upload foto atau input URL gambar luar (hanya menggunakan ikon/ilustrasi lokal).
- Tampilan peta digital (*Google Maps/OSM*).
- Fitur akun/bookmark/favorit bagi pencari kos.
- Integrasi *direct dialer* / *action launcher* otomatis untuk nomor kontak.

---

## 4. Non-Functional Requirements (NFR)
1. **Keamanan**: Row Level Security (RLS) aktif pada tabel database `kos`. Akses `INSERT`, `UPDATE`, dan `DELETE` wajib memvalidasi `auth.uid() = owner_id` di level database Supabase, bukan hanya validasi visual UI.
2. **Keandalan**: Aplikasi menampilkan pesan ramah dan tombol *Coba Lagi* (*retry*) saat koneksi internet terputus, serta menampilkan ilustrasi/pesan kosong (*empty state*) jika data tidak ditemukan.
3. **Kemudahan Pakai**: Validasi form lokal di sisi klien (nama tidak kosong, harga $> 0$, sisa kamar $\ge 0$, kontak terisi). Feedback aksi instan via SnackBar.
4. **Performa**: Waktu muat daftar kos awal $\le 2$ detik pada jaringan stabil. Operasi mutasi data langsung terefleksi pada antarmuka.
5. **Privasi**: Tidak ada secret key (Service Role Key) di dalam kode sumber aplikasi Android; hanya menggunakan Anon/Public Key Supabase.

---

## 5. User Stories (US)
- **US01**: Sebagai Pencari Kos, saya ingin melihat daftar kos dan mencari berdasarkan nama area, agar saya dapat menemukan kos di lokasi yang saya tuju.
- **US02**: Sebagai Pencari Kos, saya ingin menyaring kos berdasarkan batas harga, tipe gender, dan fasilitas, agar mendapatkan pilihan yang sesuai kriteria dan anggaran saya.
- **US03**: Sebagai Pencari Kos, saya ingin melihat detail lengkap kos, agar mengetahui ketersediaan kamar, rincian fasilitas, dan kontak pemilik.
- **US04**: Sebagai Pemilik Kos, saya ingin mendaftar dan masuk ke akun, agar dapat mengelola kos milik saya.
- **US05**: Sebagai Pemilik Kos, saya ingin menambahkan kos baru, agar kos saya dapat ditemukan oleh calon penyewa.
- **US06**: Sebagai Pemilik Kos, saya ingin melihat daftar kos yang saya miliki di halaman "Kos Saya", agar mudah memantau dan memperbaruinya.
- **US07**: Sebagai Pemilik Kos, saya ingin memperbarui data kos dan jumlah sisa kamar, agar informasi yang tampil selalu akurat.
- **US08**: Sebagai Pemilik Kos, saya ingin menghapus kos milik saya, agar kos yang sudah tidak beroperasi tidak lagi dicari penyewa.

---

## 6. Acceptance Criteria (AC)

### US01: Daftar & Pencarian Area
- **US01-AC1 (Tampil Daftar)**:
  - **Given** pengguna berada di halaman utama dan memiliki koneksi internet,
  - **When** halaman dimuat,
  - **Then** tampil daftar kartu kos dengan nama, area, tipe gender, harga/bulan, dan sisa kamar.
- **US01-AC2 (Pencarian Kosong)**:
  - **Given** pengguna memasukkan kata kunci area "AreaTidakAda",
  - **When** pencarian dijalankan,
  - **Then** sistem menampilkan pesan "Kos di area tersebut tidak ditemukan".
- **US01-AC3 (Koneksi Gagal)**:
  - **Given** koneksi internet terputus atau backend gagal dijangkau,
  - **When** pengguna membuka halaman utama atau menarik untuk me-refresh,
  - **Then** sistem menampilkan pesan "Gagal memuat data. Periksa koneksi internet Anda" dan tombol "Coba Lagi".

### US02: Filter Kos
- **US02-AC1 (Filter Kombinasi)**:
  - **Given** pengguna membuka modal/lembar filter,
  - **When** pengguna memilih tipe "Putri", batas harga Rp 1.000.000, dan fasilitas "Wi-Fi" lalu menekan "Terapkan",
  - **Then** daftar utama hanya menampilkan kos Putri berharga $\le$ Rp 1.000.000 yang memiliki fasilitas Wi-Fi.
- **US02-AC2 (Reset Filter)**:
  - **Given** filter sedang aktif,
  - **When** pengguna menekan tombol "Reset Filter",
  - **Then** semua kriteria filter kembali ke setelan default dan menampilkan seluruh kos.

### US03: Detail Kos
- **US03-AC1 (Kamar Tersedia)**:
  - **Given** sebuah kos memiliki sisa kamar $> 0$,
  - **When** pencari memilih kartu kos tersebut,
  - **Then** halaman detail menampilkan informasi lengkap, nomor kontak pemilik (teks), dan badge hijau bertuliskan "Tersedia X Kamar".
- **US03-AC2 (Kamar Penuh)**:
  - **Given** sebuah kos memiliki sisa kamar $= 0$,
  - **When** pencari memilih kartu kos tersebut,
  - **Then** halaman detail menampilkan badge merah bertuliskan "Penuh".

### US04: Autentikasi Pemilik
- **US04-AC1 (Registrasi Sukses)**:
  - **Given** pengguna mengisi email baru dan password valid ($\ge 6$ karakter),
  - **When** menekan tombol "Daftar",
  - **Then** akun berhasil dibuat dan pengguna langsung dialihkan ke halaman utama/dashboard pemilik.
- **US04-AC2 (Login Gagal)**:
  - **Given** pengguna memasukkan email atau password yang tidak terdaftar/salah,
  - **When** menekan tombol "Masuk",
  - **Then** sistem menampilkan SnackBar error "Email atau password salah".

### US05: Tambah Kos
- **US05-AC1 (Tambah Sukses)**:
  - **Given** pemilik telah login dan mengisi form kos (nama, area, tipe, harga, sisa kamar, fasilitas, no. kontak),
  - **When** menekan tombol "Simpan",
  - **Then** data tersimpan ke Supabase dengan `owner_id` pemilik saat ini, dan kos muncul di daftar.
- **US05-AC2 (Validasi Form Gagal)**:
  - **Given** pemilik mengosongkan nama kos atau memasukkan harga $\le 0$,
  - **When** menekan tombol "Simpan",
  - **Then** form menampilkan pesan error validasi di bawah field dan data tidak dikirim.

### US06: Halaman Kos Saya
- **US06-AC1 (Daftar Kos Sendiri)**:
  - **Given** pemilik telah login dan memiliki 2 properti kos,
  - **When** membuka menu "Kos Saya",
  - **Then** hanya 2 properti milik akun tersebut yang tampil.
- **US06-AC2 (Belum Memiliki Kos)**:
  - **Given** pemilik baru yang belum mendaftarkan properti,
  - **When** membuka menu "Kos Saya",
  - **Then** tampil pesan "Anda belum memiliki properti kos yang terdaftar" dan tombol "Tambah Kos".

### US07: Ubah Kos
- **US07-AC1 (Update Sukses)**:
  - **Given** pemilik membuka halaman edit pada kos miliknya,
  - **When** mengubah sisa kamar dari 2 menjadi 0 dan menekan "Perbarui",
  - **Then** data di Supabase terupdate dan status kos langsung berubah menjadi "Penuh".
- **US07-AC2 (Ditolak Backend - RLS)**:
  - **Given** request update dikirim dengan `owner_id` yang berbeda dari user yang sedang login,
  - **When** request dieksekusi ke backend Supabase,
  - **Then** Supabase RLS menolak mutasi (error unauthorized) dan database tidak berubah.

### US08: Hapus Kos
- **US08-AC1 (Hapus Terkonfirmasi)**:
  - **Given** pemilik menekan tombol "Hapus" pada kos miliknya,
  - **When** muncul dialog konfirmasi dan pemilik menekan "Ya, Hapus",
  - **Then** record kos dihapus permanen (*hard delete*) dari Supabase dan hilang dari antarmuka.
- **US08-AC2 (Batal Hapus)**:
  - **Given** dialog konfirmasi hapus terbuka,
  - **When** pemilik menekan "Batal",
  - **Then** dialog tertutup dan data kos tetap ada tanpa perubahan.

---

## 7. Hal yang Masih Ambigu
- *Tidak ada ambiguitas tersisa*. Seluruh 7 poin klarifikasi telah dijawab secara tegas dan tuntas oleh Product Owner / Software Engineer (SE).
