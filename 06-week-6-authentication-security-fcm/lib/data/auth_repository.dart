import 'package:firebase_auth/firebase_auth.dart';

/// Sesi hasil login: `access` (ID token) + `refresh` (refresh token).
class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

/// Kontrak backend autentikasi.
///
/// Dibuat sebagai abstraksi agar [AuthRepository] dapat diuji tanpa
/// Firebase sungguhan (test memakai fake), dan agar implementasi mock
/// lama tetap bisa dipakai bila diperlukan.
abstract class AuthBackend {
  /// Menukar kredensial menjadi sesi (access + refresh token).
  Future<AuthSession> signIn({required String email, required String password});

  /// Menukar refresh token menjadi access token baru.
  Future<String> refresh(String refreshToken);

  /// Mengakhiri sesi di sisi backend.
  Future<void> signOut();
}

/// Implementasi nyata memakai **Firebase Auth** (email + kata sandi).
///
/// Ini adalah titik "GANTI" yang diminta modul: kredensial tidak lagi
/// disimulasikan, melainkan diverifikasi Firebase.
/// - `access` = **ID token** Firebase (JWT berumur pendek, dikirim sebagai
///   `Authorization: Bearer ...`).
/// - `refresh` = penanda sesi. Catatan penting: di Android/iOS `refreshToken`
///   Firebase berupa string kosong karena SDK mengelola refresh token secara
///   internal (hanya web yang mengembalikannya). Penukaran ID token baru
///   tetap dilakukan lewat SDK pada [refresh].
class FirebaseAuthBackend implements AuthBackend {
  FirebaseAuthBackend({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Firebase Auth tidak mengembalikan data pengguna.');
    }

    // ID token kadang belum siap tepat setelah sign-in; ambil sekali lagi
    // dengan paksa refresh bila percobaan pertama null.
    final idToken = await user.getIdToken() ?? await user.getIdToken(true);
    if (idToken == null) {
      throw Exception('Gagal memperoleh ID token dari Firebase Auth.');
    }

    // Simpan uid sebagai penanda sesi bila refresh token tidak tersedia
    // (perilaku normal di Android/iOS).
    final refreshToken = user.refreshToken;
    final sessionHandle =
        (refreshToken == null || refreshToken.isEmpty) ? user.uid : refreshToken;
    return AuthSession(access: idToken, refresh: sessionHandle);
  }

  @override
  Future<String> refresh(String refreshToken) async {
    // Nilai `refreshToken` tidak dipakai langsung: di Android/iOS SDK Firebase
    // memegang refresh token secara internal. ID token baru diminta lewat
    // `getIdToken(true)` (force refresh) dari user yang sedang login.
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Tidak ada sesi Firebase aktif (perlu login ulang).');
    }
    final idToken = await user.getIdToken(true);
    if (idToken == null) {
      throw Exception('Refresh token kedaluwarsa (perlu login ulang).');
    }
    return idToken;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

/// Repository autentikasi aplikasi.
///
/// Menerima [AuthBackend] agar implementasi dapat diganti: Firebase Auth
/// di aplikasi, fake di unit test. Validasi kredensial dasar tetap dilakukan
/// sebelum memanggil backend agar pesan galat konsisten.
class AuthRepository {
  AuthRepository({AuthBackend? backend})
      : _backend = backend ?? FirebaseAuthBackend();

  final AuthBackend _backend;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) {
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }
    return _backend.signIn(email: email, password: password);
  }

  Future<String> refresh(String refreshToken) => _backend.refresh(refreshToken);

  Future<void> logout() => _backend.signOut();
}
