import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../providers/settings_providers.dart';

/// Halaman pengaturan: toggle tema gelap/terang dan info waktu terakhir dibuka.
/// Formatting tanggal dilakukan oleh fungsi murni di `core/format.dart`.
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
                  final parsed = parseStoredDateTime(value);
                  if (parsed == null) {
                    return value ?? 'Belum tercatat';
                  }
                  return formatDateTime(parsed);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
