# Kualiti - Product Requirements (v1.0)

Tagline (branding, selalu bahasa Inggris di semua bahasa): **Kualiti - Your Cozy Personal Dashboard**

## 1. Ringkasan

Kualiti adalah aplikasi Android pribadi yang berisi catatan, daftar tugas, timer, dan tautan cepat dalam satu dashboard yang tenang dan nyaman dilihat. Semua data tersimpan lokal di HP. Tidak ada akun, tidak ada server, tidak ada iklan.

- Platform: Android 8.0 (API 26) ke atas, didistribusikan sebagai APK lewat GitHub Releases.
- Package name: `com.kualiti`
- Bahasa antarmuka: Indonesia, Inggris, dan "Ikuti HP" (default).
- Tema: 6 (Default, Dark Mode, Aesthetic Brown, Vintage, Retro Windows XP, Pixel).
- Aplikasi harus bisa dipakai penuh tanpa internet. Internet hanya dipakai untuk mengambil ikon situs di Tautan Cepat.

## 2. Prinsip

1. Cozy dan tidak ramai. Satu layar, satu tujuan. Tidak ada gradasi berlebihan, tidak ada ilustrasi yang tidak perlu.
2. Konsisten bahasa. Jika bahasa Indonesia aktif, seluruh teks (termasuk notifikasi, tanggal, pesan error) berbahasa Indonesia. Jika Inggris, seluruhnya Inggris. Pengecualian tunggal: tagline splash dan nama produk.
3. Ringan. Tidak ada fitur yang menuntut user belajar dulu.
4. User cukup mengunduh APK. Tidak ada aplikasi pihak ketiga yang wajib dipasang.

## 3. Alur Pengguna

1. **Splash** (sekitar 2 detik): logo muncul halus (skala 90% ke 100% dan fade-in, 0,6 dtk), lalu teks "Kualiti", lalu tagline fade-in (0,5 dtk), lalu transisi ke layar berikutnya. Hanya tampil di pembukaan dingin (cold start).
2. **Onboarding** (hanya sekali):
   1. Nama (wajib, 1 sampai 24 karakter).
   2. Bahasa: Ikuti HP (default), Indonesia, English.
   3. Tema: grid 6 tema dengan pratinjau langsung saat dipilih. Ada catatan: "Tema bisa diganti kapan saja di Pengaturan."
3. **Dashboard**.
4. Izin Android tidak diminta di awal. Diminta saat pertama dibutuhkan lewat satu layar penjelasan singkat (lihat bagian 8).

Tanggal lahir tidak dikumpulkan.

## 4. Dashboard

Urutan dari atas ke bawah, tidak lebih:
1. Sapaan dengan nama dan tanggal hari ini (mengikuti format tanggal pilihan user). Ikon pengaturan di pojok.
2. Kartu ringkasan tugas hari ini: jumlah tugas yang belum selesai dan satu tugas terdekat. Jika ada yang terlambat, tampil penanda Terlambat.
3. Kartu timer aktif. Hanya muncul jika ada timer berjalan. Menampilkan nama, sisa waktu, tombol jeda.
4. Empat kartu menu: Catatan, Tugas, Timer, Tautan.
5. Satu baris sampai 4 tautan cepat pilihan user (ikon saja).

## 5. Fitur

### 5.1 Tugas (Tasks)

Data tugas: judul, prioritas, tanggal jatuh tempo, jam jatuh tempo (opsional), pengulangan, pengingat, status selesai, tanggal selesai.

- **CRUD**: tambah, lihat, ubah, hapus. Hapus memakai snackbar "Dihapus - Urungkan" selama 5 detik, bukan dialog konfirmasi.
- **Prioritas** (wajib saat tambah, default Penting): tiga level.
  - Santai (EN: Chill)
  - Penting (EN: Important)
  - Sangat Penting (EN: Critical)
  Warna diambil dari token tema (`priorityLow`, `priorityMid`, `priorityHigh`), bukan warna tetap.
