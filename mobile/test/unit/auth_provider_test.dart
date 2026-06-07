import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:arudocare_app/features/auth/providers/auth_provider.dart';
import 'package:arudocare_app/core/api/api_client.dart';

void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;
    late DioAdapter dioAdapter;
    late ApiClient apiClient;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      apiClient = ApiClient();
      dioAdapter = DioAdapter(dio: apiClient.dio);
      authProvider = AuthProvider(apiClient: apiClient);
    });

    tearDown(() {
      dioAdapter.close();
    });

    group('initial state', () {
      test('isLoading bernilai false', () {
        expect(authProvider.isLoading, false);
      });

      test('token bernilai null', () {
        expect(authProvider.token, isNull);
      });

      test('user bernilai null', () {
        expect(authProvider.user, isNull);
      });

      test('userName mengembalikan "Pengguna" saat user null', () {
        expect(authProvider.userName, 'Pengguna');
      });
    });

    group('login', () {
      test('mengembalikan true dan menyimpan token saat login berhasil', () async {
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/auth/login',
          (server) => server.reply(200, {
            'token': 'test_jwt_token_123',
            'user': {
              'id': 1,
              'name': 'Budi Santoso',
              'email': 'budi@test.com',
              'role': 'customer',
            },
          }),
        );

        final result = await authProvider.login('budi@test.com', 'password123');

        expect(result, true);
        expect(authProvider.token, 'test_jwt_token_123');
        expect(authProvider.user?['name'], 'Budi Santoso');
        expect(authProvider.isLoading, false);
      });

      test('userName mengembalikan nama user setelah login', () async {
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/auth/login',
          (server) => server.reply(200, {
            'token': 'abc',
            'user': {'id': 2, 'name': 'Siti Rahayu', 'email': 'siti@test.com'},
          }),
        );

        await authProvider.login('siti@test.com', 'pass');

        expect(authProvider.userName, 'Siti Rahayu');
      });

      test('mengembalikan false saat login gagal (401)', () async {
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/auth/login',
          (server) => server.throws(
            401,
            DioException(
              requestOptions: RequestOptions(path: '/auth/login'),
              type: DioExceptionType.badResponse,
            ),
          ),
        );

        final result = await authProvider.login('salah@test.com', 'salahpass');

        expect(result, false);
        expect(authProvider.token, isNull);
        expect(authProvider.isLoading, false);
      });

      test('isLoading kembali ke false setelah login selesai', () async {
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/auth/login',
          (server) => server.reply(200, {
            'token': 'tok',
            'user': {'id': 1, 'name': 'User'},
          }),
        );

        await authProvider.login('user@test.com', 'pass');

        expect(authProvider.isLoading, false);
      });
    });

    group('logout', () {
      test('membersihkan token dan user setelah logout', () async {
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/auth/login',
          (server) => server.reply(200, {
            'token': 'token_to_clear',
            'user': {'id': 1, 'name': 'Test User'},
          }),
        );
        await authProvider.login('test@test.com', 'pass');

        await authProvider.logout();

        expect(authProvider.token, isNull);
        expect(authProvider.user, isNull);
      });

      test('menghapus jwt_token dari SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({'jwt_token': 'existing_token'});
        final provider = AuthProvider(apiClient: apiClient);

        await provider.logout();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('jwt_token'), isNull);
      });

      test('menghapus user_name dari SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({'user_name': 'Nama Tersimpan'});
        final provider = AuthProvider(apiClient: apiClient);

        await provider.logout();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('user_name'), isNull);
      });
    });

    group('register', () {
      test('mengembalikan true saat registrasi berhasil (201)', () async {
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/auth/register',
          (server) => server.reply(201, {'message': 'User registered'}),
        );

        final result = await authProvider.register(
          'Ahmad',
          'ahmad@test.com',
          'password123',
          'customer',
        );

        expect(result, true);
        expect(authProvider.isLoading, false);
      });

      test('mengembalikan false saat registrasi gagal', () async {
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/auth/register',
          (server) => server.throws(
            400,
            DioException(
              requestOptions: RequestOptions(path: '/auth/register'),
              type: DioExceptionType.badResponse,
            ),
          ),
        );

        final result = await authProvider.register(
          'Ahmad',
          'duplikat@test.com',
          'password123',
          'customer',
        );

        expect(result, false);
        expect(authProvider.isLoading, false);
      });
    });
  });
}
