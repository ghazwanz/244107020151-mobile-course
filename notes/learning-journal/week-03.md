# Jurnal Pembelajaran: Minggu 03

- **Topik**: Navigation & State Management
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

### Ringkasan Teknis

- **Deklaratif Routing dengan GoRouter**: Mengonfigurasi `GoRouter` dan `MaterialApp.router` dengan rute `/` untuk daftar tugas dan `/stats` untuk halaman statistik, serta berpindah halaman menggunakan `NavigationBar`.
- **Manajemen State Terpusat dengan Riverpod**: Membungkus root aplikasi dengan `ProviderScope`, mengelola daftar tugas secara *immutable* menggunakan `TodoListNotifier` (`Notifier<List<Todo>>`), dan membuat provider turunan `uncompletedTodosProvider`.
- **Komposisi Widget Reusable**: Memisahkan komponen item tugas ke dalam widget independen `TodoTile` untuk memperpendek metode `build` dan mempermudah pengujian.
- **Penanganan State Asinkron**: Menggunakan `AsyncNotifier` dan `AsyncValue` untuk menangani siklus data asinkron secara aman melalui pola `.when(loading, error, data)` yang tersinkronisasi langsung dengan `todoListProvider` tanpa data dummy.
- **Automated Testing**: Memvalidasi fungsionalitas penambahan tugas melalui widget test (`test/widget_test.dart`), pengujian logika state lewat unit test (`test/notifier_test.dart`), dan screenshot rendering (`test/golden_screenshot_test.dart`).

---

### Kendala yang Dihadapi & Solusi

1. **Tampilan Simulasi Error Tidak Muncul pada Halaman Statistik**:
   - Saat simulasi kegagalan 30% (maupun saat diuji dengan probabilitas lebih tinggi) terjadi pada `AsyncNotifier.build()`, antarmuka tetap tertahan pada indikator pemuatan (*loading spinner*) dan langsung berpindah ke tampilan sukses tanpa pernah menampilkan pesan error atau tombol *Coba lagi*.
   - **Penyebab**: Fitur bawaan Riverpod 3 (`defaultRetry`) secara otomatis menjalankan percobaan ulang di latar belakang hingga 10 kali saat terjadi exception, sehingga status provider tertahan di `AsyncLoading(retrying: true)` dan salah satu percobaan ulang berhasil sebelum state error sempat dirender ke antarmuka.
   - **Solusi**: Menambahkan parameter `retry: (_, _) => null` pada deklarasi `AsyncNotifierProvider` untuk menonaktifkan auto-retry latar belakang Riverpod 3, serta melakukan *Hot Restart* agar state instance di memori ter-reset secara bersih.
