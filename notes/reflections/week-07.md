# Refleksi Pembelajaran: Minggu 07

- **Topik**: Clean Architecture in Flutter (SOLID, feature-first, domain/data/presentation)
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

1. **Mengapa interface repository harus tinggal di domain, bukan di data? Apa yang rusak bila dibalik?**
   Interface adalah kontrak yang dibutuhkan domain untuk menjalankan aturan bisnis, jadi pemiliknya adalah domain. Bila interface ditaruh di data, arah dependensi terbalik: domain (dan presentation) harus mengimpor `data/` hanya untuk mengetahui kontraknya. Akibatnya domain tidak lagi steril dari teknologi — ia ikut bergantung pada struktur folder data, sulit diuji murni, dan setiap penggantian sumber data (SQLite → REST) memaksa perubahan di domain. Dengan interface di domain, data-lah yang menyesuaikan diri ke domain.

2. **Kapan use case benar-benar dibutuhkan, dan kapan repository langsung ke notifier sudah cukup?**
   Use case dibutuhkan saat operasi menggabungkan lebih dari satu langkah/repository atau mengandung aturan bisnis (validasi, sorting, sinkronisasi). Contoh nyata di project ini: `SyncNotes` (hitung `dirty` → kirim ke server → tandai tersinkron). Untuk CRUD satu-baris seperti `addNote`/`deleteNote`, notifier cukup memanggil repository langsung.

3. **Apa biaya over-engineering (use case per CRUD satu-baris) bagi tim kecil? Kapan biayanya sepadan?**
   Biayanya: bertambahnya file dan lapisan tanpa nilai, lebih banyak kode untuk dibaca dan diubah, serta dua tempat yang harus dijaga setiap kali model berubah — semuanya memperlambat tim kecil tanpa menambah kualitas. Biaya baru sepadan ketika operasi tumbuh menjadi orkestrasi multi-sumber, memiliki aturan bisnis yang jelas, atau membutuhkan pengujian terisolasi tingkat tinggi.

4. **Bagian mana dari usulan AI yang Anda tolak atau sederhanakan, dan mengapa?**
   (a) Use case untuk **setiap** operasi saya tolak — cukup repository langsung untuk CRUD satu-baris. (b) Satu `AppRepository` raksasa saya tolak karena melanggar Interface Segregation; saya pisah per fitur (`NoteRepository`, `PostsRepository`, `PrefsRepository`). (c) Interface + impl di folder `data/` yang sama saya ubah: interface dipindah ke `domain/`. (d) Penambahan `get_it` saya tolak karena `Provider` Riverpod sudah cukup. (e) `di.dart` ber-framework di `core/` saya tolak; `lib/core` dijaga steril dan infra bersama dipindah ke `lib/shared/`. Rincian ada di `docs/ai_challenge.md`.

5. **Pelajaran dari memisahkan rute (`core/routes.dart` vs `routes.dart`).**
   Menyatukan konstanta rute dan konfigurasi `GoRouter` dalam satu file membuat halaman harus mengimpor file yang juga mengimpor halaman (import cycle). Memisahkan konstanta murni ke `core/routes.dart` menyelesaikan masalah sekaligus membuat konstanta rute bisa dipakai tanpa menyeret konfigurasi router. Ini contoh bahwa "rapi" bukan tujuan akhir — arah dependensi yang benar yang dinilai.

6. **Yang saya pahami dari aturan "bukan sekadar pindah folder".**
   Memindahkan file ke `features/` tidak ada artinya bila widget masih memanggil `Dio`/`openDatabase` langsung. Yang diuji adalah **arah panah dependensi**, dibuktikan lewat tiga grep sterilitas yang harus nol hasil. Refactor baru sah ketika grep nol, analyze bersih, dan perilaku aplikasi tetap identik.
