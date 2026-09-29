import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment_providers.dart';
import '../data/models/post.dart';
import '../data/providers.dart';

/// Halaman detail post yang menampilkan title dan body lengkap,
/// serta daftar komentar yang dimuat melalui CommentRepository (AI Challenge).
class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({
    super.key,
    required this.postId,
    this.initialPost,
  });

  final int postId;
  final Post? initialPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialPost != null) {
      return _buildScaffold(context, ref, initialPost!);
    }

    final postAsync = ref.watch(singlePostProvider(postId));
    return postAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text('Post #$postId')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: Text('Post #$postId')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  friendlyErrorMessage(err),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(singlePostProvider(postId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (post) => _buildScaffold(context, ref, post),
    );
  }

  Widget _buildScaffold(BuildContext context, WidgetRef ref, Post post) {
    final commentsAsync = ref.watch(commentsFamilyProvider(post.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Post #${post.id}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu detail post
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(post.id.toString()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          post.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    post.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header Komentar
          Row(
            children: [
              const Icon(Icons.comment_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Komentar (AI Challenge)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Daftar komentar dari CommentRepository
          commentsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(friendlyErrorMessage(err), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(commentsFamilyProvider(post.id)),
                    child: const Text('Muat ulang komentar'),
                  ),
                ],
              ),
            ),
            data: (comments) {
              if (comments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Belum ada komentar.')),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Text(comment.name.isNotEmpty ? comment.name[0].toUpperCase() : '?'),
                    ),
                    title: Text(
                      comment.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.email,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(comment.body, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
