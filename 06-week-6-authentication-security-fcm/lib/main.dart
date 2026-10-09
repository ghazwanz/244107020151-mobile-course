import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

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
  initialLocation: '/',
  refreshListenable: _routerNotifier,
  redirect: (context, state) {
    final loggedIn = container.read(authStateProvider).value ?? false;
    final goingLogin = state.matchedLocation == '/login';
    if (!loggedIn && !goingLogin) return '/login';
    if (loggedIn && goingLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
    GoRoute(path: '/', builder: (_, _) => const HomePage()),
    GoRoute(
      path: '/pengumuman/:id',
      builder: (_, s) => AnnouncementPage(id: s.pathParameters['id'] ?? ''),
    ),
  ],
);

void main() {
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
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
