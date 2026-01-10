import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:cashier_flutter_app/core/network/api_client.dart';
import 'package:cashier_flutter_app/core/network/api_exception.dart';
import 'package:cashier_flutter_app/core/config/app_config.dart';

void main() {
  group('ApiClient', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    test('should be a singleton', () {
      final client1 = ApiClient();
      final client2 = ApiClient();

      expect(identical(client1, client2), isTrue);
    });

    test('should have a valid Dio instance', () {
      expect(apiClient.dio, isNotNull);
      expect(apiClient.dio, isA<Dio>());
    });

    test('should have correct base URL', () {
      expect(apiClient.dio.options.baseUrl, AppConfig.apiBaseUrl);
    });

    test('should have correct timeouts', () {
      expect(apiClient.dio.options.connectTimeout, AppConfig.connectTimeout);
      expect(apiClient.dio.options.receiveTimeout, AppConfig.receiveTimeout);
    });

    test('should have JSON content type header', () {
      expect(apiClient.dio.options.headers['Content-Type'], 'application/json');
    });

    test('should have Accept header', () {
      expect(apiClient.dio.options.headers['Accept'], 'application/json');
    });
  });

  group('DioExceptionExtension', () {
    test(
      'apiException should return ApiException when error is ApiException',
      () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          error: const UnauthorizedException(),
        );

        final apiException = dioException.apiException;

        expect(apiException, isA<UnauthorizedException>());
      },
    );

    test(
      'apiException should return generic ApiException when error is not ApiException',
      () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          message: 'Some error',
        );

        final apiException = dioException.apiException;

        expect(apiException, isA<ApiException>());
        expect(apiException.message, 'Some error');
      },
    );
  });
}
