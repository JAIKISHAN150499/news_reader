import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader_app/features/news/domain/entities/article.dart';
import 'package:news_reader_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_reader_app/features/news/domain/usecases/get_top_headlines.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  late GetTopHeadlines usecase;
  late MockNewsRepository mockNewsRepository;

  setUp(() {
    mockNewsRepository = MockNewsRepository();
    usecase = GetTopHeadlines(mockNewsRepository);
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

  const tCategory = 'general';
  const tPage = 1;
  const tParams = TopHeadlineParams(category: tCategory, page: tPage);

  test(
    'should get top headlines from the repository',
    () async {
      // arrange
      when(() => mockNewsRepository.getTopHeadlines(
            category: any(named: 'category'),
            page: any(named: 'page'),
          )).thenAnswer((_) async => Right(tArticles));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tArticles));
      verify(() => mockNewsRepository.getTopHeadlines(
            category: tCategory,
            page: tPage,
          ));
      verifyNoMoreInteractions(mockNewsRepository);
    },
  );
}
