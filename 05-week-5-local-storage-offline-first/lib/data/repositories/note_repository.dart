import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/note.dart';

class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<Note>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  /// Mengambil satu catatan berdasarkan id, dibaca langsung dari database
  /// (bukan dari state halaman list).
  Future<Note?> fetchNoteById(int id) async {
    final db = await _openDb();
    final rows = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Note.fromMap(rows.first);
  }

  Future<int> countDirty() async {
    final db = await _openDb();
    final rows = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1');
    return ((rows.first['c'] as num?)?.toInt() ?? 0);
  }

  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }
}

/// Provider repository catatan. Diletakkan di sini agar test modul
/// (`test/note_test.dart`) dapat mengimpor provider lewat file repository.
final noteRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository());

/// Notifier daftar catatan dengan siklus AsyncValue (loading/error/data).
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() =>
      ref.watch(noteRepositoryProvider).fetchNotes();

  Future<void> addNote({required String title, String body = ''}) async {
    await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidateSelf();
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

/// Provider detail catatan berdasarkan id, membaca langsung dari repository.
final noteByIdProvider = FutureProvider.family<Note?, int>(
  (ref, id) => ref.watch(noteRepositoryProvider).fetchNoteById(id),
);
