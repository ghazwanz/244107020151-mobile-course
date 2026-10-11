# Dokumentasi AI Challenge: Authentication, Security & FCM

Dokumen ini mencatat prompt, output awal AI, daftar perbaikan manual, dan tabel pengujian tiga app state untuk modul Minggu 06 (Authentication, Security & Push Notifications) — sesuai _Tanggung jawab teknis_ bagian AI Challenge.

---

## 1. Prompt yang Digunakan

Prompt disalin persis dari modul (bagian _AI Prompt Challenge_):

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

---

## 2. Output Awal AI

Draf awal AI menghasilkan `lib/messaging/push_service.dart` dengan struktur yang secara umum benar: `requestNotificationPermission()`, `initLocalNotifications()`, `initFcmToken()`, `firebaseMessagingBackgroundHandler()` top-level ber-`@pragma('vm:entry-point')`, `listenForeground()`, dan `handleTerminated()`. Kerangka ini dipakai sebagai titik awal, lalu diverifikasi dan diperbaiki secara manual (bagian 3 dan 5).

Ringkasan draf awal AI:

```dart
final _local = FlutterLocalNotificationsPlugin();
String? pendingDeepLink;

Future<bool> requestNotificationPermission() async { /* requestPermission(...) */ }

Future<void> initLocalNotifications() async {
  await _local.initialize(
    const InitializationSettings(android: ..., iOS: ...),
    onDidReceiveNotificationResponse: (response) {
      pendingDeepLink = response.payload; // <- celah: tidak langsung navigasi
    },
  );
}

Future<void> initFcmToken({required Future<void> Function(String) onToken}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void listenForeground(void Function(String route) go) {
  FirebaseMessaging.onMessage.listen((message) async { /* _local.show(...) */ });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    go(message.data['route'] ?? '/');
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) go(initial.data['route'] ?? '/');
  if (pendingDeepLink != null) go(pendingDeepLink!);
}
```

---

## 3. AI Verification Checklist

| Kriteria Evaluasi                                                 | Status | Catatan Temuan & Analisis                                                                                                                                                                                                                                |
| :---------------------------------------------------------------- | :----: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Background handler fungsi top-level + `@pragma('vm:entry-point')` |   ✅   | Draf AI sudah benar. Handler bukan method kelas, tidak mengakses `BuildContext`/Riverpod, dan didaftarkan lewat `registerBackgroundHandler()` sebelum `runApp`.                                                                                          |
| `onTokenRefresh` mengirim token baru ke backend, bukan hanya log  |   ✅   | `initFcmToken(onToken:)` memanggil `onToken` untuk token awal **dan** pada `onTokenRefresh.listen(onToken)`. Callback di `main.dart` mengirim `POST /devices` (`{fcm_token, platform}`). Endpoint didokumentasikan karena backend kampus belum tersedia. |
| Foreground memakai local notification manual                      |   ✅   | Sistem **tidak** menampilkan banner otomatis saat foreground. `onMessage` memanggil `_local.show(...)` dengan channel `pengumuman`. Dibuktikan lewat screenshot `05-foreground-notification.png`.                                                        |
| Klik dari tiga state masuk ke rute yang benar                     |   ✅   | Terbukti pada ketiga state (tabel bagian 4). Perbaikan manual diperlukan untuk state terminated (lihat bagian 5, poin 4).                                                                                                                                |
| Token/secret tidak di-hardcode dan tidak di-log penuh             |   ✅   | Token hanya di `flutter_secure_storage`; UI menampilkan 12 karakter pertama + `...` (`maskToken`). Tidak ada token penuh di log/screenshot. `google-services.json` di-_ignore_ Git.                                                                      |
| Keputusan final beserta alasan teknis terdokumentasi              |   ✅   | Lihat bagian 5.                                                                                                                                                                                                                                          |

---

## 4. Tabel Pengujian Tiga App State

