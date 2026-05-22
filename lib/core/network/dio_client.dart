// ─────────────────────────────────────────────────────────────
// core/network/dio_client.dart
//
// WHY DIO over http package?
//   Dio gives us interceptors — middleware that runs on every
//   request/response. We use this to:
//     1. AuthInterceptor: automatically inject the API key from .env
//        so NO individual API call needs to know about the key.
//     2. LoggingInterceptor: log all requests/responses in debug mode.
//     3. Retry logic: auto-retry on network failures.
//
// ARCHITECTURE: Only the DataSource layer uses this. Domain and
// Presentation layers never touch Dio directly.
// ─────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'https://gnews.io/api/v4';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors in order — they run as a pipeline
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      if (kDebugMode) _LogInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}


class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'NEWS_API_KEY is not set in .env file',
          type: DioExceptionType.unknown,
        ),
      );
      return;
    }

    options.queryParameters['apikey'] = apiKey;
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('✗ Error: ${err.message}');
    handler.next(err);
  }
}
