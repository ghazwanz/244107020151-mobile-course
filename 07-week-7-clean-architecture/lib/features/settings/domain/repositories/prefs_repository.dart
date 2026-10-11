/// Kontrak penyimpanan preferensi (key-value).
///
/// Hanya berisi operasi preferensi; implementasi SharedPreferences ada di
/// data layer.
abstract class PrefsRepository {
  Future<bool> getDarkMode();

  Future<void> setDarkMode(bool value);

  Future<void> markOpenedNow();

  Future<String?> getLastOpened();
}
