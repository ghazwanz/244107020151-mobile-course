import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../utils/date_format.dart';

/// Halaman detail catatan pada rute `/note/:id`.
/// Membaca data langsung dari repository lokal (bukan state halaman list).
class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(noteId));

    return Scaffold(
      appBar: AppBar(title: Text('Detail Catatan #$noteId')),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat catatan: $err',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return _NoteDetail(note: note);
        },
      ),
    );
  }
}

class _NoteDetail extends StatelessWidget {
  const _NoteDetail({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(child: Text(note.id?.toString() ?? '-')),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                note.title,
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (note.dirty)
          Chip(
            avatar: const Icon(Icons.cloud_upload_outlined, size: 18),
            label: const Text('Belum tersinkron'),
            backgroundColor: theme.colorScheme.tertiaryContainer,
          )
        else
          const Chip(
            avatar: Icon(Icons.cloud_done_outlined, size: 18),
            label: Text('Tersinkron'),
          ),
        const SizedBox(height: 16),
        Text(
          note.body.isEmpty ? '(tanpa isi)' : note.body,
          style: theme.textTheme.bodyLarge,
        ),
        const Divider(height: 32),
        Text(
          'Diperbarui: ${formatDateTime(note.updatedAt)}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
