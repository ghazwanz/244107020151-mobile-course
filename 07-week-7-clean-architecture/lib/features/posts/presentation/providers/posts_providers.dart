import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/app_database.dart';
import '../../../../shared/providers/offline_provider.dart';
import '../../data/api_client.dart';
import '../../data/repositories/posts_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';

// ---------------------------------------------------------------------------
// Dependency Injection
// ---------------------------------------------------------------------------

final dioProvider = Provider<Dio>((ref) => createDio());

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepositoryImpl(
    dio: ref.watch(dioProvider),
    openDb: openAppDb,
  );
});

// ---------------------------------------------------------------------------
// State untuk UI
// ---------------------------------------------------------------------------

/// Notifier cache-first: tampilkan cache lokal seketika, lalu refresh dari
/// jaringan di background. Saat offline/gagal, cache lama tetap tampil.
class PostsCacheNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() => _loadCacheFirst();

  Future<List<Post>> _loadCacheFirst() async {
    final result = await ref.read(postsRepositoryProvider).readCache();
    // Refresh di background tanpa menunggu, agar UI tidak blank saat offline.
    refreshPostsInBackground();
    return result.posts;
  }

  Future<void> refreshPostsInBackground() async {
    if (ref.read(forceOfflineProvider)) return;
    final result = await ref.read(postsRepositoryProvider).fetchFromNetwork();
    if (result.failure == null) {
      state = AsyncData(result.posts);
    }
  }
}

final postsCacheProvider =
    AsyncNotifierProvider<PostsCacheNotifier, List<Post>>(
  PostsCacheNotifier.new,
  retry: (retryCount, error) => null,
);
