# Jurnal Pembelajaran: Minggu 06

- **Topik**: Authentication, Security & Push Notifications (FCM)
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

### Ringkasan Teknis

- Memahami tiga jenis token (ID, access, refresh) dan pola penyimpanan aman di `flutter_secure_storage`.
- Menerapkan **Firebase Auth** (email + kata sandi) sebagai sumber ID token, dengan abstraksi backend agar tetap bisa diuji tanpa Firebase.
- Menerapkan refresh otomatis satu kali pada `401` lewat interceptor Dio, dengan fallback logout bila refresh ikut kedaluwarsa.
- Membedakan perilaku `notification` vs `data` payload pada tiga app state dan alasan aplikasi notifikasi kampus memakai gabungan keduanya.
- Mengelola token lifecycle FCM: `getToken`, `onTokenRefresh`, `subscribeToTopic`/`unsubscribeFromTopic`, serta background handler top-level ber-`@pragma('vm:entry-point')`.
- Menangani deep link notifikasi ke GoRouter: foreground (`onMessage` + local notification), background (`onMessageOpenedApp`), terminated (`getInitialMessage`).
- Membuat notification channel Android eksplisit dan menyetelnya sebagai channel default FCM (`default_notification_channel_id`) agar banner konsisten di semua app state.
- Membuktikan token lifecycle lewat clear data perangkat (`pm clear`) — token berubah dan terkirim ulang ke backend.
- Refactoring: konstanta rute (`lib/routes.dart`), fungsi murni `routeFromMessage`, dan pemetaan error (`lib/data/api_errors.dart`) agar dapat diunit-test tanpa Firebase.
- Menulis 10 test (parsing rute, sesi/refresh, pemetaan error) — semua lulus; `flutter analyze` bersih.

---

### Kendala yang Dihadapi & Solusi

1. **API paket berubah** — `flutter_local_notifications` v22 memakai named parameter (`initialize(settings:)`, `show(id: ...)`) dan Riverpod 3 menghapus `StateProvider`.
   **Solusi**: membaca sumber paket di `~/.pub-cache`, lalu menyesuaikan menjadi named parameter dan `NotifierProvider`.

2. **Deep link terminated gagal** — percobaan pertama cold start mendarat di Home, bukan `/pengumuman/3`.
   **Solusi**: memindahkan `handleTerminated()`/`listenForeground()` ke sebelum tugas berat (`getToken`, `POST /devices`, `requestPermission`). Diverifikasi lewat logcat: `[FCM] getInitialMessage ... route=/pengumuman/3`.

3. **Tap banner foreground tidak navigasi** — draf AI hanya menyimpan `pendingDeepLink` tanpa memicu navigasi.
   **Solusi**: menambahkan callback `onSelect` pada `initLocalNotifications`.

4. **Simulasi state terminated** — `am force-stop` menaruh aplikasi di *stopped state* sehingga FCM tidak terkirim.
   **Solusi**: mematikan proses dari state background (`am kill`) agar notifikasi tetap masuk, lalu tap untuk memicu cold start.

5. **Tool MCP tidak mendukung `data` payload** — `messaging_send_message` hanya mengirim `notification`.
   **Solusi**: mengirim payload gabungan lewat FCM HTTP v1 (`messages:send`) dengan access token dari `gcloud auth print-access-token`.

6. **Build Android gagal** — `flutter_local_notifications` butuh desugaring.
   **Solusi**: mengaktifkan `isCoreLibraryDesugaringEnabled`, `minSdk = 23`, dan menambah `desugar_jdk_libs:2.1.4`.

7. **Channel notifikasi tidak konsisten** — banner background/terminated memakai `fcm_fallback_notification_channel`, berbeda dari foreground (`pengumuman`). Ditemukan lewat `dumpsys notification`.
   **Solusi**: membuat channel `pengumuman` via `createNotificationChannel` dan menambahkan `com.google.firebase.messaging.default_notification_channel_id` di `AndroidManifest.xml`; diverifikasi channel `pengumuman` kini dipakai di background.

8. **`unsubscribeFromTopic` terlewat** — audit ulang modul menemukan permintaan subscribe **dan** unsubscribe topik.
   **Solusi**: menambahkan `subscribeCampusTopic()`/`unsubscribeCampusTopic()` + switch di Home; dibuktikan pesan ke topik tidak diterima saat nonaktif dan diterima lagi saat aktif.

9. **Titik "GANTI" ke FirebaseAuth** — modul meminta mock auth diganti `FirebaseAuth.instance.signInWithEmailAndPassword`.
   **Solusi**: mengimplementasikan `FirebaseAuthBackend` + abstraksi `AuthBackend`; login nyata diverifikasi di emulator, sesi bertahan setelah restart, logout memanggil `signOut()`.

10. **`refreshToken` kosong di Android** — login Firebase Auth berhasil tetapi kode menampilkan "Gagal memperoleh token".
   **Solusi**: memahami bahwa `User.refreshToken` kosong di native (dikelola SDK internal); memakai ID token sebagai `access` dan uid sebagai penanda sesi, serta `getIdToken(true)` untuk refresh.
