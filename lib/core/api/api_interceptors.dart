import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys used to store tokens in secure storage.
abstract class StorageKeys {
  static const String accessToken = 'tavuel_access_token';
  static const String refreshToken = 'tavuel_refresh_token';
  static const String userId = 'tavuel_user_id';
}

/// Provides a singleton [FlutterSecureStorage] instance.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

/// Helper to read/write tokens from secure storage.
class SecureStorageHelper {
  final Ref _ref;

  SecureStorageHelper(this._ref);

  FlutterSecureStorage get _storage => _ref.read(secureStorageProvider);

  Future<String?> getAccessToken() async {
    return _storage.read(key: StorageKeys.accessToken);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
      _storage.delete(key: StorageKeys.userId),
    ]);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: StorageKeys.userId, value: userId);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: StorageKeys.userId);
  }
}

/// Dio interceptor that adds the Bearer token to every outgoing request.
class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints
    final publicPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/google',
    ];

    final isPublic = publicPaths.any(
      (path) => options.path.contains(path),
    );

    if (!isPublic) {
      final storage = SecureStorageHelper(_ref);
      final token = await storage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Let errors propagate to the refresh-token interceptor or caller
    return handler.next(err);
  }
}
