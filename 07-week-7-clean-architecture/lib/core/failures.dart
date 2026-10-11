/// Failure domain — murni Dart, tanpa dependensi framework apa pun.
///
/// Semua exception mentah dari data layer dikonversi menjadi `Failure`
/// sebelum mencapai presentation, sehingga UI hanya menerima pesan yang
/// ramah pengguna.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// Kegagalan pada sumber data lokal (SQLite, SharedPreferences, cache).
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Kegagalan pada sumber data jaringan (Dio, HTTP).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
