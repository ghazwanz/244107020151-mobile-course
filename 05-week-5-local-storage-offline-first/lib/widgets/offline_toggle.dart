import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sync.dart';

/// Toggle simulasi offline yang dipakai bersama halaman catatan dan posts.
class OfflineToggle extends ConsumerWidget {
  const OfflineToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forceOffline = ref.watch(forceOfflineProvider);
    return SwitchListTile(
      value: forceOffline,
      onChanged: (_) => ref.read(forceOfflineProvider.notifier).toggle(),
      secondary: const Icon(Icons.wifi_off),
      title: const Text('Simulasi offline'),
      subtitle: const Text('Hentikan refresh jaringan untuk demo'),
    );
  }
}
