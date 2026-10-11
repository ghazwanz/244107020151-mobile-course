import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/app_database.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';

// ---------------------------------------------------------------------------
// Dependency Injection (satu-satunya tempat abstraksi diikat ke implementasi)
// ---------------------------------------------------------------------------

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openAppDb);
});

final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final syncNotesProvider = Provider<SyncNotes>((ref) {
  return SyncNotes(ref.watch(noteRepositoryProvider));
});

// ---------------------------------------------------------------------------
// State untuk UI
// ---------------------------------------------------------------------------

/// Notifier daftar catatan dengan siklus AsyncValue (loading/error/data).
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.notes;
  }

  /// CRUD satu-baris: sengaja lewat repository langsung (bukan use case)
  /// sesuai panduan modul agar tidak over-engineering.
  Future<void> addNote({required String title, String body = ''}) async {
    final result =
        await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteNote(int id) async {
    final failure = await ref.read(noteRepositoryProvider).deleteNote(id);
    if (failure != null) {
      throw Exception(failure.message);
    }
    ref.invalidateSelf();
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

/// Provider detail catatan berdasarkan id.
final noteByIdProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final result = await ref.watch(noteRepositoryProvider).fetchNoteById(id);
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.note;
});
