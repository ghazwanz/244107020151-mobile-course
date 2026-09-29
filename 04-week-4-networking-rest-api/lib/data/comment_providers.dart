import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Notifier untuk mengelola state komentar secara asinkron dengan AsyncNotifierProvider.
/// Exception dari repository otomatis ditangkap dan dibungkus menjadi AsyncError.
class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() async {
    return [];
  }

  Future<void> loadComments(int postId) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final commentsProvider =
    AsyncNotifierProvider<CommentsNotifier, List<Comment>>(
  CommentsNotifier.new,
  retry: (retryCount, error) => null,
);

/// Provider berbasis family untuk memuat komentar berdasarkan postId secara modular.
final commentsFamilyProvider =
    FutureProvider.family<List<Comment>, int>((ref, postId) {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});
