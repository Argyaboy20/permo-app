# Permo (Pertanian Mobile)

Aplikasi edukasi pertanian untuk web dan Android. Permo membantu pengguna mengenal tanaman, jenis tanah, dan memilih tanaman yang cocok untuk cuaca di lokasinya, ditambah asisten tanya jawab berbasis AI.

Aplikasi ini adalah pembangunan ulang dari versi lama (Ionic + PHP + MySQL) dengan Flutter dan backend Go.

## Fitur

- **Akun**: daftar, masuk, ubah profil dan password, lupa akun (kode 6 digit lewat email), dan hapus akun dengan verifikasi password.
- **Kamus Tumbuhan**: 18 tumbuhan dengan kebutuhan suhu, tanah, sinar matahari, dan air, lengkap dengan pencarian.
- **Ilmu Tanah**: 15 jenis tanah beserta ciri, sebaran, dan pH-nya.
- **Rekomendasi Tanam**: saran dari 48 tanaman berdasarkan suhu dan kelembapan udara, diisi manual atau dari lokasi perangkat.
- **Permo AI**: asisten tanya jawab seputar pertanian dengan batas pertanyaan harian.
- **Pembaruan**: tombol update muncul di Beranda saat ada rilis baru di GitHub.

## Teknologi

| Bagian | Teknologi |
|---|---|
| Aplikasi | Flutter (Dart), Material 3 |
| Backend | Go (`net/http` + `pgx`), JWT, bcrypt |
| Database | PostgreSQL (Neon) |
| Hosting API | Render (Docker) |
| Email | Brevo (API transaksional) |

Repo ini berisi **aplikasi Flutter**. Kode backend ada di repo terpisah (`permo-backend`, privat).

## Struktur proyek

```
lib/
├── main.dart              rute dan tema; langsung ke Beranda bila sesi masih berlaku
├── konfigurasi.dart       alamat API (bisa diganti lewat --dart-define)
├── sesi.dart              token dan data login tersimpan di perangkat
├── api/klien_api.dart     klien HTTP ke backend
├── halaman/               landing, daftar, masuk, lupa akun, beranda, akun, Permo AI, dst.
├── model/                 model data
└── widget/                komponen bersama (latar daun, pemuat data, logo, dll.)
assets/                    logo, ikon, dan font
```

## Menjalankan

Prasyarat: [Flutter](https://docs.flutter.dev/get-started/install) (stable) terpasang.

```
flutter pub get
flutter run -d web-server --web-port 5000
```

Lalu buka `http://localhost:5000` di browser. Port 5000 dipakai karena itulah asal yang diizinkan server (CORS) untuk pengembangan lokal.

Secara bawaan aplikasi memakai server produksi `https://permo-api.onrender.com`. Server memakai paket gratis, jadi permintaan pertama setelah lama tidak dipakai bisa menunggu sekitar satu menit.

Untuk memakai backend sendiri yang berjalan lokal:

```
flutter run -d web-server --web-port 5000 --dart-define=URL_API=http://localhost:3000
```

## Membuat APK Android

Prasyarat: Android SDK terpasang, dengan jalur tanpa spasi (misalnya `C:\Android\sdk`) dan NDK yang diminta Flutter.

```
flutter config --android-sdk C:\Android\sdk
flutter doctor -v
flutter build apk --release
```

Hasilnya ada di `build/app/outputs/flutter-apk/`. Izin yang dipakai: internet dan lokasi (untuk fitur Rekomendasi Tanam).

## Merilis versi baru

1. Naikkan `version:` di `pubspec.yaml` (angka setelah `+` harus selalu naik), misalnya `1.0.1+2`.
2. Build APK release.
3. Di GitHub buat **Release** dengan tag sama dengan nomor versi (`1.0.1`) dan lampirkan APK-nya.

Aplikasi yang terpasang membandingkan versinya dengan rilis terbaru dan menampilkan tombol update bila ada yang lebih baru.

Catatan: pemasangan di atas versi lama hanya berhasil bila APK ditandatangani dengan kunci yang sama.

## Privasi

Koordinat lokasi hanya dipakai untuk mengambil cuaca dan nama daerah, dikirim langsung dari perangkat ke layanan cuaca dan tidak disimpan di server Permo. Pertanyaan Permo AI diteruskan lewat server ke penyedia layanan AI dan isi percakapan tidak disimpan di basis data Permo. Jangan menulis data pribadi di percakapan.

## Lisensi

Dirilis di bawah [Lisensi MIT](LICENSE).