import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chekmate/core/config/environment_config.dart';
import 'package:flutter_chekmate/core/utils/logger.dart';

/// HttpClientService - Dio-based HTTP Client
///
/// Provides a configured Dio instance for making HTTP requests to third-party APIs.
/// Includes interceptors for logging, error handling, and authentication.
///
/// Use Cases:
/// - Stripe API (subscription payments)
/// - RevenueCat API (in-app purchases)
/// - Spotify API (share music in posts)
/// - Giphy API (GIF search for messages)
/// - Location APIs (reverse geocoding)
/// - Analytics APIs (Mixpanel, Amplitude)
/// - Content moderation APIs
///
/// Features:
/// - Automatic retry logic
/// - Request/response logging
/// - Error handling
/// - Timeout configuration
/// - Auth token injection
/// - Request/response transformation
///
/// Usage:
/// ```dart
/// final client = HttpClientService.instance;
/// final response = await client.get('/endpoint');
/// ```
class HttpClientService {
  HttpClientService._internal() {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }

  static final HttpClientService _instance = HttpClientService._internal();
  static HttpClientService get instance => _instance;

  late final Dio _dio;

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Base options for Dio
  BaseOptions get _baseOptions => BaseOptions(
        baseUrl: EnvironmentConfig.current.apiBaseUrl,
        connectTimeout: Duration(
          milliseconds: EnvironmentConfig.current.apiTimeout,
        ),
        receiveTimeout: Duration(
          milliseconds: EnvironmentConfig.current.apiTimeout,
        ),
        sendTimeout: Duration(
          milliseconds: EnvironmentConfig.current.apiTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept all status codes to handle them in interceptors
          return status != null && status < 500;
        },
      );

  /// Setup interceptors
  void _setupInterceptors() {
    // Logging interceptor
    if (EnvironmentConfig.current.enableDebugLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => Logger.debug('[HTTP] $obj'),
        ),
      );
    }

    // Auth interceptor
    _dio.interceptors.add(AuthInterceptor());

    // Error handling interceptor
    _dio.interceptors.add(ErrorInterceptor());

    // Retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        maxRetries: EnvironmentConfig.current.maxRetries,
      ),
    );
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Download file
  Future<Response<dynamic>> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      options: options,
    );
  }

  /// Upload file
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

/// Auth Interceptor
///
/// Injects authentication tokens into requests
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get auth token from Firebase Auth
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        options.headers['Authorization'] = 'Bearer $token';
      }
    } on Exception catch (e) {
      // Log error but continue with request
      Logger.error('Failed to get auth token', e);
    }

    handler.next(options);
  }
}

/// Error Handling Interceptor
///
/// Handles HTTP errors and transforms them into user-friendly messages
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final error = _handleError(err);
    handler.next(error);
  }

  DioException _handleError(DioException error) {
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        message = _handleStatusCode(error.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificate verification failed';
        break;
      case DioExceptionType.unknown:
        message = 'An unexpected error occurred';
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: message,
    );
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred (Status: $statusCode)';
    }
  }
}

/// Retry Interceptor
///
/// Automatically retries failed requests
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    required this.maxRetries,
  });

  final Dio dio;
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final retries = (extra['retries'] as int?) ?? 0;

    if (retries >= maxRetries) {
      return handler.next(err);
    }

    // Only retry on network errors or 5xx errors
    final shouldRetry = _shouldRetry(err);
    if (!shouldRetry) {
      return handler.next(err);
    }

    // Exponential backoff
    final delay = Duration(milliseconds: 1000 * (retries + 1));
    await Future<void>.delayed(delay);

    // Retry the request
    try {
      final options = err.requestOptions;
      options.extra['retries'] = retries + 1;

      final response = await dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
