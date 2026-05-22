import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/news_repository.dart';

class GetTopHeadlines {
  final NewsRepository repository;
  GetTopHeadlines(this.repository);

  Future<Either<Failure, List<Article>>> call(TopHeadlineParams params) {
    return repository.getTopHeadlines(
      category: params.category,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class TopHeadlineParams extends Equatable {
  final String category;
  final int page;
  final int pageSize;

  const TopHeadlineParams({
    required this.category,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object> get props => [category, page, pageSize];
}
