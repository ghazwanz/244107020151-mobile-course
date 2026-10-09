import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'data/prefs.dart';
import 'pages/note_detail_page.dart';
import 'pages/notes_page.dart';
import 'pages/posts_page.dart';
import 'pages/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Catat waktu terakhir dibuka ke SharedPreferences sebelum aplikasi tampil.
  await PrefsRepository().markOpenedNow();
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.note_alt_outlined),
                selectedIcon: Icon(Icons.note_alt),
                label: 'Catatan',
              ),
              NavigationDestination(
                icon: Icon(Icons.cloud_outlined),
                selectedIcon: Icon(Icons.cloud),
                label: 'Posts Cache',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Pengaturan',
              ),
            ],
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const NotesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/posts',
              builder: (context, state) => const PostsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return NoteDetailPage(noteId: id);
      },
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp.router(
      title: 'Week 5 - Offline Notes',
      routerConfig: _router,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
