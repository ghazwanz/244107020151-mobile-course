import '../../../../core/failures.dart';
import '../entities/note.dart';

/// Kontrak yang dibutuhkan domain untuk mengelola catatan.
///
/// Interface tinggal di domain; implementasi (SQLite) ada di data layer.
/// Mengembalikan record `({data, failure})` agar sukses/gagal eksplisit
/// tanpa exception bocor ke presentation.
abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();

  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body,
  });

  Future<({Note? note, Failure? failure})> fetchNoteById(int id);

  Future<Failure?> deleteNote(int id);

  Future<({int count, Failure? failure})> countDirty();

  Future<Failure?> markAllSynced();
}
