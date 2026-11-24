# Daftar Task (TASKS.md) - KosFinder

Daftar task pengembangan KosFinder berbasis *vertical slice*. Setiap task berdiri sendiri, dapat diuji, dan setiap slice menghasilkan aplikasi yang bisa dijalankan.

---

## Slice 1: Daftar dan Detail Kos (Wajib)
*Aplikasi menampilkan katalog kos dari Supabase, detail rincian kos, dan halaman About.*

| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T01** | Setup dependencies, inisialisasi Supabase via `--dart-define`, dan buat `KosModel` | Foundation, US01-AC1 | `pubspec.yaml`, `lib/main.dart`, `lib/models/kos_model.dart`, `test/kos_model_test.dart` | `flutter test test/kos_model_test.dart` & jalankan app | Selesai |
| **T02** | Buat `KosRepository` dan `KosProvider` untuk memuat data kos beserta penanganan error/empty | US01-AC1, US01-AC3 | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `test/kos_provider_test.dart` | `flutter test test/kos_provider_test.dart` | Pending |
| **T03** | Buat `HomeScreen` (daftar kartu kos, placeholder lokal, harga, sisa kamar) dan retry error | US01-AC1, US01-AC3 | `lib/screens/home_screen.dart`, `lib/widgets/kos_card.dart`, `lib/main.dart`, `test/home_screen_test.dart` | `flutter test test/home_screen_test.dart` & verifikasi daftar di device | Pending |
| **T04** | Buat `DetailScreen` menampilkan rincian kos, teks kontak pemilik, dan status ketersediaan | US03-AC1, US03-AC2 | `lib/screens/detail_screen.dart`, `lib/screens/home_screen.dart`, `test/detail_screen_test.dart` | `flutter test test/detail_screen_test.dart` & klik kartu kos di device | Pending |
| **T05** | Buat `AboutScreen` berisi NIM (2455011006) dan Nama (Suniaramana Mardana Putra) | AGENTS.md | `lib/screens/about_screen.dart`, `lib/screens/home_screen.dart`, `test/about_screen_test.dart` | `flutter test test/about_screen_test.dart` & buka menu Tentang di device | Pending |

---

## Slice 2: Pencarian dan Filter (Wajib)
*Pencari dapat mencari area dan menyaring berdasarkan harga, tipe gender, serta fasilitas.*

| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T06** | Implementasi fitur cari berdasarkan area di `KosProvider` dan search bar `HomeScreen` | US01-AC2 | `lib/providers/kos_provider.dart`, `lib/screens/home_screen.dart`, `test/search_test.dart` | `flutter test test/search_test.dart` & ketik nama area di search bar device | Pending |
| **T07** | Buat modal `FilterBottomSheet` (harga bulanan, tipe gender, 6 checklist fasilitas, tombol reset) | US02-AC1, US02-AC2 | `lib/widgets/filter_bottom_sheet.dart`, `lib/providers/kos_provider.dart`, `lib/screens/home_screen.dart`, `test/filter_test.dart` | `flutter test test/filter_test.dart` & terapkan filter di device | Pending |

---

## Slice 3: Login Pemilik (Wajib)
*Pemilik dapat mendaftarkan akun baru dan masuk menggunakan email & password.*

| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T08** | Buat `AuthRepository` dan `AuthProvider` untuk registrasi, login email/password, dan logout | US04-AC1, US04-AC2 | `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart`, `lib/main.dart`, `test/auth_provider_test.dart` | `flutter test test/auth_provider_test.dart` | Pending |
| **T09** | Buat `AuthScreen` (tab Login/Register, validasi form, SnackBar error) & navigasi di `HomeScreen` | US04-AC1, US04-AC2 | `lib/screens/auth_screen.dart`, `lib/screens/home_screen.dart`, `test/auth_screen_test.dart` | `flutter test test/auth_screen_test.dart` & coba registrasi/login di device | Pending |

---

## Slice 4: Kelola Kos Milik Sendiri (Wajib)
*Pemilik dapat melihat kos miliknya, menambah baru, mengubah data, dan menghapus permanen.*

| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T10** | Buat `MyKosScreen` menampilkan daftar kos milik pemilik yang login beserta *empty state* | US06-AC1, US06-AC2 | `lib/screens/my_kos_screen.dart`, `lib/screens/home_screen.dart`, `test/my_kos_screen_test.dart` | `flutter test test/my_kos_screen_test.dart` & buka menu Kos Saya di device | Pending |
| **T11** | Buat form tambah kos di `KosFormScreen` (validasi wajib, harga $>0$) terhubung ke `KosRepository` | US05-AC1, US05-AC2 | `lib/screens/kos_form_screen.dart`, `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `test/kos_form_create_test.dart` | `flutter test test/kos_form_create_test.dart` & tambah kos di device | Pending |
| **T12** | Implementasi mode edit pada `KosFormScreen` untuk memperbarui data kos milik sendiri | US07-AC1, US07-AC2 | `lib/screens/kos_form_screen.dart`, `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `test/kos_form_edit_test.dart` | `flutter test test/kos_form_edit_test.dart` & ubah data kos di device | Pending |
| **T13** | Implementasi hapus kos dengan dialog konfirmasi (*hard delete* aman via Supabase RLS) | US08-AC1, US08-AC2 | `lib/screens/my_kos_screen.dart`, `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `test/delete_kos_test.dart` | `flutter test test/delete_kos_test.dart` & hapus kos melalui dialog di device | Pending |

---

## Slice 5: Pembaruan Cepat Ketersediaan Kamar (Bonus)
*Pembaruan status ketersediaan kamar secara instan tanpa perlu masuk ke form edit penuh.*

| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T14** | Tambah kontrol pembaruan cepat sisa kamar pada kartu `MyKosScreen` & sinkronisasi otomatis | US03-AC1, US03-AC2, US07-AC1 | `lib/screens/my_kos_screen.dart`, `lib/widgets/kos_card.dart`, `lib/screens/detail_screen.dart`, `test/quick_availability_test.dart` | `flutter test test/quick_availability_test.dart` & ubah sisa kamar jadi 0 di device | Pending |
