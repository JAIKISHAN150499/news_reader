import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
    
    // GNews uses 'apikey' in query parameters
    options.queryParameters.addAll({
      'apikey': apiKey,
    });
    
    return super.onRequest(options, handler);
  }
}
