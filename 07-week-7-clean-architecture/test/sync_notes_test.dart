import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_architecture/core/failures.dart';
import 'package:week7_clean_architecture/features/notes/domain/entities/note.dart';
import 'package:week7_clean_architecture/features/notes/domain/repositories/note_repository.dart';
import 'package:week7_clean_architecture/features/notes/domain/usecases/sync_notes.dart';

/// Repository palsu yang mencatat pemanggilan `markAllSynced`.
class FakeSyncRepository implements NoteRepository {
  FakeSyncRepository({required this.dirty, this.failMark = false});

  final int dirty;
  final bool failMark;
  int markCalls = 0;

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    return (count: dirty, failure: null);
  }

  @override
  Future<Failure?> markAllSynced() async {
    markCalls++;
    return failMark ? const LocalFailure('gagal menandai (simulasi)') : null;
  }

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() {
    throw UnimplementedError();
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<({Note? note, Failure? failure})> fetchNoteById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Failure?> deleteNote(int id) {
    throw UnimplementedError();
  }
}

void main() {
  test('SyncNotes mengirim lalu menandai jumlah catatan dirty', () async {
    final repo = FakeSyncRepository(dirty: 3);
    final result =
        await SyncNotes(repo, uploadDelay: Duration.zero).call();
    expect(result.failure, isNull);
    expect(result.synced, 3);
    expect(repo.markCalls, 1);
  });

  test('SyncNotes tidak menyentuh server saat tidak ada dirty', () async {
    final repo = FakeSyncRepository(dirty: 0);
    final result =
        await SyncNotes(repo, uploadDelay: Duration.zero).call();
    expect(result.failure, isNull);
    expect(result.synced, 0);
    expect(repo.markCalls, 0);
  });

  test('SyncNotes meneruskan failure tanpa melempar', () async {
    final repo = FakeSyncRepository(dirty: 2, failMark: true);
    final result =
        await SyncNotes(repo, uploadDelay: Duration.zero).call();
    expect(result.failure, isA<LocalFailure>());
    expect(result.synced, 0);
  });
}
