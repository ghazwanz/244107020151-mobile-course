# Dokumentasi AI Challenge: Clean Architecture (Minggu 07)

Dokumen ini mencatat prompt, output awal AI, tabel usulan-vs-keputusan-final, dan hasil tiga grep verifikasi untuk modul Minggu 07 — sesuai *Tanggung jawab teknis* bagian AI Challenge.

Project: **`week7_clean_architecture`** (refactor dari `week5_offline_notes`).

---

## 1. Prompt yang Digunakan

Prompt disalin dari modul dan **diadaptasi ke project Minggu 5** (bukan `campus_notify`), karena basis refactor yang dipakai adalah `week5_offline_notes`.

```text
Project Flutter saya: week5_offline_notes (catatan offline + cache posts + pengaturan).
Kondisi kini: folder lib/{data, pages, utils, widgets},
repository tercampur dengan implementasi (NoteRepository konkret tanpa interface),
provider & notifier tersebar (di file repository dan file halaman),
widget memakai data layer langsung, dan util belum menjadi core.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur notes + posts + settings.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

---

## 2. Output Awal AI

Ringkasan usulan draf awal AI:

```text
lib/
├── core/
│   ├── failures.dart
│   ├── usecases/           # AI: satu use case untuk SETIAP operasi
│   │   ├── get_notes.dart
│   │   ├── add_note.dart
│   │   ├── delete_note.dart
│   │   ├── get_note_by_id.dart
│   │   └── sync_notes.dart
│   └── di.dart             # AI: memakai get_it sebagai service locator
├── data/
│   ├── repositories/
│   │   ├── app_repository.dart     # AI: satu AppRepository untuk semua fitur
│   │   └── note_repository.dart    # interface + impl di folder yang sama
│   ├── models/note_model.dart
│   └── local/db.dart
├── features/
│   ├── notes/...           # AI: campur (sebagian di core/data, sebagian di feature)
│   ├── posts/...
│   └── settings/...
└── main.dart
```

Poin penting draf AI:

- Membuat use case untuk **setiap** operasi, termasuk `AddNote`/`DeleteNote` yang hanya memanggil satu baris repository.
- Menyatukan semua repository ke dalam satu `AppRepository` besar (melanggar Interface Segregation).
- Menaruh interface dan implementasi `NoteRepository` pada folder yang sama di `data/`.
- Menambahkan `get_it` sebagai service locator meskipun Riverpod sudah tersedia.
- Menempatkan `di.dart` (bergantung Riverpod/get_it) di dalam `core/`.

---

## 3. Tabel Usulan AI vs Keputusan Final

| # | Usulan draf AI | Keputusan final | Alasan teknis |
| :-: | :--- | :--- | :--- |
| 1 | Use case untuk **setiap** operasi (termasuk `AddNote`, `DeleteNote`, `GetNoteById`) | **Ditolak sebagian.** Hanya `GetNotes` dan `SyncNotes` yang jadi use case | CRUD satu-baris cukup repository → notifier; use case per CRUD = over-engineering (biaya tanpa nilai untuk tim kecil) |
| 2 | Satu `AppRepository` besar untuk notes + posts + settings | **Ditolak.** Repository per fitur (`NoteRepository`, `PostsRepository`, `PrefsRepository`) | Melanggar Interface Segregation; klien dipaksa bergantung pada yang tidak dipakai |
| 3 | Interface + impl `NoteRepository` di folder `data/` | **Diterima sebagian → diubah.** Interface di `domain/`, impl di `data/` | Interface harus di domain agar arah dependensi benar (domain tidak tahu detail teknologi) |
| 4 | Tambahkan `get_it` sebagai DI | **Ditolak.** Cukup `Provider`/`NotifierProvider` Riverpod | Menambah dependensi & dua sistem DI tanpa manfaat; Riverpod sudah menyediakan DI + state |
| 5 | `di.dart` (bergantung framework) di `core/` | **Ditolak.** DI lintas fitur di `presentation/providers`; infra bersama di `shared/` | `lib/core` dijaga steril (grep #2 menyertakan `lib/core`) |
| 6 | Entity menempel mapping (`toMap`/`fromJson`) | **Ditolak.** Entity murni; mapping hanya di `*_model.dart` | Entity harus bebas format luar (JSON/SQLite) |
| 7 | Struktur feature-first untuk `notes` | **Diterima.** `features/notes/{domain,data,presentation}` | Sesuai pilihan modul untuk project multi-fitur |
| 8 | Terapkan pola sama ke fitur kedua | **Diterima.** Diterapkan ke `posts` dan `settings` | Refactoring Challenge: jangan biarkan satu fitur bersih dan sisanya kotor |
| 9 | Ekstrak formatting & parsing rute | **Diterima.** `core/format.dart` (`formatDateTime`, `parseStoredDateTime`, `parseNoteId`) | Fungsi murni dapat diuji tanpa widget |
| 10 | Konversi exception → pesan ramah | **Diterima.** `LocalFailure`/`NetworkFailure` di `core/failures.dart` | UI hanya menerima `message`, tidak ada exception mentah |

---

## 4. AI Verification Checklist

| Kriteria Evaluasi | Status | Catatan |
| :--- | :--: | :--- |
| Interface repository di `domain`, implementasi di `data` | ✅ | `features/notes/domain/repositories/note_repository.dart` (abstract) vs `features/notes/data/repositories/note_repository_impl.dart` |
| `domain` bebas import Flutter/Dio/SQLite/Firebase (diperiksa dengan grep) | ✅ | Grep #2 = 0 hasil pada `lib/features/*/domain` dan `lib/core` |
| Tidak membuat use case untuk tiap CRUD satu-baris | ✅ | Hanya `GetNotes` + `SyncNotes`; `addNote`/`deleteNote` lewat repository langsung (alasan tertulis di tabel #1) |
| Entity bebas mapping (`toMap`/`fromMap`/`toJson` hanya di model) | ✅ | `Note`/`Post` murni; mapping hanya di `note_model.dart`/`post_model.dart` |
| Wiring DI terpusat di provider; widget tidak `new Repository()` | ✅ | `presentation/providers/*`; `main` memakai `ProviderContainer`, tidak ada `PrefsRepository()` manual |
| Keputusan final + alasan (boleh berbeda dari AI) | ✅ | Tabel bagian 3 |

---

## 5. Hasil Tiga Grep Verifikasi

```bash
# (1) Presentation steril dari data mentah — harus NOL
rg "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/*/presentation lib/pages
# → 0 hasil

