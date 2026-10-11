/// Entity catatan — objek bisnis murni.
///
/// Tanpa `toMap`/`fromMap`/`toJson` dan tanpa import Flutter/Dio/SQLite.
/// Mapping ke format luar hanya boleh terjadi di `NoteModel` (data layer).
class Note {
  const Note({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;
}
