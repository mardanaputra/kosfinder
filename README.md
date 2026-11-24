# KosFinder

Aplikasi pencarian dan pengelolaan kos berbasis mobile (Android) dengan Flutter dan backend Supabase.

## Pengembang
- **Nama**: Suniaramana Mardana Putra
- **NIM**: 2455011006
- **Kelas**: TRPL 5A

---

## Cara Menjalankan

Aplikasi membaca konfigurasi Supabase melalui `--dart-define` untuk menjaga kerahasiaan kredensial.

Jalankan perintah berikut di terminal dengan mengganti nilai URL dan Anon Key dengan kredensial proyek Supabase Anda:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummykeyforrunningapp12345
```

Atau untuk build APK release:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummykeyforrunningapp12345
```
