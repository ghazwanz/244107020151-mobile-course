import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/prefs_repository_impl.dart';
import '../../domain/repositories/prefs_repository.dart';

// ---------------------------------------------------------------------------
// Dependency Injection
// ---------------------------------------------------------------------------

final prefsRepositoryProvider = Provider<PrefsRepository>((ref) {
  return PrefsRepositoryImpl();
});

// ---------------------------------------------------------------------------
// State untuk UI
// ---------------------------------------------------------------------------

/// Notifier tema gelap yang membaca/menyimpan preferensi secara asinkron.
class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

/// Waktu terakhir aplikasi dibuka, dibaca dari SharedPreferences.
final lastOpenedProvider = FutureProvider<String?>(
  (ref) => ref.watch(prefsRepositoryProvider).getLastOpened(),
);
