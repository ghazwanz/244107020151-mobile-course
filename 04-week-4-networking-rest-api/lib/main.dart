import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_list_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

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
                icon: Icon(Icons.list_alt),
                selectedIcon: Icon(Icons.list_alt),
                label: 'Semua Posts',
              ),
              NavigationDestination(
                icon: Icon(Icons.all_inclusive),
                selectedIcon: Icon(Icons.all_inclusive),
                label: 'Infinite Scroll',
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
              builder: (context, state) => const PostListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/paged',
              builder: (context, state) => const PagedPostPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Week 4 - REST API',
      routerConfig: _router,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
    );
  }
}
