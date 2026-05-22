import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/news_repository.dart';

class ToggleBookmark {
  final NewsRepository repository;
  ToggleBookmark(this.repository);

  Future<Either<Failure, void>> call(Article article) {
    return repository.toggleBookmark(article);
  }
}
