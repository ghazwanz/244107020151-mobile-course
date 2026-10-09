import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs.dart';
import '../utils/date_format.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());
final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

/// Waktu terakhir aplikasi dibuka, dibaca dari SharedPreferences.
final lastOpenedProvider = FutureProvider<String?>(
  (ref) => ref.watch(prefsRepositoryProvider).getLastOpened(),
);

/// Halaman pengaturan: toggle tema gelap/terang dan info waktu terakhir dibuka.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Tema Gelap'),
            subtitle: const Text('Preferensi disimpan di SharedPreferences'),
            value: darkModeAsync.value ?? false,
            onChanged: darkModeAsync.isLoading
                ? null
                : (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Terakhir Dibuka'),
            subtitle: Text(
              lastOpenedAsync.when(
                loading: () => 'Memuat...',
                error: (err, _) => 'Gagal memuat: $err',
                data: (value) {
                  if (value == null) return 'Belum tercatat';
                  final parsed = DateTime.tryParse(value);
                  return parsed == null ? value : formatDateTime(parsed);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
