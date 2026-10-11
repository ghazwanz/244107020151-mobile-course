import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Pembuka database aplikasi.
///
/// Satu file database dipakai bersama fitur `notes` (tabel `notes`) dan
/// `posts` (tabel `cached_posts`). Fungsi ini disuntikkan ke repository
/// sebagai `Future<Database> Function()` sehingga mudah diganti fake saat test.
Future<Database> openAppDb() async {
  final dir = await getDatabasesPath();
  return openDatabase(
    p.join(dir, 'offline_notes.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL DEFAULT '',
          updated_at TEXT NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE cached_posts(
          id INTEGER PRIMARY KEY,
          payload TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
    },
  );
}
