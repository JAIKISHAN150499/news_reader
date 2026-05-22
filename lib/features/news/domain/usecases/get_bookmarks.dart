import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/news_repository.dart';

class GetBookmarks {
  final NewsRepository repository;
  GetBookmarks(this.repository);

  Future<Either<Failure, List<Article>>> call() {
    return repository.getBookmarks();
  }
}