# (2) Domain & core steril dari framework — harus NOL
rg "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase" lib/features/*/domain lib/core
# → 0 hasil

# (3) Static analysis + test
flutter analyze   # No issues found!
flutter test      # All tests passed! (11)
```

Catatan: `lib/pages` pada grep #1 sudah tidak ada (seluruh halaman kini di `features/*/presentation/pages`), sehingga pemeriksaan efektif ada pada `lib/features/*/presentation`.

---

## 6. Catatan Deviation (trade-off yang disadari)

- **`lib/core/routes.dart` vs `lib/routes.dart`.** Modul menyarankan `lib/routes.dart` memuat "GoRouter + konstanta rute". Menyatukan keduanya membuat halaman mengimpor file yang juga mengimpor halaman (import cycle). Solusinya: konstanta rute murni di `lib/core/routes.dart`, konfigurasi `GoRouter` di `lib/routes.dart`.
- **`lib/shared/` untuk infrastruktur bersama.** Modul mencontohkan `core/providers.dart`, tetapi grep sterilitas menyertakan `lib/core` sehingga provider ber-Riverpod tidak boleh di sana. Infrastruktur bersama (database, provider lintas fitur, widget bersama) diletakkan di `lib/shared/`.
- **Satu file database untuk dua fitur.** Tabel `notes` dan `cached_posts` berbagi satu database; `openAppDb()` disuntikkan ke kedua repository agar tidak ada fitur yang mengimpor data fitur lain.
