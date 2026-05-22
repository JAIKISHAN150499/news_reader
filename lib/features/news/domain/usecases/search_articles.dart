import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/news_repository.dart';

class SearchArticles {
  final NewsRepository repository;

  SearchArticles(this.repository);

  Future<Either<Failure, List<Article>>> call(SearchParams params) async {
    return await repository.searchArticles(
      query: params.query,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class SearchParams extends Equatable {
  final String query;
  final int page;
  final int pageSize;

  const SearchParams({
    required this.query,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [query, page, pageSize];
}
