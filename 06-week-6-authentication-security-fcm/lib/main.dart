import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'data/api_client.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/push_provider.dart';
import 'routes.dart';

final container = ProviderContainer();

/// Memberi tahu GoRouter untuk mengevaluasi ulang `redirect`
/// setiap kali status autentikasi berubah.
class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier() {
    container.listen(authStateProvider, (_, _) => notifyListeners());
  }
}

final _routerNotifier = _AuthRouterNotifier();

final _router = GoRouter(
  initialLocation: Routes.home,
  refreshListenable: _routerNotifier,
  redirect: (context, state) {
    final loggedIn = container.read(authStateProvider).value ?? false;
    final goingLogin = state.matchedLocation == Routes.login;
    if (!loggedIn && !goingLogin) return Routes.login;
    if (loggedIn && goingLogin) return Routes.home;
    return null;
  },
  routes: [
    GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
    GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
    GoRoute(
      path: Routes.announcementPattern,
      builder: (_, s) => AnnouncementPage(id: s.pathParameters['id'] ?? ''),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Handler background harus terdaftar sebelum aplikasi berjalan.
  registerBackgroundHandler();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
  await _initPush();
}

/// Inisialisasi FCM: izin, local notification, token, dan handler navigasi.
Future<void> _initPush() async {
  // Handler navigasi didaftarkan LEBIH DULU, sebelum tugas berat
  // (getToken + jaringan). Jika tidak, deep link dari notifikasi yang
  // membuka aplikasi bisa hilang saat cold start.
  await handleTerminated((route) => _router.go(route));
  listenForeground((route) => _router.go(route));
  await initLocalNotifications(
    onSelect: (route) => _router.go(route),
  );
  await requestNotificationPermission();

  await initFcmToken(onToken: (token) async {
    container.read(fcmTokenProvider.notifier).set(token);
    debugPrint('[FCM] token dikirim ke backend: ${maskToken(token)}');
    // Kirim token ke backend. Endpoint didokumentasikan: POST /devices.
    // Backend contoh belum tersedia, jadi kegagalan diabaikan.
    try {
      final dio = buildApiClient(
        container.read(tokenStoreProvider),
        container.read(authRepositoryProvider),
      );
      await dio.post(
        '/devices',
        data: {'fcm_token': token, 'platform': 'android'},
      );
    } catch (_) {
      // Diabaikan: token tetap ditampilkan (terpotong) di halaman debug.
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      routerConfig: _router,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
    );
  }
}
