# Jurnal Pembelajaran: Minggu 07

- **Topik**: Clean Architecture in Flutter (SOLID, feature-first, domain/data/presentation)
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

### Ringkasan Teknis

- Memahami lima prinsip **SOLID** dan gejala pelanggarannya di Flutter (mis. widget 400 baris yang fetch API + parse JSON + format tanggal).
- Menerapkan **dependency rule**: `presentation → domain ← data`; dependensi hanya mengarah ke dalam.
- Memilih **feature-first** (`lib/features/<fitur>/{domain,data,presentation}`) untuk project multi-fitur, bukan layer-first global.
- Membedakan **entity** (murni, tanpa mapping) dan **model** (mapping `toMap`/`fromJson`/`toEntity`), serta peran **repository interface** (domain), **repository impl** (data), dan **use case** (domain).
- Menggunakan **record** Dart `({data, Failure? failure})` agar sukses/gagal eksplisit tanpa exception bocor ke presentation.
- Menerapkan **DI terpusat dengan Riverpod** (`Provider`/`NotifierProvider`) tanpa package DI tambahan; `main` memakai `ProviderContainer` sehingga tidak ada instansiasi repository manual.
- Menempatkan **infrastruktur bersama** (satu file database, satu klien Dio, provider lintas fitur, widget bersama) di `lib/shared/`, sementara `lib/core` dijaga steril dari framework.
- Mengekstrak fungsi murni (`formatDateTime`, `parseStoredDateTime`, `parseNoteId`) ke `lib/core/format.dart` agar dapat diuji tanpa widget.
- Mengonversi exception data layer menjadi `LocalFailure`/`NetworkFailure` sebelum mencapai UI.
- Menulis **11 test** (use case `GetNotes` & `SyncNotes` dengan repository palsu, mapping model, fungsi murni) — semua lulus; `flutter analyze` bersih; tiga grep sterilitas nol hasil.

---

### Kendala yang Dihadapi & Solusi

1. **Import cycle `routes.dart` ↔ halaman** — konstanta rute dan `GoRouter` dalam satu file membuat halaman mengimpor file yang juga mengimpor halaman.
   **Solusi**: konstanta rute murni dipindah ke `lib/core/routes.dart`; `GoRouter` tetap di `lib/routes.dart`.

2. **Lint `prefer_initializing_formals`** — repository memakai field privat (`_openDb`) dengan parameter bernama `openDb`; initializing formal untuk nama privat tidak valid.
   **Solusi**: field dibuat publik (`openDb`, `dio`) sehingga `this.openDb`/`this.dio` valid dan analyze bersih.

3. **`lib/core` harus tetap steril** — provider lintas fitur membutuhkan Riverpod, sedangkan grep sterilitas modul menyertakan `lib/core`.
   **Solusi**: provider lintas fitur dan infrastruktur bersama diletakkan di `lib/shared/`, bukan `lib/core/`.

4. **Satu file database untuk dua fitur** — tabel `notes` dan `cached_posts` berada di database yang sama.
   **Solusi**: `openAppDb()` di `lib/shared/data/` disuntikkan ke kedua repository sehingga tidak ada fitur yang mengimpor data fitur lain.

5. **Identitas package setelah menyalin project** — project Minggu 5 bernama `week5_offline_notes`.
   **Solusi**: mengganti nama package menjadi `week7_clean_architecture` di `pubspec.yaml`, `namespace`/`applicationId` Android, dan `MainActivity`; import di test disesuaikan.

6. **Menentukan batas use case** — modul mencontohkan `GetNotes` tetapi juga memperingatkan over-engineering.
   **Solusi**: memakai `GetNotes` + `SyncNotes` sebagai use case, sedangkan CRUD satu-baris lewat repository langsung, dengan alasan tertulis di `docs/ai_challenge.md`.

7. **`RenderFlex overflowed` pada dialog "Tambah Catatan" saat keyboard terbuka** — teramati saat uji perangkat.
   **Keputusan**: ini **perilaku bawaan Minggu 5** (kode dialog `_AddNoteDialog` disalin identik) dan **sengaja tidak diubah**, karena definisi selesai modul menuntut aplikasi berjalan identik sebelum/sesudah refactor. Refactor struktur tidak boleh dicampur dengan perubahan perilaku. Catatan ini didokumentasikan agar diketahui, bukan sebagai regresi refactor.
