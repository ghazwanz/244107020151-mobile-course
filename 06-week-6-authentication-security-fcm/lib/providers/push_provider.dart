import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Token FCM perangkat saat ini (dipakai halaman debug, ditampilkan terpotong).
class FcmTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? token) => state = token;
}

final fcmTokenProvider =
    NotifierProvider<FcmTokenNotifier, String?>(FcmTokenNotifier.new);

/// Menyensor token agar aman ditampilkan: 12 karakter pertama + `...`.
String maskToken(String? token) {
  if (token == null || token.isEmpty) return '(belum tersedia)';
  if (token.length <= 12) return token;
  return '${token.substring(0, 12)}...';
}

/// Status langganan topik broadcast kampus.
///
/// Awalnya `true` karena aplikasi berlangganan topik saat startup
/// (`initFcmToken`). Pengguna dapat berhenti/berlangganan kembali dari Home.
class TopicSubscriptionNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void set(bool value) => state = value;
}

final topicSubscribedProvider =
    NotifierProvider<TopicSubscriptionNotifier, bool>(
  TopicSubscriptionNotifier.new,
);
