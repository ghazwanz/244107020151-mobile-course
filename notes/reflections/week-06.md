# Refleksi Pembelajaran: Minggu 06

- **Topik**: Authentication, Security & Push Notifications (FCM)
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

1. **Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?**
   SharedPreferences menyimpan data sebagai plaintext di penyimpanan internal aplikasi. Pada perangkat yang di-root, backup tanpa enkripsi, atau eksploitasi pembacaan berkas, refresh token bisa dibaca pihak lain. Refresh token berumur panjang (mis. 7 hari) dan bisa menukar access token baru tanpa login, sehingga bila bocor penyerang dapat mengakses akun dalam waktu lama tanpa mengetahui kata sandi. Karena itu token hanya disimpan di `flutter_secure_storage` (Keystore/Keychain).

2. **Apa yang rusak bila `onTokenRefresh` diabaikan selama satu semester perkuliahan?**
   Token FCM berubah saat aplikasi di-reinstall, data dibersihkan, dipulihkan dari backup, atau token dirotasi Firebase. Tanpa `onTokenRefresh`, backend menyimpan token basi dan push notification tidak sampai ke perangkat — kegagalan senyap, karena dari sisi server pengiriman tampak berhasil. Sepanjang satu semester, pengumuman penting berpotensi tidak pernah diterima mahasiswa.

3. **Kapan memakai topik dan kapan memakai token perangkat?**
   - **Topik** untuk broadcast massal tanpa perlu tahu daftar token. Contoh: pengumuman jadwal kuliah atau libur nasional untuk seluruh mahasiswa.
   - **Token perangkat** untuk pesan personal ke satu pengguna. Contoh: nilai ujian atau tagihan UKT milik satu mahasiswa.

4. **Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?**
   (a) Draf AI hanya menyimpan `pendingDeepLink` saat tap banner foreground tanpa memicu navigasi, sehingga tap tidak membuka rute — saya tambahkan callback `onSelect` agar navigasi terjadi langsung. (b) Urutan inisialisasi FCM membuat `getInitialMessage()` terlewat saat cold start, sehingga deep link terminated gagal — saya pindahkan pendaftaran handler sebelum tugas berat. (c) API `flutter_local_notifications` v22 (named parameter) dan `NotifierProvider` Riverpod 3 saya sesuaikan. (d) `unsubscribeFromTopic` belum ada di draf, padahal diminta modul — saya tambahkan beserta switch di Home. (e) Banner background/terminated memakai channel fallback FCM yang berbeda dari foreground — saya buat channel `pengumuman` eksplisit dan menyetelnya sebagai channel default FCM. Rincian ada di `docs/ai_challenge.md`.

5. **Apa yang saya pelajari dari mengaudit ulang modul?**
   Membaca ulang modul secara kritis memunculkan item yang terlewat meski fitur utama sudah jalan: `unsubscribeFromTopic`, konsistensi channel, pembuktian token lifecycle lewat clear data, dan yang terpenting **titik "GANTI" ke FirebaseAuth** yang semula saya lewati. Ini menunjukkan bahwa "selesai" perlu diverifikasi terhadap teks modul, bukan hanya terhadap aplikasi yang berjalan. Bukti diambil langsung dari perangkat (`dumpsys notification`, logcat, `pm clear`).

6. **Pelajaran dari migrasi FirebaseAuth.**
   Setelah mock diganti Firebase Auth nyata, muncul bug yang tidak terlihat dari membaca kode: `User.refreshToken` ternyata **kosong di Android/iOS** karena SDK mengelola refresh token secara internal. Login tampak berhasil di log tetapi kode kita gagal mengambil token. Pelajaran: pahami perilaku platform (native vs web) dan baca dokumentasi paket, bukan hanya menyalin contoh.
