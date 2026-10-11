import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

final _local = FlutterLocalNotificationsPlugin();

/// Topik broadcast pengumuman kampus (semua mahasiswa).
const kCampusTopic = 'pengumuman-kampus';

/// ID & nama channel notifikasi Android.
///
/// Dipakai untuk banner foreground (local notification) DAN diset sebagai
/// channel default FCM di AndroidManifest, sehingga tampilan banner
/// konsisten di state foreground, background, dan terminated.
const kChannelId = 'pengumuman';
const kChannelName = 'Pengumuman Kampus';

/// Route yang menunggu diproses (dari klik banner lokal saat foreground).
String? pendingDeepLink;

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications({
  void Function(String route)? onSelect,
}) async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      // Klik banner foreground -> teruskan payload ke router.
      final route = response.payload;
      if (route == null) return;
      if (onSelect != null) {
        // Aplikasi sedang berjalan: navigasi langsung.
        onSelect(route);
      } else {
        pendingDeepLink = route;
      }
    },
  );

  // Buat channel eksplisit (Android 8+). Tanpa ini, FCM memakai channel
  // fallback bawaan di background/terminated sehingga banner berbeda
  // dengan foreground.
  await _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          kChannelId,
          kChannelName,
          description: 'Notifikasi pengumuman kampus.',
          importance: Importance.high,
        ),
      );
}

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  // 1. Ambil token saat ini dan kirim ke backend.
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);

  // 2. Token bisa berubah (reinstall, clear data, rotasi keamanan).
  //    Listener ini WAJIB ada, jika tidak backend menyimpan token basi.
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);

  // 3. Langganan topik kampus (mis. semua mahasiswa angkatan).
  await subscribeCampusTopic();
}

/// Berlangganan topik broadcast pengumuman kampus.
Future<void> subscribeCampusTopic() =>
    FirebaseMessaging.instance.subscribeToTopic(kCampusTopic);

/// Berhenti berlangganan topik broadcast pengumuman kampus.
///
/// Dipakai saat pengguna mematikan notifikasi pengumuman; perangkat tidak
/// lagi menerima pesan yang dikirim ke topik ini.
Future<void> unsubscribeCampusTopic() =>
    FirebaseMessaging.instance.unsubscribeFromTopic(kCampusTopic);

/// Memaksa pembuatan token baru (debug).
///
/// Menghapus token lama lalu meminta token baru. Berguna untuk membuktikan
/// bahwa `onTokenRefresh` mengirim token terbaru ke backend.
Future<String?> forceTokenRefresh() async {
  await FirebaseMessaging.instance.deleteToken();
  return FirebaseMessaging.instance.getToken();
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Jangan akses BuildContext / Riverpod di sini.
  // Tugasnya: catat / simpan ringan saja. Navigasi dilakukan saat klik.
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

void listenForeground(void Function(String route) go) {
  // Foreground: sistem TIDAK menampilkan banner otomatis,
  // jadi tampilkan manual via local notification.
  FirebaseMessaging.onMessage.listen((message) async {
    debugPrint(
      '[FCM] onMessage id=${message.messageId} '
      'hasNotification=${message.notification != null} data=${message.data}',
    );
    final route = routeFromMessage(message.data);
    const androidDetails = AndroidNotificationDetails(
      kChannelId,
      kChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  // Background -> diklik.
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    debugPrint('[FCM] onMessageOpenedApp route=${routeFromMessage(message.data)}');
    go(routeFromMessage(message.data));
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  // Terminated -> dibuka dari notifikasi.
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  debugPrint(
    '[FCM] getInitialMessage id=${initial?.messageId} '
    'route=${initial == null ? null : routeFromMessage(initial.data)}',
  );
  if (initial != null) go(routeFromMessage(initial.data));
  if (pendingDeepLink != null) go(pendingDeepLink!);
}
