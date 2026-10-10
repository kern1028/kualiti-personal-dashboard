# Kualiti - Technical Specification

Baca `PRD.md` lebih dulu. Dokumen ini menjelaskan cara membangunnya.

## 1. Stack

- Framework: Flutter (stable terbaru), Dart.
- Platform target: Android saja. minSdk 26, targetSdk terbaru.
- Package/applicationId: `com.kualiti`
- State management: Riverpod (atau Provider jika lebih sederhana). Pilih satu, jangan campur.
- Database lokal: SQLite lewat `drift` atau `sqflite`.
- Preferensi: `shared_preferences`.
- Semua font dan aset dibundel di APK. Aplikasi tidak boleh mengunduh apa pun untuk berjalan.

Paket yang disarankan (boleh diganti jika ada padanan yang lebih stabil):

| Kebutuhan | Paket |
|---|---|
| Notifikasi dan alarm terjadwal | `flutter_local_notifications`, `timezone`, `flutter_timezone` |
| Timer di latar belakang | `flutter_foreground_task` |
| Getar | `vibration` (opsional, channel notifikasi sudah menangani getar) |
| Editor rich text | `flutter_quill` atau `appflowy_editor` |
| Buka tautan | `url_launcher` |
| Pilih/simpan file | `file_picker` atau Storage Access Framework |
| Info versi | `package_info_plus` |
| Lokalisasi | `flutter_localizations`, `intl` (ARB) |
| HTTP untuk ikon situs | `http` |

## 2. Struktur Proyek

```
lib/
  main.dart
  app/            # MaterialApp, router, bootstrap
  core/
    theme/        # token tema, 6 ThemeData
    l10n/         # app_id.arb, app_en.arb
    db/           # skema dan DAO
    notifications/
    utils/        # format tanggal/jam, sanitasi nama file
  features/
    splash/
    onboarding/
    dashboard/
    tasks/
    timer/
    notes/
    links/
    settings/
    backup/
assets/
  images/kualiti_logo.jpg          # PLACEHOLDER, diganti user
  audio/kualiti_notification.mp3   # PLACEHOLDER, diganti user
  fonts/
android/app/src/main/res/raw/kualiti_notification.mp3   # salinan untuk channel notifikasi
```

Catatan: suara notification channel Android harus berada di `res/raw`. Simpan satu file asli di `assets/audio/` dan salin ke `res/raw/` lewat langkah build atau commit keduanya dengan nama sama.

## 3. Model Data (SQLite)

```
tasks(
  id INTEGER PK, title TEXT, priority INTEGER (1 santai, 2 penting, 3 sangat penting),
  due_date TEXT (YYYY-MM-DD), due_time TEXT NULL (HH:mm), has_time INTEGER,
  repeat_type INTEGER (0 none,1 daily,2 weekly,3 monthly,4 yearly),
  repeat_days TEXT NULL (mis. "1,3,5"), repeat_until TEXT NULL,
  remind_before INTEGER (0, 10, 60, 1440 menit),
  done INTEGER, done_at TEXT NULL, series_id TEXT NULL, created_at TEXT
)
notes(id, title, body_json TEXT, pinned INTEGER, tags TEXT, updated_at TEXT, created_at TEXT)
links(id, name, url, icon_blob BLOB NULL, show_on_home INTEGER, sort_order INTEGER)
settings(key TEXT PK, value TEXT)   # atau shared_preferences
```

Isi catatan disimpan sebagai JSON dokumen terstruktur (format delta/AST milik editor), bukan HTML.

## 4. Editor Catatan

- Wajib: heading, bold, italic, underline, link, bullet list, numbered list, list huruf (a, b, c).
- List huruf tidak standar di kebanyakan editor. Implementasikan sebagai ordered list dengan atribut gaya `lower-alpha` yang ikut tersimpan di JSON dan dirender ulang dengan benar.
- Toolbar ringkas satu baris di atas keyboard.
- Autosave dengan debounce sekitar 500 ms.
- Pencarian memakai ekstraksi teks polos dari JSON (simpan kolom `plain_text` untuk pencarian cepat).

## 5. Notifikasi dan Alarm

