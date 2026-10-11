import '../../../../core/failures.dart';
import '../entities/post.dart';

/// Kontrak sumber data post untuk pola cache-first.
abstract class PostsRepository {
  /// Membaca cache lokal (tabel `cached_posts`) seketika.
  Future<({List<Post> posts, Failure? failure})> readCache();

  /// Mengambil dari jaringan lalu menyimpannya ke cache.
  Future<({List<Post> posts, Failure? failure})> fetchFromNetwork();
}
