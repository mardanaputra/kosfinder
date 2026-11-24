# Rencana Uji Terima (Test Plan) - KosFinder

Dokumen rencana pengujian penerimaan pengguna (*User Acceptance Test*) berdasarkan Acceptance Criteria pada `docs/PRD.md`.
Kolom **hasil nyata** dan **lulus** disediakan kosong untuk diisi oleh Software Engineer (SE) saat pengujian manual di perangkat.

---

## Tabel Rencana Uji Terima

| ID | AC terkait | langkah | hasil yang diharapkan | hasil nyata | lulus |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TP01** | US01-AC1 | Buka aplikasi dengan koneksi internet aktif. | Halaman utama memuat daftar kartu kos dari Supabase lengkap dengan nama, area, tipe gender, harga per bulan, dan sisa kamar. | | |
| **TP02** | US01-AC2 | Ketik nama area yang tidak ada (misal: `AreaTidakAda`) pada search bar. | Tampil ilustrasi/pesan "Kos di area tersebut tidak ditemukan". | | |
| **TP03** | US01-AC3 | Matikan koneksi internet (Airplane mode), lalu buka aplikasi atau tarik layar (*pull to refresh*). | Aplikasi tidak crash, menampilkan pesan "Gagal memuat data. Periksa koneksi internet Anda" dan tombol "Coba Lagi". | | |
| **TP04** | US02-AC1 | Buka modal filter, pilih tipe "Putri", batas harga Rp 1.000.000, fasilitas "Wi-Fi", lalu tekan "Terapkan". | Daftar kos tersaring dan hanya menampilkan kos Putri berharga $\le$ Rp 1.000.000 yang memiliki fasilitas Wi-Fi. | | |
| **TP05** | US02-AC2 | Buka modal filter saat filter aktif, lalu tekan tombol "Reset Filter". | Semua kriteria filter dibersihkan dan daftar kembali menampilkan seluruh kos secara utuh. | | |
| **TP06** | US03-AC1 | Pilih kartu kos yang memiliki sisa kamar $> 0$. | Halaman detail menampilkan informasi lengkap, daftar fasilitas, teks nomor kontak pemilik, dan badge hijau "Tersedia X Kamar". | | |
| **TP07** | US03-AC2 | Pilih kartu kos yang memiliki sisa kamar $= 0$. | Halaman detail menampilkan badge merah "Penuh". | | |
| **TP08** | US04-AC1 | Masuk ke menu Akun, pilih tab Daftar, isi email baru dan password $\ge 6$ karakter, tekan "Daftar Akun Pemilik". | Registrasi berhasil di Supabase Auth, muncul SnackBar sukses, dan akun langsung berstatus login. | | |
| **TP09** | US04-AC2 | Masuk ke menu Akun, pilih tab Masuk, masukkan email/password yang salah, tekan "Masuk". | Login gagal, muncul SnackBar peringatan merah "Email atau password salah". | | |
| **TP10** | US05-AC1 | Login sebagai pemilik, buka menu "Kos Saya", tekan "Tambah Kos", isi form valid, lalu tekan "Simpan Kos". | Data kos tersimpan ke Supabase dengan `owner_id` akun saat ini dan muncul di daftar. | | |
| **TP11** | US05-AC2 | Pada form tambah kos, kosongkan nama atau isi harga $\le 0$, lalu tekan "Simpan Kos". | Form menampilkan pesan validasi error merah di bawah field dan data tidak terkirim ke database. | | |
| **TP12** | US06-AC1 | Login sebagai pemilik yang memiliki kos, lalu buka halaman "Kos Saya". | Hanya properti kos milik akun yang sedang login yang ditampilkan. | | |
| **TP13** | US06-AC2 | Login sebagai pemilik baru yang belum memiliki kos, buka halaman "Kos Saya". | Tampil empty state "Anda belum memiliki properti kos yang terdaftar" dan tombol "Tambah Kos Sekarang". | | |
| **TP14** | US07-AC1 | Buka form edit pada kos milik sendiri, ubah sisa kamar dari 2 menjadi 0, lalu tekan "Simpan Perubahan". | Data di Supabase terbarui, badge ketersediaan berubah menjadi "Penuh". | | |
| **TP15** | US07-AC2 | Pemilik B mencoba memodifikasi/menembak API update data kos milik Pemilik A. | Permintaan ditolak backend via Supabase Row Level Security (RLS) dengan kode unauthorized. Data Pemilik A tidak berubah. | | |
| **TP16** | US08-AC1 | Pada halaman "Kos Saya", tekan ikon Hapus pada kos milik sendiri, lalu tekan "Ya, Hapus" pada dialog konfirmasi. | Data kos dihapus permanen (*hard delete*) dari Supabase dan hilang dari antarmuka. | | |
| **TP17** | US08-AC2 | Tekan ikon Hapus, lalu tekan tombol "Batal" pada dialog konfirmasi. | Dialog tertutup dan data kos tetap aman tanpa ada perubahan. | | |
| **TP18** | AGENTS.md | Buka menu Tentang Aplikasi (*About*). | Halaman menampilkan nama aplikasi KosFinder, NIM `2455011006`, dan Nama `Suniaramana Mardana Putra`. | | |