### 5.1 Channel
- `kualiti_sound`: importance high, suara `res/raw/kualiti_notification`, getar aktif.
- `kualiti_silent`: importance high, tanpa suara, getar aktif.
- Toggle "Suara MP3" memilih channel saat membuat notifikasi. Mode dering/getar/senyap HP dihormati sistem.
- Karena Android mengunci pengaturan channel setelah dibuat, jangan mengubah properti channel di versi berikutnya. Buat channel baru dengan id baru bila perlu.

### 5.2 Pengingat tugas
- Jadwalkan dengan `zonedSchedule` memakai `AndroidScheduleMode.exactAllowWhileIdle`.
- Waktu = tanggal + jam (default 09.00 jika `has_time = 0`) dikurangi `remind_before`.
- Gunakan zona waktu HP (`flutter_timezone`). Tidak ada pilihan zona waktu di aplikasi.
- Jadwalkan ulang saat: tugas dibuat/diubah/diselesaikan/dihapus, HP restart (`RECEIVE_BOOT_COMPLETED`, `ScheduledNotificationBootReceiver`), aplikasi diperbarui.
- Pengingat harus tetap berbunyi setelah aplikasi dihapus dari recent apps.

### 5.3 Tugas berulang
- Saat kemunculan diselesaikan, hitung tanggal berikutnya dari aturan lalu buat baris baru dengan `series_id` sama. Hentikan jika melewati `repeat_until`.
- Jika kemunculan terlewat, jangan membuat susulan. Maksimal satu tugas per `series_id` yang belum selesai pada satu waktu.
- Bulanan pada tanggal 29 sampai 31: pakai hari terakhir bulan itu jika tanggal tidak ada.

## 6. Timer

- Mesin timer berbasis timestamp (waktu akhir absolut), bukan menghitung detik di UI, supaya akurat setelah aplikasi di latar belakang. Sisa waktu = `endAt - now`.
- Saat ada timer/stopwatch/sesi aktif, jalankan foreground service dengan satu notifikasi permanen yang merangkum semuanya. Notifikasi permanen ini tanpa suara.
- Selesai fase: tampilkan notifikasi dengan channel sesuai toggle suara. Jadwalkan juga alarm exact sebagai cadangan agar bunyi tepat waktu saat layar mati.
- Saat tugas dihapus dari recent apps (`onTaskRemoved`): hentikan service, batalkan alarm timer/sesi/20-20-20, hapus state. Alarm pengingat tugas tidak boleh ikut dibatalkan.
- Batas: 5 timer/stopwatch aktif, 1 sesi aktif.
- Sesi: state `{mode, phase, cycle, totalCycles (0 = tanpa batas), autoStart, focusSec, restSec}`.
  - Fase selesai: jika `autoStart`, mulai fase berikutnya langsung. Jika tidak, tunggu tombol Mulai.
  - Akhir fase Istirahat menaikkan `cycle`. Jika `cycle > totalCycles` dan bukan tanpa batas, sesi selesai dan notifikasi "Sesi selesai".

### 20-20-20
- Satu `zonedSchedule` berulang tiap 20 menit dalam jam aktif (08.00 sampai 22.00 default). Jangan memakai service yang terus hidup.
- Notifikasi punya tiga action: `START_REST` (hitung 20 detik, lalu getar singkat dan jadwalkan 20 menit berikutnya), `SNOOZE_5` (jadwalkan 5 menit lagi), `SKIP` (jadwalkan 20 menit berikutnya).
- Penghitung "tidak direspons": naik tiap pengingat tanpa aksi, reset saat ada aksi. Pada 3 berturut-turut, jeda otomatis dan tampilkan keterangan di layar.
- Di luar jam aktif tidak ada alarm. Alarm berikutnya dijadwalkan ke jam mulai esok hari.

## 7. Izin dan Manifest

```
POST_NOTIFICATIONS
SCHEDULE_EXACT_ALARM  (atau USE_EXACT_ALARM bila sesuai kebijakan)
RECEIVE_BOOT_COMPLETED
VIBRATE
FOREGROUND_SERVICE (+ tipe yang sesuai, mis. specialUse / mediaPlayback tidak dipakai)
REQUEST_IGNORE_BATTERY_OPTIMIZATIONS  (hanya diminta dengan persetujuan user)
INTERNET  (hanya untuk mengambil ikon situs)
```

