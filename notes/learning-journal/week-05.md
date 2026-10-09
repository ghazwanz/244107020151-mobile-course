# Jurnal Pembelajaran: Minggu 05

- **Topik**: Local Storage & Offline-First Architecture
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

### Ringkasan Teknis

- **Pemilihan Storage Sesuai Kebutuhan**: SharedPreferences untuk preferensi key-value kecil, SQLite (`sqflite`) untuk catatan yang butuh query terurut dan update parsial.
- **Repository Preferensi Terpusat**: `PrefsRepository` memusatkan akses key-value dan disambungkan ke `darkModeProvider` (`AsyncNotifier`).
- **CRUD Lokal dengan Penanda Sinkronisasi**: Model `Note` menyimpan `dirty` dan `updated_at`, sedangkan `NoteRepository` (dengan injeksi `openDb`) menangani CRUD, `countDirty`, dan `markAllSynced`.
- **Pola Offline-First**: Cache-first read menampilkan cache lokal lebih dulu lalu refresh di background; dirty flag + `syncNotes` menangani antrean tulisan; aturan konflik *last-write-wins* berbasis `updated_at`.
- **State Lokal dengan Riverpod**: `AsyncNotifier`/`AsyncValue` menampilkan empat state (loading, error, empty, success) untuk data lokal.
- **Preferensi Tema & Format Waktu Lokal**: Halaman `SettingsPage` membaca `darkModeProvider` dan `lastOpenedProvider`; helper `formatDateTime` mengubah nilai waktu ke zona lokal dengan format `09 Okt 2026, 18:26`.
- **Pengujian Terisolasi**: `FakeNoteRepository` menguji provider tanpa menyentuh SQLite sungguhan.

---

### Kendala yang Dihadapi & Solusi

1. **`databaseFactory not initialized` saat dijalankan di desktop**: `sqflite` hanya menginisialisasi factory otomatis di Android/iOS, sehingga gagal di macOS. **Solusi**: menjalankan aplikasi pada emulator Android.
2. **`TextEditingController was used after being disposed`**: controller dibuang tepat setelah `showDialog` selesai, sementara animasi keluar masih me-rebuild `TextField`. **Solusi**: memindahkan kepemilikan controller ke `StatefulWidget` dialog yang membuangnya di `dispose()`.
3. **Warning `unused_import` pada `settings_page.dart`**: kode modul hanya berisi provider/notifier tanpa widget halaman. **Solusi**: menambahkan widget `SettingsPage` pada file yang sama sehingga import `material.dart` terpakai dan warning hilang.
4. **Waktu mentah berformat ISO8601**: nilai `updated_at`/`last_opened_at` awalnya tampil sebagai string ISO mentah. **Solusi**: helper `formatDateTime` mengonversi ke waktu lokal dan memformatnya menjadi `09 Okt 2026, 18:26`.
