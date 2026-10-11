import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Mengubah [FirebaseAuthException] menjadi pesan yang ramah untuk pengguna.
///
/// Kode galat Firebase Auth dipetakan agar UI tidak menampilkan pesan mentah
/// berbahasa Inggris (mis. `wrong-password`).
String friendlyAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'user-not-found':
        return 'Akun tidak ditemukan.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah (minimal 6 karakter).';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Gagal masuk: ${error.message ?? error.code}';
    }
  }
  return error.toString().replaceFirst('Exception: ', '');
}

/// Mengubah [DioException] menjadi pesan yang ramah untuk pengguna.
///
/// Tujuan refactoring: UI hanya menerima `String`, bukan exception mentah,
/// sehingga tidak perlu tahu detail teknis Dio. Pesan 401 sengaja
/// mengarahkan pengguna untuk masuk ulang (refresh token ikut kedaluwarsa).
String friendlyApiError(Object error) {
  if (error is! DioException) {
    return 'Terjadi kesalahan tak terduga.';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Koneksi lambat. Silakan coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi internet.';
    case DioExceptionType.badCertificate:
      return 'Sertifikat server tidak valid.';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      if (code == 401) return 'Sesi berakhir. Silakan masuk kembali.';
      if (code == 403) return 'Anda tidak punya akses.';
      if (code == 404) return 'Data tidak ditemukan.';
      if (code != null && code >= 500) return 'Server sedang bermasalah.';
      return 'Permintaan gagal (kode $code).';
    case DioExceptionType.unknown:
      return 'Gagal terhubung ke server.';
  }
}