Layar penjelasan izin dibuat satu kali dan dipakai ulang. Diminta lazily: izin notifikasi dan alarm saat user pertama membuat tugas dengan pengingat atau menjalankan timer. Panduan hemat baterai muncul sebagai tips opsional di Pengaturan.

## 8. Ikon Situs (Quick Links)

1. Normalisasi URL (tambah `https://` jika tidak ada).
2. Ambil HTML halaman, cari `<link rel="icon">` atau `apple-touch-icon`. Jika tidak ada, coba `/favicon.ico`.
3. Perkecil ke sekitar 64 px, simpan ke kolom `icon_blob`. Timeout 5 detik.
4. Jika gagal: tampilkan lingkaran dengan huruf awal nama (warna aksen tema).
5. Jangan mengambil ulang tiap buka. Ambil ulang hanya jika user menekan "Segarkan ikon".

## 9. Lokalisasi dan Format

- ARB `app_id.arb` dan `app_en.arb`. Dilarang menaruh string UI langsung di kode.
- "Ikuti HP": jika bahasa HP bukan Indonesia atau Inggris, pakai Inggris.
- Teks notifikasi juga lewat ARB dan mengikuti bahasa pilihan user (bukan bahasa HP bila user memilih lain).
- Tagline splash adalah konstanta, tidak diterjemahkan.
- Format tanggal: DD/MM/YYYY, MM/DD/YYYY, YYYY/MM/DD. Format jam: 12 atau 24 jam. Satu helper pusat memformat semuanya.

## 10. Cadangan Data

Format file: **JSON** (`.json`), mudah diperiksa dan stabil lintas versi.

```json
{
  "app": "kualiti",
  "schemaVersion": 1,
  "appVersion": "1.0.0",
  "createdAt": "2026-10-10T08:00:00Z",
  "user": { "name": "Rina" },
  "settings": { "language": "system", "theme": "default", "dateFormat": "dmy", "hour24": true, "soundEnabled": true },
  "tasks": [],
  "notes": [],
  "links": []
}
```

- Nama file: `kualiti` + nama user (hanya huruf dan angka) + `backup.json`. Contoh: `kualitiRinabackup.json`. Jika nama kosong setelah dibersihkan, pakai `kualitibackup.json`.
- Ekspor: Storage Access Framework (`ACTION_CREATE_DOCUMENT`), tidak butuh izin penyimpanan.
- Impor: validasi `app` dan `schemaVersion`. Tolak jika versi lebih baru dari yang didukung. Konfirmasi dulu, lalu timpa dalam satu transaksi, lalu jadwalkan ulang semua pengingat.
- Ikon tautan tidak ikut dicadangkan (diambil ulang). 
- Tombol Google Drive: dialog "Segera hadir" saja. Siapkan antarmuka `BackupProvider` (`LocalFileProvider` sekarang, `GoogleDriveProvider` nanti) supaya mudah diperluas.

## 11. Build dan Rilis

- Buat keystore sendiri. Simpan di luar repo dan **jangan hilang**. Keystore yang sama dipakai di setiap rilis, kalau tidak user tidak bisa memperbarui aplikasi di atas versi lama.
- `flutter build apk --release --split-per-abi` atau satu APK universal untuk kemudahan user. Untuk distribusi sederhana, pakai APK universal.
- Nama file rilis: `Kualiti-v1.0.0.apk`.
- Unggah ke GitHub Releases pada repositori `kern1028/kualiti-personal-dashboard`.
- Naikkan `versionCode` di tiap rilis.

## 12. Pengujian Minimum

- Pengingat tugas: dibuat, diubah, dihapus, berbunyi setelah swipe dari recent apps, berbunyi setelah restart.
- Timer: Home button tetap jalan, swipe dari recent apps berhenti.
- Mode HP: dering + MP3 aktif (bunyi dan getar), dering + MP3 nonaktif (getar), getar (getar), senyap (tidak ada suara).
- Ekspor dan impor bolak-balik, termasuk nama dengan spasi dan karakter khusus.
- Ganti bahasa saat aplikasi berjalan: tidak ada teks tercampur, termasuk notifikasi yang sudah dijadwalkan (jadwalkan ulang).
- Uji di setidaknya satu HP Samsung dan satu HP Xiaomi/Oppo/Vivo bila memungkinkan.
