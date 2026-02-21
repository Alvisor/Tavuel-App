import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import 'api_interceptors.dart';

/// Provides a singleton [Dio] instance configured for the Tavuel API.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});

/// Centralized HTTP client for all API communication.
class ApiClient {
  late final Dio _dio;
  final Ref _ref;

  ApiClient(this._ref) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(seconds: AppConstants.receiveTimeout),
        sendTimeout: const Duration(seconds: AppConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': AppConstants.appVersion,
          'X-Platform': 'flutter',
        },
      ),
    );

    // Interceptors are added in order of execution
    _dio.interceptors.addAll([
      AuthInterceptor(_ref),
      _buildRefreshTokenInterceptor(),
      if (kDebugMode) _buildLogInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  // ──────────────────────────────────────────────
  // Convenience HTTP methods
  // ──────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload a file with multipart form data.
  Future<Response<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Interceptors
  // ──────────────────────────────────────────────

  /// Interceptor that attempts to refresh the access token on 401 responses.
  QueuedInterceptorsWrapper _buildRefreshTokenInterceptor() {
    return QueuedInterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        if (error.response?.statusCode == 401) {
          try {
            // Attempt token refresh using a separate Dio instance
            // to avoid interceptor recursion.
            final refreshDio = Dio(
              BaseOptions(baseUrl: AppConstants.apiBaseUrl),
            );

            final storage = SecureStorageHelper(_ref);
            final refreshToken = await storage.getRefreshToken();

            if (refreshToken == null) {
              return handler.reject(error);
            }

            final response = await refreshDio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            if (response.statusCode == 200) {
              final newAccessToken = response.data['accessToken'] as String;
              final newRefreshToken = response.data['refreshToken'] as String;

              await storage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              // Retry the original request with the new token
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await _dio.fetch(options);
              return handler.resolve(retryResponse);
            }
          } catch (_) {
            // Refresh failed — clear tokens and let auth guard redirect
            final storage = SecureStorageHelper(_ref);
            await storage.clearTokens();
          }
        }
        return handler.reject(error);
      },
    );
  }

  /// Pretty-print logs in debug mode (filters sensitive data).
  LogInterceptor _buildLogInterceptor() {
    return LogInterceptor(
      requestBody: false,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
      error: true,
      logPrint: (object) => debugPrint(object.toString()),
    );
  }

  // ──────────────────────────────────────────────
  // Error mapping
  // ──────────────────────────────────────────────

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message:
              'La conexión ha tardado demasiado. Por favor verifica tu internet.',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message:
              'No se pudo conectar al servidor. Verifica tu conexión a internet.',
          statusCode: null,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return const AppException(message: 'La solicitud fue cancelada.');

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Error de seguridad en la conexión.',
        );

      case DioExceptionType.unknown:
      default:
        return const AppException(
          message: 'Ocurrió un error inesperado. Intenta de nuevo.',
        );
    }
  }

  AppException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode ?? 500;
    final data = response?.data;

    String message = 'Error del servidor.';
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      final rawMessage = data['message'];
      if (rawMessage is String) {
        message = rawMessage;
      } else if (rawMessage is List) {
        message = rawMessage.join('. ');
      }
    }

    switch (statusCode) {
      case 400:
        return AppException(message: message, statusCode: statusCode);
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return AppException(
          message: 'No tienes permisos para realizar esta acción.',
          statusCode: statusCode,
        );
      case 404:
        return AppException(
          message: 'Recurso no encontrado.',
          statusCode: statusCode,
        );
      case 409:
        return AppException(message: message, statusCode: statusCode);
      case 422:
        return AppException(
          message: 'Los datos enviados no son válidos.',
          statusCode: statusCode,
        );
      case 429:
        return AppException(
          message: 'Demasiadas solicitudes. Espera un momento.',
          statusCode: statusCode,
        );
      case >= 500:
        return ServerException(
          message: 'Error interno del servidor. Intenta más tarde.',
          statusCode: statusCode,
        );
      default:
        return AppException(message: message, statusCode: statusCode);
    }
  }
}
