import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../services/token_storage.dart';
import 'api_exception.dart';

/// Singleton API client using Dio with interceptors for auth, logging, and error handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  // Flag to prevent multiple token refresh attempts
  bool _isRefreshing = false;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// Get the Dio instance (for direct access if needed)
  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Add logging in debug mode
    assert(() {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => print('[API] $obj'),
        ),
      );
      return true;
    }());
  }

  /// Attach auth token to requests
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints
    final noAuthPaths = ['/auth/login', '/auth/register', '/auth/refresh'];
    if (!noAuthPaths.any((path) => options.path.contains(path))) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  /// Process responses
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  /// Handle errors and transform to ApiException
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle network errors
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          error: const NetworkException(),
        ),
      );
      return;
    }

    // Handle timeouts
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          error: const TimeoutException(),
        ),
      );
      return;
    }

    final response = error.response;
    if (response == null) {
      handler.next(error);
      return;
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Handle 401 - try to refresh token
    if (statusCode == 401 && !_isRefreshing) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry the original request
        try {
          final retryResponse = await _retry(error.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          // Refresh succeeded but retry failed
        }
      }
      // Token refresh failed - user needs to login again
      await _tokenStorage.clearTokens();
      handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          error: const UnauthorizedException(),
        ),
      );
      return;
    }

    // Transform other errors
    final apiError = _transformError(statusCode, data);
    handler.reject(
      DioException(requestOptions: error.requestOptions, error: apiError),
    );
  }

  /// Try to refresh the access token
  Future<bool> _tryRefreshToken() async {
    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Create a new Dio instance for refresh to avoid interceptor loop
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['accessToken'];
        final newRefreshToken =
            response.data['data']['refreshToken'] ?? refreshToken;

        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Retry a failed request
  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await _tokenStorage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Transform HTTP status codes to ApiException
  ApiException _transformError(int statusCode, dynamic data) {
    final message = data is Map ? data['message'] as String? : null;

    switch (statusCode) {
      case 400:
        // Check for validation errors
        if (data is Map && data['errors'] != null) {
          final errors = (data['errors'] as List)
              .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
              .toList();
          return ValidationException(
            message: message ?? 'Validasi gagal',
            errors: errors,
          );
        }
        return ApiException(
          message: message ?? 'Permintaan tidak valid',
          statusCode: 400,
        );
      case 401:
        return UnauthorizedException(message: message ?? 'Sesi telah berakhir');
      case 403:
        return ForbiddenException(message: message ?? 'Akses ditolak');
      case 404:
        return NotFoundException(message: message ?? 'Data tidak ditemukan');
      case 500:
      case 502:
      case 503:
        return ServerException(message: message ?? 'Terjadi kesalahan server');
      default:
        return ApiException(
          message: message ?? 'Terjadi kesalahan',
          statusCode: statusCode,
        );
    }
  }

  // ==================== HTTP Methods ====================

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// Extension to easily extract ApiException from DioException
extension DioExceptionExtension on DioException {
  ApiException get apiException {
    if (error is ApiException) {
      return error as ApiException;
    }
    return ApiException(message: message ?? 'Terjadi kesalahan');
  }
}
