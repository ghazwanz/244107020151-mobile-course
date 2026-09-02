# Jurnal Pembelajaran: Minggu 01

- **Topik**: Mobile Development Ecosystem & Flutter Refresh
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

Flutter merupakan framework untuk membuat aplikasi multi-platform (Android dan iOS) yang menggunakan bahasa pemrograman dart.

Flutter memiliki struktur folder utama:

- `lib/`: Tempat menulis seluruh kode logika dan tampilan aplikasi.
- `pubspec.yaml`: File konfigurasi proyek untuk mengatur nama aplikasi, versi SDK, dependensi, serta aset seperti gambar dan font.
- `test/`: Tempat menyimpan file testing otomatis untuk memastikan tampilan dan fungsi kode berjalan dengan benar.

Pada praktikum ini, saya mempelajari penggunaan widget dasar seperti:

- `MaterialApp`: Struktur Widget utama.
- `Scaffold`: Kerangka dasar halaman yang menyediakan struktur bilah atas (`AppBar`) dan area konten utama (`body`).
- `Center` dan `Column`: Pengatur tata letak untuk menempatkan konten di tengah layar dan menyusun elemen secara vertikal dari atas ke bawah.
- `Icon` dan `Text`: Komponen untuk menampilkan Icon dan teks seperti nama, NIM, dan keterangan mata kuliah.

---

## Kendala

Saat menjalankan verifikasi lisensi Android dengan perintah `flutter doctor --android-licenses`, proses gagal dengan pesan error bahwa command tersebut sudah (_deprecated_). Berdasarkan referensi pembahasan masalah serupa di forum GitHub, kendala ini diselesaikan dengan melakukan _downgrade_ versi komponen Android SDK Command-line Tools (`cmdline-tools`) ke versi sebelumnya. Setelah versi disesuaikan, command `flutter doctor --android-licenses` berhasil dijalankan.
