import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';
import '../datasources/news_local_datasource.dart';
import '../models/article_hive_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Article>>> getTopHeadlines({
    required String category,
    required int page,
    int pageSize = 20,
  }) async {
    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        final dtos = await remoteDataSource.getTopHeadlines(
          category: category,
          page: page,
          pageSize: pageSize,
        );

        final hiveModels = dtos
            .map((dto) => ArticleHiveModel.fromEntity(dto.toEntity()))
            .toList();

        if (page == 1) {
          await localDataSource.cacheArticles(category, hiveModels);
        }

        final articles = await _mergeBookmarkState(
          dtos.map((dto) => dto.toEntity()).toList(),
        );

        return Right(articles);
      } on Failure {
        return _getCachedArticles(category);
      } catch (e) {
        return Left(UnexpectedFailure(e.toString()));
      }
    } else {
      return _getCachedArticles(category);
    }
  }

  Future<Either<Failure, List<Article>>> _getCachedArticles(
      String category,
      ) async {
    try {
      final cached = await localDataSource.getCachedArticles(category);
      if (cached.isEmpty) {
        return const Left(CacheFailure('No cached articles available'));
      }
      final articles = await _mergeBookmarkState(
        cached.map((m) => m.toEntity()).toList(),
      );
      return Right(articles);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<List<Article>> _mergeBookmarkState(List<Article> articles) async {
    final result = <Article>[];
    for (final article in articles) {
      final bookmarked = await localDataSource.isBookmarked(article.id);
      result.add(article.copyWith(isBookmarked: bookmarked));
    }
    return result;
  }

  @override
  Future<Either<Failure, List<Article>>> searchArticles({
    required String query,
    required int page,
    int pageSize = 20,
  }) async {
    final isOnline = await networkInfo.isConnected;
    if (!isOnline) {
      return const Left(NetworkFailure('Search requires an internet connection'));
    }

    try {
      final dtos = await remoteDataSource.searchArticles(
        query: query,
        page: page,
        pageSize: pageSize,
      );
      final articles = await _mergeBookmarkState(
        dtos.map((dto) => dto.toEntity()).toList(),
      );
      return Right(articles);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Article>>> getBookmarks() async {
    try {
      final hiveModels = await localDataSource.getBookmarks();
      final articles = hiveModels.map((m) => m.toEntity()).toList();
      return Right(articles);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleBookmark(Article article) async {
    try {
      final isBookmarked = await localDataSource.isBookmarked(article.id);
      if (isBookmarked) {
        await localDataSource.removeBookmark(article.id);
      } else {
        final hiveModel = ArticleHiveModel.fromEntity(article);
        await localDataSource.saveBookmark(hiveModel);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to toggle bookmark: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isBookmarked(String articleId) async {
    try {
      final result = await localDataSource.isBookmarked(articleId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
