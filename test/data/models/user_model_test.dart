import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_flutter_app/data/models/user_model.dart';

void main() {
  group('User', () {
    test('should create from JSON', () {
      final json = {
        'id': 'user-123',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'ADMIN',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.role, 'ADMIN');
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('should handle null dates in JSON', () {
      final json = {
        'id': 'user-123',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'CASHIER',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    test('toJson should include all fields', () {
      final user = User(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        role: 'ADMIN',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final json = user.toJson();

      expect(json['id'], 'user-123');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['role'], 'ADMIN');
      expect(json['createdAt'], isNotNull);
    });

    test('isAdmin should return true for ADMIN role', () {
      final admin = User(
        id: '1',
        name: 'Admin',
        email: 'admin@test.com',
        role: 'ADMIN',
      );

      expect(admin.isAdmin, isTrue);
    });

    test('copyWith should create new instance with updated values', () {
      final original = User(
        id: '1',
        name: 'Original',
        email: 'original@test.com',
        role: 'ADMIN',
      );

      final updated = original.copyWith(name: 'Updated');

      expect(updated.id, '1');
      expect(updated.name, 'Updated');
      expect(updated.email, 'original@test.com');
      expect(original.name, 'Original'); // Original unchanged
    });

    test('equality should be based on id', () {
      final user1 = User(
        id: '1',
        name: 'User 1',
        email: 'user1@test.com',
        role: 'ADMIN',
      );

      final user2 = User(
        id: '1',
        name: 'Different Name',
        email: 'different@test.com',
        role: 'CASHIER',
      );

      expect(user1, equals(user2)); // Same id
    });

    test('toString should include key fields', () {
      final user = User(
        id: '1',
        name: 'Test',
        email: 'test@test.com',
        role: 'ADMIN',
      );

      expect(user.toString(), contains('id: 1'));
      expect(user.toString(), contains('name: Test'));
    });
  });
}
