import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sync.dart';
import '../widgets/offline_toggle.dart';

/// Halaman posts cache-first: menampilkan cache lokal seketika, lalu refresh
/// dari jaringan di background. Saat offline, cache lama tetap tampil.
class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsCacheProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Cache'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh dari jaringan',
            onPressed: () => ref
                .read(postsCacheProvider.notifier)
                .refreshPostsInBackground(),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineToggle(),
          Expanded(
            child: postsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Gagal memuat: $err', textAlign: TextAlign.center),
                ),
              ),
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Belum ada cache. Matikan simulasi offline lalu tekan refresh.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(post.id.toString())),
                      title: Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