- **Jam opsional**. Jika kosong, pengingat dijadwalkan pukul 09.00 dan form menampilkan keterangan: "Jika kosong, pengingat pukul 09.00." Waktu default ini bisa diubah di Pengaturan.
- **Pengingat**: default tepat waktu. Opsi tambahan: 10 menit, 1 jam, atau 1 hari sebelumnya. Notifikasi tetap berbunyi walau aplikasi dihapus dari recent apps.
- **Filter** (chip): Semua, Hari Ini, Mendatang, Selesai, Berulang.
  - Semua: semua tugas yang belum selesai.
  - Hari Ini: tugas dengan tanggal hari ini. Tugas terlambat tampil di bagian atas dengan subjudul "Terlambat".
  - Mendatang: tanggal setelah hari ini.
  - Selesai: riwayat tugas selesai, dikelompokkan per tanggal selesai (Hari ini, Kemarin, lalu tanggal). Ada opsi "Bersihkan riwayat".
  - Berulang: tugas yang punya aturan pengulangan dan belum selesai.
- **Sort** (terpisah, pilih satu): Tenggat (tanggal lalu jam), Prioritas (tertinggi dulu), A-Z (abjad judul).
- **Penanda Terlambat**: label kecil "Terlambat" memakai warna `priorityHigh` tema, ditambah teks relatif ("kemarin 14.00", "2 hari lalu"). Bukan merah murni.
- **Pengulangan**: tidak ada, tiap hari, tiap minggu (pilih hari), tiap bulan, tiap tahun. Tanggal berhenti opsional. Saat sebuah kemunculan diselesaikan, kemunculan berikutnya dibuat otomatis. Kemunculan yang terlewat tidak menumpuk: hanya satu yang tampil sebagai Terlambat. Tidak ada pola custom ("tiap 2 minggu") di v1.
- Menyelesaikan tugas berulang menaruh kemunculan itu ke riwayat Selesai.

### 5.2 Timer

Enam tab: Timer, Stopwatch, Gaming, Membaca, Belajar, 20-20-20.

Aturan umum:
- Maksimal 5 timer aktif sekaligus (Timer dan Stopwatch). Hanya satu sesi (Gaming, Membaca, Belajar) aktif per waktu. 20-20-20 dihitung terpisah.
- Saat selesai: notifikasi dengan MP3 (jika diaktifkan) dan getar mengikuti pengaturan HP.
- Satu notifikasi permanen merangkum semua timer yang berjalan.
- Home button: timer tetap jalan. Aplikasi dihapus dari recent apps: timer, stopwatch, dan sesi berhenti dan hilang (disengaja).

**Timer**: user menambah banyak timer dengan nama sendiri dan durasi (jam, menit, detik). Preset cepat: 1, 5, 10, 15 menit.

**Stopwatch**: bisa ditambah dan diberi nama. Tombol Lap dan daftar lap yang bisa dilipat.

**Sesi Gaming, Membaca, Belajar**: dua fase, Fokus dan Istirahat.

| Mode | Fokus | Istirahat | Preset alternatif |
|---|---|---|---|
| Gaming | 2 jam | 20 menit | 1 jam / 15 menit |
| Membaca | 45 menit | 10 menit | 30 / 5 |
| Belajar | 50 menit | 10 menit | Pomodoro 25 / 5 |

- Semua bisa di-custom. Preset ditandai "Rekomendasi".
- **Siklus**: pilih 1 sampai 8 atau Tanpa batas (default 1). Tampilan: "Siklus 2 dari 4" ditambah titik kecil per siklus.
- **Mulai otomatis** (toggle, default aktif): aktif berarti fase berikutnya langsung jalan. Nonaktif berarti user menekan Mulai pada tiap fase.

**20-20-20** (hemat baterai):
- Satu alarm terjadwal berulang tiap 20 menit, bukan service yang terus hidup.
- Notifikasi berisi teks (ID): "Saatnya mengistirahatkan mata dengan melihat objek sejauh 6 meter di sekitar Anda." (EN): "Time to rest your eyes. Look at something 20 feet (6 meters) away."
- Tombol notifikasi: **Mulai istirahat 20 detik**, **Tunda 5 menit**, **Lewati**. Setelah istirahat selesai, getar singkat dan alarm 20 menit berikutnya dijadwalkan.
- **Sleep mode**: jam aktif, default 08.00 sampai 22.00 (bisa diubah). Di luar jam itu tidak ada alarm.
- **Jeda otomatis** bila 3 pengingat berturut-turut tidak direspons.
- Berhenti jika aplikasi dihapus dari recent apps. Layar 20-20-20 menampilkan keterangan ini.

Tidak ada riwayat sesi di v1.

### 5.3 Catatan (Notes)

