import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Use case contoh dari modul: satu operasi baca daftar catatan.
///
/// Operasi baca daftar dipertahankan sebagai use case (bukan passthrough
/// tanpa alasan) karena menjadi seam murni yang diuji di
/// `test/get_notes_test.dart`, sekaligus tempat aturan query tumbuh
/// (filter/sort) tanpa mengubah notifier.
class GetNotes {
  const GetNotes(this._repository);

  final NoteRepository _repository;

  Future<({List<Note> notes, Failure? failure})> call() {
    return _repository.fetchNotes();
  }
}
