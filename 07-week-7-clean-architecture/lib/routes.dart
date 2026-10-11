import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/format.dart';
import 'core/routes.dart';
import 'features/notes/presentation/pages/note_detail_page.dart';
import 'features/notes/presentation/pages/notes_page.dart';
import 'features/posts/presentation/pages/posts_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

/// Konfigurasi navigasi aplikasi (GoRouter).
///
/// Konstanta rute murni tinggal di `lib/core/routes.dart` agar halaman dapat
/// memakainya tanpa membuat import cycle dengan file ini.
final appRouter = GoRouter(
  initialLocation: Routes.notes,
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
              path: Routes.notes,
              builder: (context, state) => const NotesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.posts,
              builder: (context, state) => const PostsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.noteDetailPattern,
      builder: (context, state) => NoteDetailPage(
        noteId: parseNoteId(state.pathParameters['id']),
      ),
    ),
  ],
);
