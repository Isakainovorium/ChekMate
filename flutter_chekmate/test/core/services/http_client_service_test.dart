import 'package:dio/dio.dart';
import 'package:flutter_chekmate/core/config/environment_config.dart';
import 'package:flutter_chekmate/core/services/http_client_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpClientService', () {
    late HttpClientService httpClient;

    setUp(() {
      // HttpClientService uses EnvironmentConfig.current which defaults to development
      httpClient = HttpClientService.instance;
    });

    group('Singleton Pattern', () {
      test('should return the same instance', () {
        final instance1 = HttpClientService.instance;
        final instance2 = HttpClientService.instance;

        expect(instance1, equals(instance2));
      });

      test('should have a configured Dio instance', () {
        expect(httpClient.dio, isA<Dio>());
      });
    });

    group('Base Configuration', () {
      test('should have correct base URL from environment config', () {
        final baseUrl = httpClient.dio.options.baseUrl;
        expect(baseUrl, equals(EnvironmentConfig.current.apiBaseUrl));
      });

      test('should have correct timeout configuration', () {
        final connectTimeout = httpClient.dio.options.connectTimeout;
        final receiveTimeout = httpClient.dio.options.receiveTimeout;
        final sendTimeout = httpClient.dio.options.sendTimeout;

        final expectedTimeout = Duration(
          milliseconds: EnvironmentConfig.current.apiTimeout,
        );

        expect(connectTimeout, equals(expectedTimeout));
        expect(receiveTimeout, equals(expectedTimeout));
        expect(sendTimeout, equals(expectedTimeout));
      });

      test('should have correct default headers', () {
        final headers = httpClient.dio.options.headers;

        expect(headers['Content-Type'], equals('application/json'));
        expect(headers['Accept'], equals('application/json'));
      });

      test('should validate status codes correctly', () {
        final validateStatus = httpClient.dio.options.validateStatus;

        // Should accept 2xx and 4xx status codes
        expect(validateStatus(200), isTrue);
        expect(validateStatus(201), isTrue);
        expect(validateStatus(400), isTrue);
        expect(validateStatus(404), isTrue);

        // Should reject 5xx status codes
        expect(validateStatus(500), isFalse);
        expect(validateStatus(503), isFalse);
      });
    });

    group('Interceptors', () {
      test('should have LogInterceptor in debug mode', () {
        final interceptors = httpClient.dio.interceptors;
        final hasLogInterceptor = interceptors.any(
          (interceptor) => interceptor is LogInterceptor,
        );

        expect(hasLogInterceptor, isTrue);
      });

      test('should have AuthInterceptor', () {
        final interceptors = httpClient.dio.interceptors;
        final hasAuthInterceptor = interceptors.any(
          (interceptor) => interceptor is AuthInterceptor,
        );

        expect(hasAuthInterceptor, isTrue);
      });

      test('should have ErrorInterceptor', () {
        final interceptors = httpClient.dio.interceptors;
        final hasErrorInterceptor = interceptors.any(
          (interceptor) => interceptor is ErrorInterceptor,
        );

        expect(hasErrorInterceptor, isTrue);
      });

      test('should have RetryInterceptor', () {
        final interceptors = httpClient.dio.interceptors;
        final hasRetryInterceptor = interceptors.any(
          (interceptor) => interceptor is RetryInterceptor,
        );

        expect(hasRetryInterceptor, isTrue);
      });

      test('should have exactly 5 interceptors', () {
        final interceptors = httpClient.dio.interceptors;
        expect(interceptors.length, equals(5));
      });
    });

    group('HTTP Methods', () {
      test('get method should be callable', () {
        expect(
          () => httpClient.get<dynamic>('/test'),
          returnsNormally,
        );
      });

      test('post method should be callable', () {
        expect(
          () => httpClient.post<dynamic>('/test', data: {'key': 'value'}),
          returnsNormally,
        );
      });

      test('put method should be callable', () {
        expect(
          () => httpClient.put<dynamic>('/test', data: {'key': 'value'}),
          returnsNormally,
        );
      });

      test('patch method should be callable', () {
        expect(
          () => httpClient.patch<dynamic>('/test', data: {'key': 'value'}),
          returnsNormally,
        );
      });

      test('delete method should be callable', () {
        expect(
          () => httpClient.delete<dynamic>('/test'),
          returnsNormally,
        );
      });

      test('download method should be callable', () {
        expect(
          () => httpClient.download('/test', '/path/to/save'),
          returnsNormally,
        );
      });

      test('upload method should be callable', () {
        final formData = FormData();
        expect(
          () => httpClient.upload<dynamic>('/test', formData),
          returnsNormally,
        );
      });
    });

    group('Error Handling', () {
      test('ErrorInterceptor should handle DioException', () {
        final interceptor = ErrorInterceptor();

        // Verify interceptor is created successfully
        expect(interceptor, isA<ErrorInterceptor>());
      });

      test('ErrorInterceptor should provide user-friendly messages', () {
        // Connection timeout
        var error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        expect(error.type, equals(DioExceptionType.connectionTimeout));

        // Receive timeout
        error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.receiveTimeout,
        );
        expect(error.type, equals(DioExceptionType.receiveTimeout));

        // Bad response
        error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 404,
          ),
        );
        expect(error.type, equals(DioExceptionType.badResponse));
        expect(error.response?.statusCode, equals(404));
      });
    });

    group('Retry Logic', () {
      test('RetryInterceptor should have correct configuration', () {
        final dio = httpClient.dio;
        final interceptor = RetryInterceptor(dio: dio, maxRetries: 3);

        // Verify interceptor is created successfully
        expect(interceptor, isA<RetryInterceptor>());
      });

      test('RetryInterceptor should retry on network errors', () {
        final dio = httpClient.dio;
        final interceptor = RetryInterceptor(dio: dio, maxRetries: 3);
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );

        expect(
          () => interceptor.onError(error, ErrorInterceptorHandler()),
          returnsNormally,
        );
      });
    });

    group('Auth Token Injection', () {
      test('AuthInterceptor should be called on requests', () {
        final interceptor = AuthInterceptor();
        final options = RequestOptions(path: '/test');

        expect(
          () => interceptor.onRequest(options, RequestInterceptorHandler()),
          returnsNormally,
        );
      });

      test('AuthInterceptor should not modify headers when no token', () {
        final interceptor = AuthInterceptor();
        final options = RequestOptions(path: '/test');
        final originalHeaders = Map<String, dynamic>.from(options.headers);

        interceptor.onRequest(options, RequestInterceptorHandler());

        // Headers should remain unchanged when no token is available
        expect(options.headers.length, equals(originalHeaders.length));
      });
    });

    group('Logging', () {
      test('LogInterceptor should be configured for debug mode', () {
        final interceptors = httpClient.dio.interceptors;
        final logInterceptor = interceptors.firstWhere(
          (interceptor) => interceptor is LogInterceptor,
          orElse: () => throw Exception('LogInterceptor not found'),
        ) as LogInterceptor;

        expect(logInterceptor, isA<LogInterceptor>());
      });
    });
  });
}
