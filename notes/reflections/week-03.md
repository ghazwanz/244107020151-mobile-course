# Refleksi Pembelajaran: Minggu 03

- **Topik**: Navigation & State Management
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

1. **Kapan setState Masih Cukup, dan Kapan State Harus Naik ke Riverpod**:
   - `setState` masih cukup untuk state lokal satu widget yang tidak memengaruhi widget atau halaman lain, seperti membuka/menutup dialog atau input teks sementara dalam controller.
   - State harus naik ke Riverpod saat data perlu dibagikan antar-halaman (seperti daftar ToDo yang dibaca pada halaman tugas dan halaman statistik), bertahan di luar daur hidup widget, atau membutuhkan pengujian unit terisolasi tanpa UI.

2. **Perbedaan `context.go` dan `context.push`, Serta Waktu Penggunaannya**:
   - `context.go` mengganti rute aktif sesuai bagan path deklaratif (mengatur stack ke path target), sangat tepat digunakan untuk navigasi utama (seperti `NavigationBar`), deep link, atau redirect alur otentikasi.
   - `context.push` menumpuk layar baru di atas stack navigasi yang sedang aktif, tepat digunakan untuk alur detail atau drill-down di mana pengguna dapat kembali ke halaman sebelumnya menggunakan tombol *back*.

3. **Bagaimana `AsyncValue` Mencegah Bug Dibanding Tiga Boolean Terpisah**:
   - Tiga boolean terpisah (`isLoading`, `hasError`, `isSuccess`) rentan menciptakan inkonsistensi state, seperti `isLoading` dan `hasError` bernilai `true` secara bersamaan yang dapat memicu tampilan antarmuka ganda atau layar putih.
   - `AsyncValue` membungkus status asinkron ke dalam satu tipe *union* yang saling eksklusif (loading, error, data). Fungsi `.when()` memastikan seluruh kemungkinan kondisi antarmuka wajib ditangani secara eksplisit.

4. **Bagian Hasil AI yang Diperbaiki dan Alasannya**:
   - Menambahkan pembersihan input `controller.clear()` sebelum menutup dialog `Navigator.pop(context)` agar widget teks input tidak tertinggal di pohon antarmuka saat pengujian *single-frame* widget test dijalankan, sehingga pengujian otomatis lulus 100%.
   - Menyesuaikan arsitektur provider agar menggunakan `Notifier` dan `AsyncNotifier` versi Riverpod modern, menggantikan pola `StateProvider` yang sudah tidak disarankan.
