import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../core/services/auth_service.dart';
import '../core/network/api_exception.dart';

/// Auth state containing user and loading/error states
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isInitialized;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Auth provider for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier({AuthService? authService})
    : _authService = authService ?? AuthService(),
      super(const AuthState()) {
    // Check authentication status on creation
    _checkAuth();
  }

  /// Check if user is already authenticated (has valid tokens)
  Future<void> _checkAuth() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final hasTokens = await _authService.isAuthenticated();

      if (hasTokens) {
        // Try to get current user
        try {
          final user = await _authService.getCurrentUser();
          state = state.copyWith(
            user: user,
            isLoading: false,
            isInitialized: true,
          );
          return;
        } catch (e) {
          // Token might be expired, clear it
          await _authService.logout();
        }
      }

      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        clearUser: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        clearUser: true,
      );
    }
  }

  /// Login with email and password
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authService.login(email: email, password: password);

      state = state.copyWith(user: result.user, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan. Silakan coba lagi.',
      );
      rethrow;
    }
  }

  /// Register a new user
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      state = state.copyWith(user: result.user, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan. Silakan coba lagi.',
      );
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        clearError: true,
      );
    } catch (e) {
      // Even if logout fails, clear the user locally
      state = state.copyWith(isLoading: false, clearUser: true);
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;

    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      // If refresh fails (e.g., token expired), logout
      await logout();
    }
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Global auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Convenience provider for getting current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Convenience provider for checking if auth is initialized
final isAuthInitializedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isInitialized;
});
