/// Konstanta rute murni (tanpa import Flutter) agar bisa dipakai bersama
/// oleh presentation tanpa membuat import cycle dengan konfigurasi router.
///
/// Konfigurasi `GoRouter` itu sendiri tinggal di `lib/routes.dart`.
abstract final class Routes {
  static const String notes = '/';
  static const String posts = '/posts';
  static const String settings = '/settings';
  static const String noteDetailPattern = '/note/:id';

  /// Path detail catatan untuk sebuah `id`.
  static String noteDetail(int id) => '/note/$id';
}
