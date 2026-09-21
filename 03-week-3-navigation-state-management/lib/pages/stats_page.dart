import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/stats_provider.dart';

/// Halaman statistik yang menampilkan state asinkron menggunakan AsyncValue
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau perubahan state dari statsProvider secara reaktif
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
      // Menangani tiga kemungkinan state AsyncValue: loading, error, dan success
      body: statsAsync.when(
        // 1. State Loading: Menampilkan indikator pemuatan melingkar
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        // 2. State Error: Menampilkan pesan kesalahan dan tombol coba lagi
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat: $err'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        // 3. State Data (Success): Menampilkan daftar metrik atau teks kosong jika belum ada tugas
        data: (stats) => stats.isEmpty
            ? const Center(
                child: Text('Belum ada data statistik'),
              )
            : ListView.builder(
                itemCount: stats.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: Text(stats[index]),
                ),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'Tugas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}
