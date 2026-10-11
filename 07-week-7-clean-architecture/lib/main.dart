import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/settings/presentation/providers/settings_providers.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Catat waktu terakhir dibuka lewat provider (tanpa instansiasi manual
  // repository di `main`), lalu pakai container yang sama untuk aplikasi.
  final container = ProviderContainer();
  await container.read(prefsRepositoryProvider).markOpenedNow();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp.router(
      title: 'Week 7 - Clean Architecture',
      routerConfig: appRouter,
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
