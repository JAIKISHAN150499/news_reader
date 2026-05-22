import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader_app/core/errors/failures.dart';
import 'package:news_reader_app/features/news/domain/entities/article.dart';
import 'package:news_reader_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_reader_app/features/news/domain/usecases/search_articles.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  late SearchArticles usecase;
  late MockNewsRepository mockNewsRepository;

  setUp(() {
    mockNewsRepository = MockNewsRepository();
    usecase = SearchArticles(mockNewsRepository);
  });

  final tArticles = [
    Article(
      id: '1',
      title: 'Test Title',
      url: 'https://test.com',
      sourceName: 'Test Source',
      publishedAt: DateTime.now(),
    ),
  ];

  const tQuery = 'flutter';
  const tPage = 1;
  const tParams = SearchParams(query: tQuery, page: tPage);

  test(
    'should get articles for the query from the repository',
    () async {
      // arrange
      when(() => mockNewsRepository.searchArticles(
            query: any(named: 'query'),
            page: any(named: 'page'),
          )).thenAnswer((_) async => Right(tArticles));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tArticles));
      verify(() => mockNewsRepository.searchArticles(
            query: tQuery,
            page: tPage,
          ));
      verifyNoMoreInteractions(mockNewsRepository);
    },
  );

  test(
    'should return failure when the repository call is unsuccessful',
    () async {
      // arrange
      const tFailure = ServerFailure('Server Error');
      when(() => mockNewsRepository.searchArticles(
            query: any(named: 'query'),
            page: any(named: 'page'),
          )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockNewsRepository.searchArticles(
            query: tQuery,
            page: tPage,
          ));
      verifyNoMoreInteractions(mockNewsRepository);
    },
  );
}
