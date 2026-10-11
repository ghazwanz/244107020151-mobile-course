import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

/// Use case sinkronisasi catatan.
///
/// Ini contoh kapan use case **memang** dibutuhkan: operasi menggabungkan
/// lebih dari satu langkah repository (hitung `dirty` → kirim ke server →
/// tandai tersinkron) dan memiliki aturan bisnis. Berbeda dengan CRUD
/// satu-baris (`addNote`/`deleteNote`) yang cukup dipanggil langsung dari
/// notifier.
class SyncNotes {
  const SyncNotes(
    this._repository, {
    this.uploadDelay = const Duration(seconds: 1),
  });

  final NoteRepository _repository;

  /// Delay simulasi upload; dibuat bisa disetel agar test berjalan instan.
  final Duration uploadDelay;

  Future<({int synced, Failure? failure})> call() async {
    final countResult = await _repository.countDirty();
    if (countResult.failure != null) {
      return (synced: 0, failure: countResult.failure);
    }

    final dirty = countResult.count;
    if (dirty == 0) {
      return (synced: 0, failure: null);
    }

    // Simulasi upload ke REST API. Pada project nyata, kirim tiap catatan
    // `dirty` ke server di sini, lalu tandai bersih bila server menjawab 2xx.
    await Future<void>.delayed(uploadDelay);

    final markFailure = await _repository.markAllSynced();
    if (markFailure != null) {
      return (synced: 0, failure: markFailure);
    }
    return (synced: dirty, failure: null);
  }
}
