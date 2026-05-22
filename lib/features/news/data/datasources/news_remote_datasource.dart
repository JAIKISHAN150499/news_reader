import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../models/article_dto.dart';

abstract class NewsRemoteDataSource {
  Future<List<ArticleDto>> getTopHeadlines({
    required String category,
    required int page,
    int? pageSize,
  });

  Future<List<ArticleDto>> searchArticles({
    required String query,
    required int page,
    int? pageSize,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final DioClient dioClient;

  NewsRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ArticleDto>> getTopHeadlines({
    required String category,
    required int page,
    int? pageSize,
  }) async {
    try {
      final max = pageSize ?? int.tryParse(dotenv.env['GNEWS_MAX_PER_PAGE'] ?? '20') ?? 20;

      final response = await dioClient.dio.get(
        '/top-headlines',
        queryParameters: {
          'category': category,
          'lang': 'en',
          'country': 'us',
          'page': page,
          'max': max,
        },
      );

      final parsed = NewsApiResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      return parsed.articles ?? [];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Connection timed out');
      }
      
      final response = e.response;
      if (response != null) {
        final data = response.data;
        String errorMessage = 'Server error';
        if (data is Map && data.containsKey('errors')) {
          errorMessage = (data['errors'] as List).join(', ');
        } else if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
        throw ServerFailure(errorMessage, statusCode: response.statusCode);
      }
      throw ServerFailure(e.message ?? 'Unknown network error');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ArticleDto>> searchArticles({
    required String query,
    required int page,
    int? pageSize,
  }) async {
    try {
      final max = pageSize ?? int.tryParse(dotenv.env['GNEWS_MAX_PER_PAGE'] ?? '20') ?? 20;

      final response = await dioClient.dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'lang': 'en',
          'page': page,
          'max': max,
        },
      );

      final parsed = NewsApiResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      return parsed.articles ?? [];
    } on DioException catch (e) {
      final response = e.response;
      String errorMessage = 'Search failed';
      if (response != null && response.data is Map && response.data.containsKey('message')) {
        errorMessage = response.data['message'];
      }
      throw ServerFailure(errorMessage, statusCode: response?.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
