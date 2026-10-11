import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

final tokenStoreProvider = Provider((ref) => TokenStore());
final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    // Akhiri sesi di Firebase Auth, lalu bersihkan token lokal.
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Diabaikan: yang terpenting token lokal dibersihkan.
    }
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}
