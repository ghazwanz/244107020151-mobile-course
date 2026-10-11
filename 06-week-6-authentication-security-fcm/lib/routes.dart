/// Satu sumber kebenaran untuk string rute.
///
/// Dipakai bersama oleh GoRouter (definisi route) dan PushService
/// (deep link dari notifikasi FCM), sehingga tidak ada string rute
/// yang tersebar dan rawan salah ketik.
class Routes {
  const Routes._();

  static const login = '/login';
  static const home = '/';
  static const announcementPattern = '/pengumuman/:id';

  /// Membangun rute detail pengumuman dari sebuah id.
  static String announcement(String id) => '/pengumuman/$id';
}

/// Mengekstrak rute tujuan dari `data` payload FCM.
///
/// Fungsi murni (tanpa dependensi Firebase) agar bisa diunit-test:
/// - `data` kosong -> [Routes.home]
/// - rute tanpa garis miring depan -> ditambahkan
/// - rute dengan garis miring depan -> dibiarkan
String routeFromMessage(Map<String, dynamic> data) {
  final route = (data['route'] as String?) ?? Routes.home;
  if (route.isEmpty) return Routes.home;
  return route.startsWith('/') ? route : '/$route';
}
