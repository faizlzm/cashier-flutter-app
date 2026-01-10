import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_flutter_app/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('apiBaseUrl should not be empty', () {
      final url = AppConfig.apiBaseUrl;
      expect(url, isNotEmpty);
    });

    test('apiBaseUrl should start with http', () {
      final url = AppConfig.apiBaseUrl;
      expect(url, startsWith('http'));
    });

    test('apiBaseUrl should end with /api', () {
      final url = AppConfig.apiBaseUrl;
      expect(url, endsWith('/api'));
    });

    test('connectTimeout should be reasonable', () {
      expect(AppConfig.connectTimeout.inSeconds, greaterThanOrEqualTo(10));
      expect(AppConfig.connectTimeout.inSeconds, lessThanOrEqualTo(60));
    });

    test('receiveTimeout should be reasonable', () {
      expect(AppConfig.receiveTimeout.inSeconds, greaterThanOrEqualTo(10));
      expect(AppConfig.receiveTimeout.inSeconds, lessThanOrEqualTo(60));
    });

    test('accessTokenKey should be defined', () {
      expect(AppConfig.accessTokenKey, isNotEmpty);
    });

    test('refreshTokenKey should be defined', () {
      expect(AppConfig.refreshTokenKey, isNotEmpty);
    });

    test('databaseName should be defined', () {
      expect(AppConfig.databaseName, isNotEmpty);
      expect(AppConfig.databaseName, endsWith('.db'));
    });

    test('productsCacheExpiry should be at least 1 hour', () {
      expect(AppConfig.productsCacheExpiry.inHours, greaterThanOrEqualTo(1));
    });
  });
}
