# Kualiti - Design System

Tujuan visual: **cozy di mata**. Tenang, hangat, tidak ramai, tidak terlihat seperti template. Satu aksen per tema, satu bahasa bentuk per tema, jarak yang lega.

Mockup referensi: `kualiti-mockup.html` (3 dari 6 tema). Tiga tema sisanya mengikuti token di bawah.

## 1. Prinsip

1. Satu layar, satu tujuan. Maksimal satu aksi utama yang menonjol.
2. Hierarki lewat ukuran dan jarak, bukan lewat banyak warna atau bayangan.
3. Tidak ada gradasi dekoratif, kecuali pada tema yang memang membutuhkannya (Retro XP).
4. Teks isi selalu terbaca. Font dekoratif hanya untuk judul dan label pendek.
5. Animasi hanya untuk menjawab aksi user (buka, centang, selesai) dan satu momen splash. Hormati pengaturan "kurangi animasi" Android.
6. Semua warna berasal dari token tema. Dilarang hard-code warna di widget.
7. Kontras teks minimal 4,5:1.

## 2. Token Tema

Setiap tema mendefinisikan token berikut: `bg`, `surface`, `ink`, `inkMuted`, `accent`, `onAccent`, `line`, `priorityLow`, `priorityMid`, `priorityHigh`, `radius`, `borderWidth`, `fontBody`, `fontTitle`.

| Token | Default | Dark Mode | Aesthetic Brown |
|---|---|---|---|
| bg | #F6F1E9 | #26231F | #EADBC8 |
| surface | #FFFBF5 | #302C27 | #F6EBDD |
| ink | #3B342C | #EDE3D3 | #4A3426 |
| inkMuted | #8C8276 | #9A8F80 | #8A6F5B |
| accent | #C4704B | #E3B15C | #B5603A |
| onAccent | #FFFFFF | #26231F | #FFFFFF |
| line | #E8DFD2 | #3E3933 | #D9C5AC |
| priorityLow (Santai) | #8FB39A | #7FA38C | #8E9B6F |
| priorityMid (Penting) | #E0B25C | #D9A85A | #D2A04F |
| priorityHigh (Sangat Penting) | #D1675A | #D9776A | #B5483A |
| radius | 16 | 16 | 14 |
| borderWidth | 1 | 1 | 1 |
| fontBody / fontTitle | Nunito | Nunito | Quicksand |

| Token | Vintage | Retro Windows XP | Pixel |
|---|---|---|---|
| bg | #EFE3C8 | #ECE9D8 | #F4EEFF |
| surface | #F7EEDB | #FFFFFF | #FFFFFF |
| ink | #3E2F1F | #000000 | #2B2540 |
| inkMuted | #8B7355 | #555555 | #6A6385 |
| accent | #7A4E2D | #3A9A2E (hijau start) | #FF8FB1 |
| onAccent | #FFFFFF | #FFFFFF | #2B2540 |
| line | #D8C7A3 | #7A96DF | #2B2540 |
| priorityLow | #7C8B5A | #3A9A2E | #8FD6A8 |
| priorityMid | #C79A3B | #E8A400 | #FFD36E |
| priorityHigh | #A4452F | #D03A2A | #FF7A8A |
| radius | 6 | 3 | 0 |
| borderWidth | 1 (garis tipis seperti halaman buku) | 2 (timbul) | 3 |
| fontBody | Lora | Noto Sans (cadangan Tahoma-like) | Nunito |
| fontTitle | Lora (bold) | Noto Sans (bold) | Press Start 2P / Silkscreen |

Warna di atas adalah titik awal. Boleh disesuaikan sedikit untuk kontras, selama suasananya sama.

## 3. Karakter per Tema

| Tema | Suasana | Pembeda bentuk |
|---|---|---|
| Default | Pagi yang tenang | Sudut membulat besar, garis tipis, tanpa bayangan |
| Dark Mode | Malam hangat | Abu-arang hangat (bukan hitam pekat), aksen kuning redup |
| Aesthetic Brown | Kafe | Cokelat susu dan krem, bentuk datar, tanpa gradasi |
| Vintage | Buku catatan lama | Warna kertas, tinta sepia, serif, garis tipis seperti baris halaman, sudut kecil |
| Retro Windows XP | Nostalgia desktop XP (biru-hijau) | Title bar biru bergradasi, tombol hijau bergaya Start, panel krem, border timbul. Terinspirasi saja. Dilarang memakai logo, ikon, wallpaper, atau font resmi Microsoft |
| Pixel | Game 8-bit lembut | Palet pastel terbatas, border tebal tanpa sudut membulat, bayangan keras offset 3 px, font pixel hanya untuk judul dan label |

