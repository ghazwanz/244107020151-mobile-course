import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository untuk mengakses endpoint komentar pada REST API JSONPlaceholder.
/// UI tidak boleh memanggil Dio secara langsung; repository adalah satu-satunya gerbang data.
class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  /// Mengambil daftar komentar untuk post tertentu berdasarkan postId.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
