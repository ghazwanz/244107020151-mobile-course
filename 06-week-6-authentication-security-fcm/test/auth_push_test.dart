import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/routes.dart';

/// Token store in-memory: menggantikan `flutter_secure_storage` (plugin
/// platform) supaya logika sesi bisa diuji tanpa perangkat/Firebase.
class FakeTokenStore extends TokenStore {
  FakeTokenStore({this.access, this.refresh});

  String? access;
  String? refresh;

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

/// Backend auth palsu: menggantikan Firebase Auth supaya logika sesi
/// dapat diuji tanpa inisialisasi Firebase.
class FakeAuthBackend implements AuthBackend {
  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
  }

  @override
  Future<String> refresh(String refreshToken) async {
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> signOut() async {}
}

/// Adapter Dio palsu: mengembalikan 401 pada panggilan pertama
/// (token kedaluwarsa), lalu 200 setelah request diulang.
class _ExpiredOnceAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final headers = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    };
    if (calls == 1) {
      return ResponseBody.fromString('{"error":"expired"}', 401,
          headers: headers);
    }
    return ResponseBody.fromString('{"ok":true}', 200, headers: headers);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('routeFromMessage (parsing route dari data payload)', () {
    test('data kosong memakai rute home', () {
      expect(routeFromMessage({}), Routes.home);
      expect(routeFromMessage({'id': '3'}), Routes.home);
    });

    test('rute tanpa garis miring depan ditambahkan', () {
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    });

    test('rute dengan garis miring depan dibiarkan', () {
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('data payload membawa id pengumuman', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), Routes.announcement('3'));
    });
  });

  group('sesi & refresh token', () {
    test('login valid mengembalikan access + refresh', () async {
      final session = await AuthRepository(backend: FakeAuthBackend())
          .login(email: 'mhs@polinema.ac.id', password: 'rahasia');
      expect(session.access, contains('mhs@polinema.ac.id'));
      expect(session.refresh, isNotEmpty);
    });

    test('login tidak valid melempar exception', () async {
      expect(
        () => AuthRepository(backend: FakeAuthBackend())
            .login(email: 'salah', password: '123'),
        throwsException,
      );
    });

    test('401 memicu refresh sekali lalu retry berhasil', () async {
      final store = FakeTokenStore(
        access: 'mock-access-lama',
        refresh: 'mock-refresh-ada',
      );
      final dio = buildApiClient(store, AuthRepository(backend: FakeAuthBackend()));
      final adapter = _ExpiredOnceAdapter();
      dio.httpClientAdapter = adapter;

      final res = await dio.get('/pengumuman/3');

      expect(res.statusCode, 200);
      expect(adapter.calls, 2, reason: 'request harus diulang tepat sekali');
      expect(store.access, startsWith('mock-access-renewed-'));
      expect(store.refresh, 'mock-refresh-ada');
    });

    test('refresh mati -> sesi dibersihkan (paksa login ulang)', () async {
      final store = FakeTokenStore(access: 'mock-access-lama', refresh: '');
      final dio = buildApiClient(store, AuthRepository(backend: FakeAuthBackend()));
      dio.httpClientAdapter = _ExpiredOnceAdapter();

      await expectLater(dio.get('/pengumuman/3'), throwsA(isA<DioException>()));
      expect(store.access, isNull);
      expect(store.refresh, isNull);
    });
  });

  group('friendlyApiError (DioException -> pesan pengguna)', () {
    test('401 -> arahkan masuk kembali', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );
      expect(friendlyApiError(err), contains('masuk kembali'));
    });

    test('timeout & offline punya pesan masing-masing', () {
      expect(
        friendlyApiError(DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionTimeout,
        )),
        contains('Koneksi lambat'),
      );
      expect(
        friendlyApiError(DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
        )),
        contains('internet'),
      );
    });
  });

  group('friendlyAuthError (FirebaseAuthException -> pesan pengguna)', () {
    test('kode salah sandi & email tidak ditemukan punya pesan ramah', () {
      expect(
        friendlyAuthError(FirebaseAuthException(code: 'wrong-password')),
        contains('salah'),
      );
      expect(
        friendlyAuthError(FirebaseAuthException(code: 'user-not-found')),
        contains('tidak ditemukan'),
      );
      expect(
        friendlyAuthError(FirebaseAuthException(code: 'invalid-credential')),
        contains('salah'),
      );
    });

    test('galat non-Firebase memakai pesan aslinya', () {
      expect(friendlyAuthError(Exception('Email atau kata sandi tidak valid')),
          'Email atau kata sandi tidak valid');
    });
  });
}
