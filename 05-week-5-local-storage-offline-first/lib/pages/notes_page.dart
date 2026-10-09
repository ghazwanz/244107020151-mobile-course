import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import '../widgets/note_tile.dart';
import '../widgets/offline_toggle.dart';

/// Halaman catatan offline: CRUD lokal + badge jumlah catatan belum tersinkron.
/// Tetap berfungsi penuh dalam mode pesawat karena bersumber dari SQLite lokal.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sinkronkan catatan',
            onPressed: () => _sync(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineToggle(),
          Expanded(
            child: notesAsync.when(
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
              data: (notes) {
                if (notes.isEmpty) {
                  return const Center(
                    child: Text('Belum ada catatan. Tekan + untuk menambah.'),
                  );
                }
                final dirtyCount = notes.where((n) => n.dirty).length;
                return Column(
                  children: [
                    if (dirtyCount > 0) _DirtyBanner(count: dirtyCount),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => ref.invalidate(notesProvider),
                        child: ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return NoteTile(
                              note: note,
                              onTap: note.id == null
                                  ? null
                                  : () => context.push('/note/${note.id}'),
                              onDelete: note.id == null
                                  ? null
                                  : () => _confirmDelete(context, ref, note),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final count = await syncNotes(ref.read(noteRepositoryProvider));
    ref.invalidate(notesProvider);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          count == 0
              ? 'Semua catatan sudah tersinkron.'
              : '$count catatan berhasil disinkronkan.',
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final draft = await showDialog<({String title, String body})>(
      context: context,
      builder: (_) => const _AddNoteDialog(),
    );
    if (draft == null) return;
    await ref
        .read(notesProvider.notifier)
        .addNote(title: draft.title, body: draft.body);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text('Hapus "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && note.id != null) {
      await ref.read(notesProvider.notifier).deleteNote(note.id!);
    }
  }
}

/// Dialog tambah catatan yang memiliki sendiri TextEditingController-nya,
/// sehingga controller baru dibuang setelah dialog benar-benar dilepas.
class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(
      context,
      (title: title, body: _bodyController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Catatan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Judul'),
          ),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(labelText: 'Isi'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

/// Banner jumlah catatan yang belum tersinkron (dirty).
class _DirtyBanner extends StatelessWidget {
  const _DirtyBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.cloud_upload_outlined,
              size: 18, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count catatan belum tersinkron.',
              style: TextStyle(color: scheme.onTertiaryContainer, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

