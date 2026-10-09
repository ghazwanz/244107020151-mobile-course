import 'package:flutter/material.dart';
import '../data/local/note.dart';

/// Baris catatan yang dapat dipakai ulang, menampilkan badge "belum tersinkron"
/// bila `note.dirty == true`.
class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
  });

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(note.id?.toString() ?? '-')),
      title: Text(
        note.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        note.body.isEmpty ? '(tanpa isi)' : note.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.dirty) const _DirtyBadge(),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus',
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

/// Badge kecil penanda catatan belum tersinkron.
class _DirtyBadge extends StatelessWidget {
  const _DirtyBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'belum tersinkron',
        style: TextStyle(
          fontSize: 10,
          color: scheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
