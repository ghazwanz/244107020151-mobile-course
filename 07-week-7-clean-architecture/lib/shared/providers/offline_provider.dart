import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Toggle simulasi offline lintas fitur (dipakai halaman Catatan & Posts).
///
/// Diletakkan di `shared/` (bukan `core/`) karena bergantung pada Riverpod,
/// sementara `lib/core` sengaja dibiarkan bebas framework agar lolos
/// pemeriksaan sterilitas dependency rule.
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);
