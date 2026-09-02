# Laporan Tugas Mingguan: Minggu 01 - Mobile Development Ecosystem & Flutter Refresh

- **Nama Mahasiswa**: Ghazwan Ababil
- **NIM**: 244107020151
- **Repositori**: [244107020151-mobile-course](https://github.com/ghazwanz/244107020151-mobile-course)
- **Status Tugas**: ✅ _Selesai_

---

## 1. Tujuan

Mempersiapkan ekosistem pengembangan Flutter SDK, memahami eksekusi perintah dasar CLI, mengonfigurasi emulator Android `Small_phone`, serta memahami alur kerja Hot Reload dan Hot Restart.

---

## 2. Langkah Praktikum

Proyek dibuat melalui terminal dengan perintah:

```bash
flutter create nama_proyek
```

Dan untuk menjalankan Proyek flutter melalui terminal dengan perintah:

```bash
flutter run
```

Kode default pada `lib/main.dart` diganti dengan tampilan Profil Mahasiswa menggunakan widget dasar `Scaffold`, `AppBar`, `Center`, `Column`, `Icon`, dan `Text`:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, size: 72),
              SizedBox(height: 16),
              Text('Ghazwan Ababil', style: TextStyle(fontSize: 24)),
              Text('Pemrograman Mobile — Minggu 1'),
            ],
          ),
        ),
      ),
    );
  }
}
```

![Profil Mahasiswa Awal](./screenshots/Profil%20Mahasiswa.png)

## 3. Menambahkan Informasi NIM

Menambahkan NIM, dan informasi tambahan dengan menggunakan komponen dengan kode sebagai berikut setelah Text untuk menambahkan nama:

```dart
Text('244107020151'),
Text('Politeknik Negeri Malang'),
```

![Profil Mahasiswa](./screenshots/Profil%20Mahasiswa%20New.png)

---

## 4. Refleksi

### 1. Kapan pengembangan Native lebih tepat dipilih daripada Cross-Platform?

Pengembangan Native digunakan ketika aplikasi membutuhkan performa tinggi (seperti game berat) dan memerlukan akses ke fitur perangkat keras khusus yang belum didukung oleh framework cross-platform. Untuk aplikasi yang tidak memerlukan akses khusus ke salah satu platform, Flutter lebih praktis dan hemat waktu karena satu kode dapat digunakan untuk cross-platform.

### 2. Bagaimana perubahan State berhubungan dengan Widget Tree dan UI Deklaratif?

Pada Flutter, tampilan layar otomatis menyesuaikan dengan data (_state_). Saat data berubah, Flutter akan memperbarui tampilan widget yang terkait secara otomatis tanpa perlu mengubah teks atau elemen antarmuka secara manual satu per satu.

### 3. Mengapa commit kecil dengan pesan jelas bermanfaat bagi tim dan portofolio?

Commit kecil dengan pesan yang jelas membuat riwayat perubahan mudah dipahami oleh anggota tim lain, mempermudah pelacakan jika terjadi error, serta menunjukkan cara kerja yang rapi dan profesional pada portofolio.

---

## 5. Jurnal Belajar

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

### Kendala

Saat menjalankan verifikasi lisensi Android dengan perintah `flutter doctor --android-licenses`, proses gagal dengan pesan error bahwa command tersebut sudah (_deprecated_). Berdasarkan referensi pembahasan masalah serupa di forum GitHub, kendala ini diselesaikan dengan melakukan _downgrade_ versi komponen Android SDK Command-line Tools (`cmdline-tools`) ke versi sebelumnya. Setelah versi disesuaikan, command `flutter doctor --android-licenses` berhasil dijalankan.

---

## 6. Kesimpulan

Praktikum Minggu 01 telah berhasil diselesaikan dengan setup tools Flutter dan Android Emulator, membuat aplikasi Profil Mahasiswa dan dapat dijalankan, memahami perbedaan Hot Reload dan Hot Restart, serta menyelesaikan kendala lisensi SDK melalui penyesuaian versi `cmdline-tools`.
