// features/news/domain/repositories/news_repository.dart
//
// WHY abstract (interface)?
//   Domain layer defines WHAT the repository can do.
//   Data layer defines HOW it actually does it.
//
//   This is the Dependency Inversion Principle:
//   High-level modules (Domain) should not depend on
//   low-level modules (Data). Both depend on abstractions.
//
//   In tests: inject FakeNewsRepository (returns mock data)
//   In production: inject NewsRepositoryImpl (real API + Hive)
//
// WHY Either<Failure, T>?
//   Forces callers to handle errors. You cannot use the result
//   without checking if it's a Failure first. No forgotten try/catch.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/article.dart';

abstract class NewsRepository {
  /// Fetches top headlines for a given category and page.
  /// Returns cached data if offline.
  Future<Either<Failure, List<Article>>> getTopHeadlines({
    required String category,
    required int page,
    int pageSize = 20,
  });

  Future<Either<Failure, List<Article>>> searchArticles({
    required String query,
    required int page,
    int pageSize = 20,
  });

  Future<Either<Failure, List<Article>>> getBookmarks();

  Future<Either<Failure, void>> toggleBookmark(Article article);

  Future<Either<Failure, bool>> isBookmarked(String articleId);
}