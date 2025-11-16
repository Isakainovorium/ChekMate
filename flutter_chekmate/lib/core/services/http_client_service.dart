import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chekmate/core/config/environment_config.dart';

/// Auth Interceptor for adding authentication headers
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth headers here when authentication is implemented
    // For now, just pass through
    handler.next(options);
  }
}

/// Error Interceptor for handling common errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle common errors here
    // For now, just pass through
    handler.next(err);
  }
}

/// Retry Interceptor for handling retries
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
  });

  final Dio dio;
  final int maxRetries;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle retries here
    // For now, just pass through
    handler.next(err);
  }
}

/// HTTP Client Service
/// Provides a configured Dio instance for making HTTP requests
class HttpClientService {
  HttpClientService._();

  static HttpClientService? _instance;
  static Dio? _dio;

  /// Get the singleton instance
  static HttpClientService get instance {
    _instance ??= HttpClientService._();
    return _instance!;
  }

  /// Get the configured Dio instance
  Dio get dio {
    _dio ??= _createDioInstance();
    return _dio!;
  }

  /// Create and configure Dio instance
  Dio _createDioInstance() {
    final dio = Dio();

    // Base configuration
    dio.options = BaseOptions(
      baseUrl: EnvironmentConfig.current.apiBaseUrl,
      connectTimeout: Duration(milliseconds: EnvironmentConfig.current.apiTimeout),
      receiveTimeout: Duration(milliseconds: EnvironmentConfig.current.apiTimeout),
      sendTimeout: Duration(milliseconds: EnvironmentConfig.current.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // Accept 2xx and 4xx status codes, reject 5xx
        return status != null && (status >= 200 && status < 500);
      },
    );

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      RetryInterceptor(dio: dio, maxRetries: 3),
      if (kDebugMode) LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    ]);

    return dio;
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.get<T>(
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
  }) {
    return dio.post<T>(
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
  }) {
    return dio.put<T>(
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
  }) {
    return dio.patch<T>(
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
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options? options,
  }) {
    return dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }

  /// Upload file
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.post<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
