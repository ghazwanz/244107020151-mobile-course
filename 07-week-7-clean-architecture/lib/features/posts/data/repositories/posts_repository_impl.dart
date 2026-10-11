import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../models/post_model.dart';

/// Implementasi [PostsRepository]: cache lokal (SQLite) + jaringan (Dio).
class PostsRepositoryImpl implements PostsRepository {
  PostsRepositoryImpl({
    required this.dio,
    required this.openDb,
  });

  final Dio dio;
  final Future<Database> Function() openDb;

  @override
  Future<({List<Post> posts, Failure? failure})> readCache() async {
    try {
      final db = await openDb();
      final rows = await db.query('cached_posts', orderBy: 'cached_at DESC');
      final posts = rows.map((row) {
        final payload = row['payload'] as String? ?? '{}';
        return PostModel.fromJson(
          jsonDecode(payload) as Map<String, dynamic>,
        ).toEntity();
      }).toList();
      return (posts: posts, failure: null);
    } catch (e) {
      return (
        posts: const <Post>[],
        failure: LocalFailure('Gagal membaca cache posts: $e'),
      );
    }
  }

  @override
  Future<({List<Post> posts, Failure? failure})> fetchFromNetwork() async {
    try {
      final response = await dio.get<List>('/posts');
      final data = response.data ?? [];
      final posts = data
          .whereType<Map<String, dynamic>>()
          .map((json) => PostModel.fromJson(json).toEntity())
          .toList();
      await _saveCache(posts);
      return (posts: posts, failure: null);
    } on DioException catch (e) {
      return (
        posts: const <Post>[],
        failure: NetworkFailure('Gagal memuat dari jaringan: ${e.message}'),
      );
    } catch (e) {
      return (
        posts: const <Post>[],
        failure: NetworkFailure('Gagal memuat dari jaringan: $e'),
      );
    }
  }

  /// Upsert hasil fetch ke tabel `cached_posts` untuk kunjungan berikutnya.
  Future<void> _saveCache(List<Post> posts) async {
    final db = await openDb();
    final batch = db.batch();
    for (final post in posts) {
      batch.insert(
        'cached_posts',
        {
          'id': post.id,
          'payload': jsonEncode(PostModel(
            userId: post.userId,
            id: post.id,
            title: post.title,
            body: post.body,
          ).toJson()),
          'cached_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
