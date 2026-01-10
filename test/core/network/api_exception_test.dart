import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_flutter_app/core/network/api_exception.dart';

void main() {
  group('ApiException', () {
    test('should create with message and statusCode', () {
      const exception = ApiException(message: 'Test error', statusCode: 500);

      expect(exception.message, 'Test error');
      expect(exception.statusCode, 500);
      expect(exception.data, isNull);
    });

    test('toString should include message and status', () {
      const exception = ApiException(message: 'Test error', statusCode: 500);

      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('500'));
    });
  });

  group('UnauthorizedException', () {
    test('should have default message and 401 status', () {
      const exception = UnauthorizedException();

      expect(exception.statusCode, 401);
      expect(exception.message, isNotEmpty);
    });

    test('should allow custom message', () {
      const exception = UnauthorizedException(message: 'Custom auth error');

      expect(exception.message, 'Custom auth error');
      expect(exception.statusCode, 401);
    });
  });

  group('ValidationException', () {
    test('should have default message and 400 status', () {
      const exception = ValidationException();

      expect(exception.statusCode, 400);
      expect(exception.errors, isEmpty);
    });

    test('should store validation errors', () {
      const errors = [
        ValidationError(field: 'email', message: 'Email tidak valid'),
        ValidationError(field: 'password', message: 'Password terlalu pendek'),
      ];

      const exception = ValidationException(errors: errors);

      expect(exception.errors.length, 2);
      expect(exception.errors[0].field, 'email');
      expect(exception.errors[1].field, 'password');
    });

    test('getFieldError should return correct error message', () {
      const errors = [
        ValidationError(field: 'email', message: 'Email tidak valid'),
        ValidationError(field: 'password', message: 'Password terlalu pendek'),
      ];

      const exception = ValidationException(errors: errors);

      expect(exception.getFieldError('email'), 'Email tidak valid');
      expect(exception.getFieldError('password'), 'Password terlalu pendek');
      expect(exception.getFieldError('name'), isNull);
    });
  });

  group('ValidationError', () {
    test('fromJson should parse correctly', () {
      final json = {'field': 'email', 'message': 'Invalid email'};

      final error = ValidationError.fromJson(json);

      expect(error.field, 'email');
      expect(error.message, 'Invalid email');
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final error = ValidationError.fromJson(json);

      expect(error.field, '');
      expect(error.message, '');
    });
  });

  group('ForbiddenException', () {
    test('should have 403 status', () {
      const exception = ForbiddenException();

      expect(exception.statusCode, 403);
      expect(exception.message, isNotEmpty);
    });
  });

  group('NotFoundException', () {
    test('should have 404 status', () {
      const exception = NotFoundException();

      expect(exception.statusCode, 404);
      expect(exception.message, isNotEmpty);
    });
  });

  group('ServerException', () {
    test('should have 500 status', () {
      const exception = ServerException();

      expect(exception.statusCode, 500);
      expect(exception.message, isNotEmpty);
    });
  });

  group('NetworkException', () {
    test('should have descriptive message', () {
      const exception = NetworkException();

      expect(exception.message, contains('koneksi'));
    });
  });

  group('TimeoutException', () {
    test('should have descriptive message', () {
      const exception = TimeoutException();

      expect(exception.message.toLowerCase(), contains('timeout'));
    });
  });
}