Payload uji (gabungan `notification` + `data`, sama untuk ketiga state):

```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Jadwal kuliah berubah",
      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
    },
    "data": { "route": "/pengumuman/3", "id": "3" }
  }
}
```

| State      | Yang Diharapkan                                                  | Hasil | Bukti                                                          |
| :--------- | :--------------------------------------------------------------- | :---: | :------------------------------------------------------------- |
| Foreground | Banner lokal muncul (manual), klik masuk ke `/pengumuman/3`      |  ✅   | `05-foreground-notification.png`, `06-foreground-deeplink.png` |
| Background | Banner sistem muncul, klik masuk ke `/pengumuman/3`              |  ✅   | `07-background-notification.png`, `08-background-deeplink.png` |
| Terminated | Aplikasi cold start ke `/pengumuman/3` via `getInitialMessage()` |  ✅   | `09-terminated-notification.png`, `10-terminated-deeplink.png` |

Catatan metode uji:

- **Foreground**: aplikasi terbuka di halaman Home, pesan dikirim ke topik. Karena sistem tidak menampilkan banner otomatis, `onMessage` menampilkan notifikasi lokal; tap → `onSelect` → `_router.go('/pengumuman/3')`.
- **Background**: aplikasi ditekan Home (launcher di depan). Banner sistem muncul otomatis; tap → `onMessageOpenedApp` → navigasi.
- **Terminated**: proses aplikasi dimatikan (bukan _force-stop_ yang masuk _stopped state_, melainkan `am kill` dari state background agar FCM tetap terkirim). Saat notifikasi di-tap, aplikasi cold start dan `getInitialMessage()` mengembalikan `route=/pengumuman/3` (dibuktikan lewat logcat: `[FCM] getInitialMessage ... route=/pengumuman/3`).

### Perbedaan Platform: Android 13+ vs iOS (permintaan prompt)

Sesuai permintaan prompt, bagian yang **berbeda** antar platform ditandai berikut ini:

| Aspek                   | Android 13+ (API 33+)                                                                                                                                  | iOS                                                                                                               |
| :---------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------- |
| **Izin notifikasi**     | `POST_NOTIFICATIONS` runtime permission; diminta eksplisit via `FirebaseMessaging.requestPermission()` (dipetakan ke dialog sistem).                   | Dialog izin ditampilkan sekali oleh sistem saat `requestPermission()`; status `provisional` mungkin tanpa dialog. |
| **Banner foreground**   | Sistem **tidak** menampilkan otomatis → wajib `flutter_local_notifications` (`onMessage` → `_local.show`).                                             | `onMessage` juga manual; perlu `DarwinInitializationSettings` + `onDidReceiveNotificationResponse`.               |
| **Channel notifikasi**  | Wajib channel eksplisit (Android 8+). Channel `pengumuman` dibuat via `createNotificationChannel` dan diset sebagai `default_notification_channel_id`. | Tidak ada konsep channel; pengaturan lewat `DarwinNotificationDetails`.                                           |
| **Konfigurasi build**   | `google-services.json` + plugin `com.google.gms.google-services`; butuh `minSdk 23` + core library desugaring.                                         | `GoogleService-Info.plist` + kapabilitas Push Notifications + sertifikat APNs.                                    |
| **`minSdk`/desugaring** | Perlu untuk `flutter_local_notifications`.                                                                                                             | Tidak relevan.                                                                                                    |

Bagian yang **tidak boleh** mengakses `BuildContext` (berjalan di isolate terpisah / di luar siklus widget):

- `firebaseMessagingBackgroundHandler()` — top-level, `@pragma('vm:entry-point')`, tanpa `BuildContext` maupun Riverpod.
- Callback `onTokenRefresh.listen(...)` dan `onMessageOpenedApp` harus mengirim **rute/string**, bukan `BuildContext`; navigasi dilakukan lewat router global (`_router.go`) atau `onSelect`.

