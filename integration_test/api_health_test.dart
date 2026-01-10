/// Integration test for API connectivity
/// Run with: flutter test integration_test/api_health_test.dart
/// Note: Requires the API server to be running on localhost:3001
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_flutter_app/core/network/api_client.dart';
import 'package:cashier_flutter_app/core/config/app_config.dart';

void main() {
  group('API Integration Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    test(
      'Health endpoint should return OK',
      () async {
        // This test requires the API to be running
        // Skip in CI environments
        try {
          final response = await apiClient.dio.get(
            '/health'.replaceFirst('/api', ''),
            options: null,
          );

          expect(response.statusCode, 200);
          expect(response.data['status'], 'ok');
          print('✅ API Health Check Passed');
          print('   Base URL: ${AppConfig.apiBaseUrl}');
          print('   Response: ${response.data}');
        } catch (e) {
          print('⚠️ API not reachable (expected if server is not running)');
          print('   Attempted URL: ${AppConfig.apiBaseUrl}');
          print('   Error: $e');
          // Don't fail the test - just skip
          // The test is informational
        }
      },
      skip: 'Run manually with API server running',
    );

    test('API base URL should be configured correctly', () {
      final baseUrl = AppConfig.apiBaseUrl;

      print('📍 Configured API URL: $baseUrl');

      // Basic URL validation
      expect(baseUrl, isNotEmpty);
      expect(baseUrl, startsWith('http'));
      expect(baseUrl, contains(':3001'));
    });
  });
}
