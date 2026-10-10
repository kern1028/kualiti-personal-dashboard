# Prompt untuk Antigravity

Salin isi blok di bawah ini sebagai prompt pertama. Sertakan file `PRD.md`, `TECH-SPEC.md`, `DESIGN-SYSTEM.md`, dan `kualiti-mockup.html` di workspace.

```
Kamu akan membangun aplikasi Android bernama Kualiti memakai Flutter.

Baca dokumen berikut berurutan sebelum menulis kode:
1. PRD.md - apa yang dibangun dan aturan perilakunya
2. TECH-SPEC.md - cara membangunnya
3. DESIGN-SYSTEM.md - token tema dan prinsip visual
4. kualiti-mockup.html - referensi tampilan dan alur untuk 3 tema (Default, Dark, Retro XP). Tiru suasananya, bukan kodenya. Tiga tema lain (Aesthetic Brown, Vintage, Pixel) ikuti token di DESIGN-SYSTEM.md.

Aturan keras:
- Package name com.kualiti. minSdk 26.
- Semua data lokal. Tidak ada akun, server, atau analitik.
- Semua string UI lewat ARB (id dan en). Dilarang mencampur bahasa. Tagline splash "Kualiti - Your Cozy Personal Dashboard" tetap Inggris.
- Semua warna dari token tema. Dilarang hard-code warna di widget.
- Aset logo dan MP3 adalah placeholder: assets/images/kualiti_logo.jpg dan assets/audio/kualiti_notification.mp3. Muat lewat satu konstanta nama file agar mudah diganti. Jangan membuat logo atau suara sendiri.
- Fitur cadangan Google Drive TIDAK dibuat. Hanya tombol yang menampilkan dialog "Segera hadir". Siapkan antarmuka BackupProvider.
- Tidak ada zona waktu manual. Pilihan format tanggal (DD/MM/YYYY, MM/DD/YYYY, YYYY/MM/DD) dan format jam (12/24) ada di Pengaturan.

Urutan pengerjaan (berhenti dan laporkan setelah tiap tahap, tunggu konfirmasi):
Tahap 1  Fondasi: struktur proyek, sistem tema (6), sistem bahasa (id, en, ikuti HP), database, splash, onboarding (nama, bahasa, tema), dashboard kosong, navigasi.
Tahap 2  Tugas: CRUD, prioritas, jam opsional (default 09.00), filter, sort, penanda Terlambat, pengulangan, riwayat selesai, pengingat notifikasi (termasuk setelah restart dan setelah aplikasi dihapus dari recent apps).
Tahap 3  Tautan cepat: CRUD, pengambilan dan cache ikon situs, baris tautan di dashboard.
Tahap 4  Catatan: editor (heading, bold, italic, underline, link, bullet, nomor, huruf), autosave, pencarian, pin, tag.
Tahap 5  Timer: timer, stopwatch, sesi gaming/membaca/belajar (fokus, istirahat, siklus, mulai otomatis), 20-20-20 dengan aksi notifikasi, sleep mode, jeda otomatis, foreground service, perilaku saat aplikasi dihapus dari recent apps.
Tahap 6  Pengaturan, ekspor/impor JSON dengan nama kualiti[namauser]backup.json, layar izin, penyempurnaan, build APK release.

Definisi selesai ada di PRD.md bagian 9. Jangan menambah fitur di luar PRD.md tanpa bertanya.
```

## Tips

- Jalankan satu tahap per sesi agar hasilnya mudah diperiksa.
- Setelah tahap 1, ganti file placeholder logo dan MP3 dengan file asli Anda.
- Simpan keystore rilis di luar repositori dan cadangkan. Hilang berarti user tidak bisa memperbarui aplikasi.