- Daftar catatan, judul, cuplikan isi, tanggal ubah. Catatan yang di-pin tampil di atas.
- Pencarian (judul dan isi), tag ringan (maksimal 5 per catatan, filter chip di atas daftar). Tanpa folder.
- Autosave, tanpa tombol simpan.
- Format teks: Heading (satu level), **Bold**, *Italic*, Underline, Tautan, dan list: bullet, nomor (1, 2, 3), huruf (a, b, c).
- Hapus lewat snackbar Urungkan.

### 5.4 Tautan Cepat (Quick Links)

- CRUD: nama dan alamat. Input tanpa `https://` tetap diterima dan dinormalisasi.
- Ikon diambil dari situs saat pertama ditambahkan, lalu disimpan lokal (cache) supaya tampil saat offline. Jika gagal: lingkaran dengan huruf awal nama.
- Tap membuka tautan di browser HP. Tekan lama untuk ubah atau hapus.
- User memilih sampai 4 tautan untuk ditampilkan di dashboard.

### 5.5 Pengaturan

- Bahasa: Ikuti HP, Indonesia, English.
- Tema: 6 pilihan dengan pratinjau.
- Format tanggal: DD/MM/YYYY, MM/DD/YYYY, YYYY/MM/DD (default mengikuti bahasa/HP). Format jam: 12 jam atau 24 jam (default mengikuti HP). Format ini dipakai di seluruh aplikasi.
- Notifikasi: toggle "Suara MP3" dan jam pengingat default (09.00).
- Cadangan data: lihat 5.6.
- Nama: bisa diubah.
- Tentang: versi, tautan GitHub.

Pilihan zona waktu tidak ada. Kualiti selalu memakai zona waktu HP.

### 5.6 Cadangan Data

- **Ekspor ke perangkat**: menyimpan satu file JSON lewat dialog simpan bawaan Android (Storage Access Framework). Nama file: `kualiti[namauser]backup.json`, misalnya `kualitiRinabackup.json`. Karakter selain huruf dan angka di nama dibuang.
- **Impor cadangan**: user memilih file `.json`. Aplikasi memvalidasi, menampilkan tanggal cadangan dan jumlah isi, lalu meminta konfirmasi karena data lokal akan ditimpa.
- **Cadangkan ke Google Drive**: tombol tampil di Pengaturan. Saat ditekan muncul dialog "Segera hadir" (Coming soon). Tidak ada fungsi di v1.
- Seluruhnya offline.

## 6. Notifikasi

- Satu file MP3 untuk semua notifikasi: `kualiti_notification.mp3` (di bawah 5 detik).
- Dua notification channel: `kualiti_sound` (MP3 dan getar) dan `kualiti_silent` (getar saja). Toggle "Suara MP3" memilih channel yang dipakai.
- Mode HP (dering, getar, senyap) ditangani sistem Android. Jika HP mode getar, hanya bergetar. Jika HP mode dering dan toggle MP3 mati, hanya getar. Tidak ada pola getar custom.
- Pembeda jenis notifikasi hanya judul dan isi teks.

## 7. Di Luar Lingkup v1

Subtask, widget layar utama, kunci aplikasi (PIN atau sidik jari), riwayat sesi timer, pola pengulangan custom, backup Google Drive (hanya tombol "Segera hadir"), zona waktu manual.

## 8. Izin Android

Satu layar penjelasan ramah, muncul saat izin pertama kali dibutuhkan, dengan tombol "Izinkan" dan "Nanti saja". Tidak boleh menghalangi pemakaian.

| Izin | Alasan yang ditampilkan ke user |
|---|---|
| Notifikasi (Android 13+) | Untuk pengingat tugas dan timer |
| Alarm tepat waktu | Supaya pengingat berbunyi tepat waktu |
| Pengecualian hemat baterai (opsional) | Beberapa merek HP mematikan aplikasi di latar belakang |

## 9. Kriteria Selesai

- Semua teks UI, notifikasi, dan format tanggal mengikuti bahasa aktif, tanpa campuran.
- Pengingat tugas berbunyi setelah aplikasi dihapus dari recent apps dan setelah HP restart.
- Timer tetap jalan saat user menekan Home dan berhenti saat aplikasi dihapus dari recent apps.
- Ekspor lalu impor mengembalikan data persis sama.
- Enam tema terbaca jelas (kontras teks cukup) di seluruh layar.
- APK dapat dipasang tanpa aplikasi tambahan.
