# Refleksi Pembelajaran: Minggu 04

- **Topik**: Networking & REST API Integration
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

1. **Mengapa UI Dilarang Memanggil Dio Langsung dan Dampak Pelanggarannya**:
   - UI hanya bertugas merender tampilan berdasarkan state; memanggil Dio secara langsung mengikat antarmuka secara erat (*tight coupling*) dengan implementasi jaringan mentah.
   - Jika dilanggar, widget menjadi sulit diuji (*untestable*) tanpa mock HTTP yang rumit, duplikasi konfigurasi endpoint/header terjadi di berbagai file, dan perubahan skema API akan merusak banyak komponen UI sekaligus.

2. **Kapan Pagination Client-Side Cukup vs Kapan Harus Mengandalkan Pagination Server (`_page`/`_limit`)**:
   - Pagination *client-side* cukup jika dataset berukuran kecil dan statis (di bawah 100 data) sehingga seluruh data aman dimuat sekaligus ke memori tanpa membebani bandwidth dan performa rendering.
   - Pagination *server-side* wajib digunakan saat dataset besar atau terus bertambah (ratusan hingga ribuan item) untuk menghemat penggunaan kuota, mempercepat respon jaringan awal, dan menjaga penggunaan RAM perangkat tetap efisien.

3. **Bagaimana Exception Repository Berubah Menjadi AsyncError Tanpa Try/Catch di Setiap Widget dan Kapan Try/Catch Eksplisit Tetap Dibutuhkan**:
   - `AsyncNotifier.build()` secara otomatis menangkap exception yang dilempar oleh repository layer dan membungkusnya ke dalam `AsyncError(error, stackTrace)`. UI cukup mendeklarasikan penanganan error secara deklaratif menggunakan `.when(loading, error, data)`.
   - `try/catch` eksplisit tetap dibutuhkan pada aksi interaktif yang dipicu pengguna (*user-triggered events* seperti mutasi data form, tombol refresh manual, atau aksi tombol submit) saat ingin menampilkan feedback instan seperti `SnackBar` tanpa mengganti seluruh pohon widget.

4. **Bagian Hasil AI yang Diperbaiki dan Alasannya**:
   - Bagian yang diubah secara manual meliputi:
     1. *Defensive Null-Safety pada Model*: Mengubah casting langsung AI (`json['postId'] as int` dan `json['name'] as String`) menjadi konversi aman `(json['postId'] as num?)?.toInt() ?? 0` dan `(json['name'] as String?)?.trim() ?? ''` guna mengantisipasi payload API yang mengirim tipe angka mengambang atau nilai `null`.
     2. *Lokalisasi Pesan Error*: Mengganti pesan error berbahasa Inggris generik bawaan AI dengan integrasi mapper `friendlyErrorMessage` berbahasa Indonesia.
     3. *Penyempurnaan Unit Test*: Menambahkan pengujian khusus untuk missing key dan field bernilai null pada `test/comment_test.dart`.
   - *Penyebab*: AI cenderung berfokus pada *happy path* berdasarkan dokumentasi resmi JSONPlaceholder tanpa mempertimbangkan skenario anomali data di lingkungan produksi (*keterbatasan konteks defensif*), serta prompt awal yang menitikberatkan struktur dasar ketimbang aturan null-safety ketat.
