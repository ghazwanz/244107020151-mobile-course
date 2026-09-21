import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_provider.dart';

/// Notifier asinkron untuk mengelola data statistik tugas dengan AsyncValue
class StatsNotifier extends AsyncNotifier<List<String>> {
  /// Flag kontrol simulasi kegagalan (dapat dinonaktifkan saat unit testing)
  static bool enableFailureSimulation = true;

  /// Penanda apakah ini pemuatan awal / refresh
  bool _isInitial = true;

  @override
  Future<List<String>> build() async {
    // Mengamati daftar tugas dari todoListProvider secara reaktif
    final todos = ref.watch(todoListProvider);

    // Simulasi delay network 2 detik dan kegagalan hanya pada pemuatan pertama / refresh
    if (_isInitial) {
      _isInitial = false;
      await Future.delayed(const Duration(seconds: 2));

      // Simulasi kemungkinan gagal 30% jika simulasi aktif
      if (enableFailureSimulation && Random().nextDouble() < 0.3) {
        throw Exception('Koneksi ke server statistik terputus.');
      }
    }

    // Jika daftar tugas kosong, kembalikan daftar kosong tanpa dummy data
    if (todos.isEmpty) {
      return const [];
    }

    final total = todos.length;
    final completed = todos.where((t) => t.done).length;
    final uncompleted = total - completed;

    // Mengembalikan 3 item data statistik riil berdasarkan todoListProvider
    return [
      'Total Tugas: $total Item',
      'Tugas Selesai: $completed Item',
      'Tugas Belum Selesai: $uncompleted Item',
    ];
  }

  /// Memuat ulang data statistik dengan penanganan AsyncValue.guard
  Future<void> refresh() async {
    _isInitial = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider global untuk mengakses state statistik
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
  retry: (_, _) => null,
);
