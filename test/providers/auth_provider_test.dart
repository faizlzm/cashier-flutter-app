import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_flutter_app/data/models/user_model.dart';
import 'package:cashier_flutter_app/providers/auth_provider.dart';

void main() {
  group('AuthState', () {
    test('should have default values', () {
      const state = AuthState();

      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isInitialized, isFalse);
      expect(state.error, isNull);
      expect(state.isAuthenticated, isFalse);
    });

    test('isAuthenticated should be true when user is set', () {
      final state = AuthState(user: _createMockUser());

      expect(state.isAuthenticated, isTrue);
    });

    test('copyWith should update specific fields', () {
      const original = AuthState(isLoading: true);
      final updated = original.copyWith(isInitialized: true);

      expect(updated.isLoading, isTrue);
      expect(updated.isInitialized, isTrue);
    });

    test('copyWith with clearUser should set user to null', () {
      final original = AuthState(user: _createMockUser());
      final updated = original.copyWith(clearUser: true);

      expect(updated.user, isNull);
      expect(updated.isAuthenticated, isFalse);
    });

    test('copyWith with clearError should set error to null', () {
      const original = AuthState(error: 'Some error');
      final updated = original.copyWith(clearError: true);

      expect(updated.error, isNull);
    });
  });
}

// Helper to create mock user
User _createMockUser() {
  return const User(
    id: 'test-id',
    name: 'Test User',
    email: 'test@test.com',
    role: 'ADMIN',
  );
}
