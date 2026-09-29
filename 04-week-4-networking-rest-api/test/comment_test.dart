import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  group('Comment Model Serialization Tests', () {
    test('fromJson aman terhadap field yang hilang (missing fields)', () {
      final json = {
        'id': 10,
        'postId': 2,
      };

      final comment = Comment.fromJson(json);

      expect(comment.id, 10);
      expect(comment.postId, 2);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('fromJson menangani nilai null dan tipe tidak sesuai secara defensif (edge case)', () {
      final json = {
        'postId': 15,
        'id': null,
        'name': null,
        'email': null,
        'body': null,
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 15);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('toJson menghasilkan Map yang konsisten dengan objek model', () {
      const comment = Comment(
        postId: 1,
        id: 101,
        name: 'Ghazwan',
        email: 'ghazwan@example.com',
        body: 'Testing comment body',
      );

      final map = comment.toJson();

      expect(map['postId'], 1);
      expect(map['id'], 101);
      expect(map['name'], 'Ghazwan');
      expect(map['email'], 'ghazwan@example.com');
      expect(map['body'], 'Testing comment body');
    });
  });
}
