# Jurnal Pembelajaran: Minggu 04

- **Topik**: Networking & REST API Integration
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

### Ringkasan Teknis

- **Konfigurasi HTTP Client Terpusat**: Mengonfigurasi `Dio` dengan `BaseOptions` (base URL, connect/receive timeout 10 detik) dan interceptor logging pada satu tempat agar pengelolaan komunikasi jaringan konsisten dan aman dari memory leak.
- **Serialisasi JSON Aman Null**: Mengimplementasikan model data dengan konversi eksplisit defensif (`as num?` / `as String? ?? ''`) untuk mencegah error run-time saat skema respons API dummy JSONPlaceholder mengalami anomali.
- **Pemisahan Lapisan dengan Repository Pattern**: Mengisolasi pemanggilan endpoint REST API (`GET /posts` dan `GET /comments`) di dalam kelas repository, memastikan antarmuka UI tidak berinteraksi langsung dengan driver HTTP mentah.
- **Manajemen Siklus Asinkron Deklaratif**: Menghubungkan repository ke UI melalui Riverpod `AsyncNotifier` dan mengekspos state menggunakan `AsyncValue.when(loading, error, data)` untuk menangani 4 state esensial aplikasi mobile: loading, error, empty, dan success.
- **Implementasi Infinite Scroll Pagination**: Menerapkan pagination server-side berbasis query parameters (`_page` & `_limit`) menggunakan `ScrollController` listener dengan ambang batas 200px dan guard ganda untuk mencegah duplicate request.
- **Testing & Mocking Terisolasi**: Melakukan pengujian unit parsing model, verifikasi pemetaan pesan error jaringan ramah pengguna, serta pengujian state provider menggunakan fake repository tanpa koneksi internet sungguhan.

---

### Kendala yang Dihadapi & Solusi

1. **Inisialisasi Project Tanpa Menghasilkan Folder Platform Eksternal**:
   - Menghindari pembuatan folder platform (`android/`, `ios/`, dll.) yang dapat mengotori repositori portofolio dan melanggar aturan kebersihan Git.
   - **Solusi**: Menyusun langsung berkas `pubspec.yaml`, `analysis_options.yaml`, `lib/`, `test/`, dan `screenshots/` di dalam folder kerja minggu berjalan, lalu menjalankan `flutter pub get` untuk mengunduh pustaka dependensi secara bersih.

2. **Auto-Retry Infinite Loop pada Test Suite Riverpod**:
   - Pada pengujian `provider error dengan repository palsu`, implementasi default Riverpod 3 dapat memicu mekanisme retry otomatis internal sehingga fungsi pembantu `readPostsErrorOnce` berisiko mengalami timeout atau deadlock.
   - **Solusi**: Menambahkan konfigurasi `retry: (retryCount, error) => null` pada definisi `postListProvider` untuk menonaktifkan auto-retry otomatis selama pengujian berlangsung.

3. **Double Triggering Listener pada ScrollController Pagination**:
   - Event listener `ScrollController` terpicu berulang kali dalam hitungan milidetik saat pengguna menggulir cepat melewati ambang batas 200px, berpotensi memicu request berulang ke server.
   - **Solusi**: Menerapkan guard ganda di awal method: `if (state.isLoadingMore || !state.hasMore) return;` sebelum menaikkan nomor halaman dan mengeksekusi request jaringan.
