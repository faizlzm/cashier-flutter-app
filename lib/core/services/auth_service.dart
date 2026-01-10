import 'package:dio/dio.dart';
import '../../data/models/user_model.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import 'token_storage.dart';

/// Authentication result containing user and tokens
class AuthResult {
  final User user;
  final String accessToken;
  final String refreshToken;

  const AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

/// Authentication service for login, register, and user management
class AuthService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthService({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  /// Login with email and password
  /// Returns AuthResult with user and tokens
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final result = AuthResult.fromJson(response.data['data']);

      // Save tokens
      await _tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return result;
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Register a new user
  /// Returns AuthResult with user and tokens
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      final result = AuthResult.fromJson(response.data['data']);

      // Save tokens
      await _tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return result;
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Get current authenticated user
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Logout - clear tokens
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  /// Check if user has valid tokens
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.hasTokens();
  }

  /// Refresh access token
  Future<String> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const UnauthorizedException(message: 'No refresh token');
      }

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['data']['accessToken'] as String;
      final newRefreshToken =
          (response.data['data']['refreshToken'] as String?) ?? refreshToken;

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return newAccessToken;
    } on DioException catch (e) {
      throw e.apiException;
    }
  }
}
