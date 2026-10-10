# Kualiti

[English](README.md) | [Bahasa Indonesia](README.id.md)

Kualiti - Your Cozy Personal Dashboard.

Kualiti adalah aplikasi Android kecil yang awalnya saya buat untuk diri sendiri, dan sekarang bisa dipakai siapa saja yang butuh tempat tenang untuk catatan, tugas, timer, dan tautan. Semua data tersimpan di HP kamu. Tanpa akun, tanpa server, tanpa iklan.

## Isinya

- **Catatan.** Notepad sederhana dengan heading, tebal, miring, garis bawah, tautan, serta list bullet, angka, dan huruf. Ada pencarian, pin, dan tag. Tersimpan otomatis saat mengetik.
- **Tugas.** Tanggal dan jam jatuh tempo, tiga tingkat prioritas, pengingat, tugas berulang, dan riwayat tugas selesai. Filter Semua, Hari Ini, Mendatang, Selesai, atau Berulang, dan urutkan berdasarkan tenggat, prioritas, atau A-Z.
- **Timer.** Timer biasa, stopwatch dengan lap, dan sesi fokus serta istirahat untuk gaming, membaca, dan belajar, lengkap dengan waktu rekomendasi yang bisa diubah. Ada juga pengingat 20-20-20 untuk mengistirahatkan mata.
- **Tautan cepat.** Simpan situs favorit lengkap dengan ikonnya.
- **Tema.** Default, Dark Mode, Aesthetic Brown, Vintage, Retro Windows XP, dan Pixel.
- **Bahasa.** Indonesia dan Inggris. Aplikasi tidak pernah mencampur keduanya.

## Unduh

1. Buka halaman [Releases](https://github.com/kern1028/kualiti-personal-dashboard/releases).
2. Unduh `Kualiti-vX.X.X.apk` yang terbaru.
3. Buka file itu di HP. Kalau Android bertanya, izinkan pemasangan dari browser atau pengelola file kamu satu kali saja.
4. Buka Kualiti, isi nama, pilih bahasa dan tema, selesai.

Butuh Android 8.0 atau lebih baru. Tidak perlu memasang aplikasi lain.

## Perlu diketahui

- **Notifikasi.** Pengingat tugas dan timer butuh izin notifikasi. Kualiti baru memintanya saat dibutuhkan, dan kamu boleh pilih "nanti saja".
- **Suara dan getar.** Kualiti mengikuti pengaturan HP. Di mode getar, HP hanya bergetar. Di mode dering, ada suara pendek yang bisa dimatikan di Pengaturan sehingga hanya bergetar.
- **Hemat baterai.** Beberapa HP (Xiaomi, Oppo, Vivo, dan beberapa lainnya) menutup aplikasi di latar belakang. Kalau pengingat tidak muncul, atur Kualiti ke "tanpa batasan" di pengaturan baterai.
- **Timer dan recent apps.** Timer tetap jalan saat kamu menekan Home. Kalau aplikasi digeser dari recent apps, timer berhenti. Pengingat tugas tetap berbunyi.
- **Ikon tautan cepat.** Ikon diunduh satu kali saat tautan ditambahkan, jadi perlu internet pada saat itu. Setelahnya bisa dipakai tanpa internet.

## Cadangan

Data hanya ada di HP kamu. Di Pengaturan, pilih **Ekspor ke perangkat** untuk menyimpan file bernama `kualiti[namakamu]backup.json`. Untuk memulihkan, pilih **Impor cadangan** lalu pilih file itu. Cadangan ke Google Drive sedang direncanakan dan untuk sementara tampil sebagai "Segera hadir".

## Build dari kode sumber

Kamu butuh Flutter terpasang.

```
git clone https://github.com/kern1028/kualiti-personal-dashboard.git
cd kualiti-personal-dashboard
flutter pub get
flutter run
```

Untuk membuat APK:

```
flutter build apk --release
```

Hasilnya ada di `build/app/outputs/flutter-apk/`.

## Rencana

- Cadangan ke Google Drive
- Pola pengulangan yang lebih banyak
- Subtugas
- Widget layar utama

## Pembuat

Dibuat oleh Kern. Laporan bug dan ide boleh disampaikan lewat tab Issues.