Catatan: implementasi pada project ini **Android-only** (Firebase app hanya Android), sehingga jalur iOS di atas bersifat referensi, bukan yang diuji.

---

## 5. Keputusan Final & Perbaikan Manual

1. **API `flutter_local_notifications` v22 berubah ke named parameter.**
   Draf AI memakai positional argument (`initialize(settings)`, `show(id, title, ...)`) yang gagal dianalisis. Diperbaiki menjadi `initialize(settings: ...)` dan `show(id: ..., title: ..., notificationDetails: ..., payload: ...)`.

2. **`StateProvider` tidak tersedia di Riverpod 3.**
   Diganti dengan `NotifierProvider<FcmTokenNotifier, String?>` (`lib/providers/push_provider.dart`) agar sesuai API Riverpod modern.

3. **Celah foreground tap (temuan utama).**
   Draf AI hanya menyimpan `pendingDeepLink = response.payload` pada tap banner foreground, padahal `pendingDeepLink` hanya dibaca saat `handleTerminated` (startup). Akibatnya tap banner saat aplikasi terbuka **tidak** bernavigasi. Diperbaiki: `initLocalNotifications` menerima callback `onSelect` yang langsung memanggil router, sementara `pendingDeepLink` dipertahankan sebagai jalur cadangan.

4. **Urutan inisialisasi FCM memengaruhi deep link terminated (bug nyata).**
   Pada percobaan pertama, `handleTerminated()` dipanggil setelah `getToken()` + `POST /devices` + `requestPermission()`. Saat aplikasi cold start dari notifikasi, `getInitialMessage()` sudah "terlewat" sehingga aplikasi mendarat di Home, bukan `/pengumuman/3`. Perbaikan: `handleTerminated()` dan `listenForeground()` didaftarkan **lebih dulu**, sebelum tugas berat. Setelah perbaikan, logcat menunjukkan `route=/pengumuman/3` dan halaman detail terbuka. Ini contoh nyata mengapa "membaca kode saja tidak cukup" — perilakunya baru terlihat saat diuji di perangkat.

5. **`unsubscribeFromTopic` belum ada di draf AI.**
   Prompt AI Challenge menyebut `subscribe/unsubscribe` topik `pengumuman-kampus`, tetapi draf hanya berlangganan. Ditambahkan `subscribeCampusTopic()` / `unsubscribeCampusTopic()` dan switch di Home. Dibuktikan: saat topik nonaktif pesan ke topik **tidak** diterima (screenshot `12`), saat aktif kembali diterima (`13`).

6. **Channel notifikasi tidak konsisten antar state (temuan uji perangkat).**
   Semula banner foreground memakai channel `pengumuman`, sedangkan background/terminated memakai `fcm_fallback_notification_channel` bawaan FCM. Ditemukan lewat `dumpsys notification`. Diperbaiki dengan `createNotificationChannel` (channel `pengumuman`, importance high) + `com.google.firebase.messaging.default_notification_channel_id` di `AndroidManifest.xml`. Setelah perbaikan, `dumpsys` menunjukkan channel `pengumuman` dipakai di background (screenshot `14`).

7. **Bug `refreshToken` kosong di Android (temuan uji perangkat pada boilerplate auth).**
   Setelah mock diganti Firebase Auth, login berhasil tetapi UI menampilkan "Gagal memperoleh token dari Firebase Auth". Penyebab: dokumentasi `firebase_auth` menyatakan `User.refreshToken` **kosong di native (Android/iOS)** karena SDK mengelola refresh token internal. Perbaikan: `access` = ID token (`getIdToken() ?? getIdToken(true)`), `refresh` = uid sebagai penanda sesi, dan `refresh()` memakai `getIdToken(true)`.

8. **Keamanan (keputusan final).**
   - Token FCM hanya ditampilkan terpotong (`dE0wJWTKR4e4...`)
   - Tidak ada token/secret yang di-hardcode di Dart.