Warna prioritas dan warna "Terlambat" selalu memakai token tema. Untuk Pixel dan Retro, penanda prioritas boleh berbentuk kotak/piksel, bukan lingkaran.

## 4. Tipografi

- Font dibundel di aset. Tidak boleh mengunduh font saat runtime.
- Skala: Judul layar 22, judul kartu 16, isi 14 (isi catatan 16), label kecil 12. Tinggi baris 1,4 untuk sans, 1,55 untuk serif.
- Dilarang: huruf kapital semua untuk label, label kecil di atas setiap judul, tanda panah di tombol.
- Isi catatan selalu memakai font yang mudah dibaca (di tema Pixel bukan font pixel).

## 5. Layout dan Komponen

- Jarak: kelipatan 4. Padding layar 16. Jarak antar kartu 10.
- Navigasi bawah 5 item: Beranda, Tugas, Timer, Catatan, Tautan. Pengaturan lewat ikon di Beranda.
- Kartu: surface + garis tipis, radius sesuai token, tanpa bayangan (kecuali Pixel dan Retro sesuai karakternya).
- Tombol utama: warna `accent`. Tombol sekunder: outline.
- Chip filter: satu baris yang bisa digeser horizontal.
- Penanda prioritas: titik atau strip tipis di sisi kiri baris tugas, warna dari token.
- Bottom sheet untuk tambah/ubah tugas dan tautan. Snackbar untuk Urungkan.
- Empty state: satu kalimat petunjuk dan satu tombol, tanpa ilustrasi besar.
- Lingkaran waktu pada timer: angka besar di tengah, progres tipis. Siklus ditampilkan sebagai teks "Siklus 2 dari 4" dan titik kecil.

## 6. Splash

- Latar polos warna `bg` tema aktif.
- Logo (`assets/images/kualiti_logo.jpg`) muncul dari skala 90% ke 100% sambil fade-in selama 0,6 detik.
- Teks "Kualiti" fade-in, lalu "Your Cozy Personal Dashboard" fade-in 0,5 detik.
- Tahan sebentar, total sekitar 2 detik, lalu transisi lembut. Tidak bisa dilewati dengan loading palsu: jika aplikasi siap lebih cepat, tetap tampilkan minimal 1,5 detik.
- Tagline tidak diterjemahkan.
- JPG tidak transparan, jadi pada tema selain krem, taruh logo di dalam kotak/lingkaran berwarna latar logo agar tidak tampak seperti stiker. Ikon launcher memakai latar krem yang sama dengan latar logo, dengan margin lebar karena Android memotong ikon.

## 7. Aset Placeholder

| Aset | Path | Keterangan |
|---|---|---|
| Logo | `assets/images/kualiti_logo.jpg` | Placeholder. Akan diganti oleh pemilik. Satu file dipakai di splash, ikon, onboarding, dan README |
| Suara notifikasi | `assets/audio/kualiti_notification.mp3` | Placeholder. Satu file dipakai semua notifikasi. Durasi di bawah 5 detik |

Kode harus memuat aset lewat satu konstanta nama file, supaya penggantian file tidak menyentuh kode.

## 8. Prompt Logo (untuk generator gambar)

```
A minimalist app logo for "Kualiti", a cozy personal dashboard app. A simple rounded
coffee cup in flat vector style, seen from the side, with a single curl of steam that
subtly forms a checkmark shape. Soft warm cream background (#F5EFE6), cup in muted
terracotta (#C4704B), steam in a slightly darker brown. Clean thin shapes, generous
empty space, no text, no gradients, no shadows, no extra decoration. Centered
composition, perfectly square 1:1 canvas, flat design, calm and friendly mood,
suitable as an Android app icon.
```

Prompt negatif: `text, letters, gradients, realistic, 3D, shadows, busy background, multiple objects, complex details, outlines too thick, neon colors`

Hasilkan minimal 1024 x 1024 px dengan margin lebar.
