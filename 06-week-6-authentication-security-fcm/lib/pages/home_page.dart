import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../providers/push_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(fcmTokenProvider);
    final subscribed = ref.watch(topicSubscribedProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: const Text('Pengumuman #3'),
              subtitle: const Text('Buka contoh deep link /pengumuman/3'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.announcement('3')),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Token FCM (debug)'),
              subtitle: Text('${maskToken(token)}\nTopik: $kCampusTopic'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Paksa refresh token (debug)',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final newToken = await forceTokenRefresh();
                  ref.read(fcmTokenProvider.notifier).set(newToken);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Token diminta ulang (debug).')),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.group_outlined),
              title: Text('Langganan topik $kCampusTopic'),
              subtitle: Text(
                subscribed
                    ? 'Aktif — menerima broadcast topik'
                    : 'Nonaktif — tidak menerima broadcast topik',
              ),
              value: subscribed,
              onChanged: (value) async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  if (value) {
                    await subscribeCampusTopic();
                  } else {
                    await unsubscribeCampusTopic();
                  }
                  ref.read(topicSubscribedProvider.notifier).set(value);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Berlangganan topik $kCampusTopic'
                            : 'Berhenti berlangganan topik $kCampusTopic',
                      ),
                    ),
                  );
                } catch (error) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Gagal mengubah langganan: $error')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
