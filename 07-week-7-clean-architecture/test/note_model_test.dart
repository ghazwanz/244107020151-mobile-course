import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_architecture/features/notes/data/models/note_model.dart';

void main() {
  test('fromMap aman terhadap field yang hilang', () {
    final model = NoteModel.fromMap({'title': 'Belanja'});
    expect(model.title, 'Belanja');
    expect(model.body, '');
    expect(model.dirty, isFalse);
  });

  test('flag dirty bertahan pada serialisasi', () {
    final model = NoteModel(
      title: 'a',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );
    final restored = NoteModel.fromMap(model.toMap());
    expect(restored.dirty, isTrue);
  });

  test('toEntity menghasilkan entity murni dengan nilai sama', () {
    final model = NoteModel(
      id: 7,
      title: 'x',
      body: 'y',
      updatedAt: DateTime(2026, 1, 1),
      dirty: true,
    );
    final entity = model.toEntity();
    expect(entity.id, 7);
    expect(entity.title, 'x');
    expect(entity.body, 'y');
    expect(entity.dirty, isTrue);
  });
}
