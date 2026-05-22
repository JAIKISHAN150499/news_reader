import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader_app/core/errors/failures.dart';
import 'package:news_reader_app/features/news/domain/entities/article.dart';
import 'package:news_reader_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_reader_app/features/news/domain/usecases/toggle_bookmark.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  late ToggleBookmark usecase;
  late MockNewsRepository mockNewsRepository;

  setUpAll(() {
    registerFallbackValue(Article(
      id: 'fallback',
      title: 'fallback',
      url: 'fallback',
    ));
  });

  setUp(() {
    mockNewsRepository = MockNewsRepository();
    usecase = ToggleBookmark(mockNewsRepository);
  });

  final tArticle = Article(
    id: '1',
    title: 'Test Title',
    url: 'https://test.com',
    sourceName: 'Test Source',
    publishedAt: DateTime.now(),
    isBookmarked: false,
  );

  test(
    'should call the repository to toggle bookmark',
    () async {
      // arrange
      when(() => mockNewsRepository.toggleBookmark(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tArticle);

      // assert
      expect(result, const Right(null));
      verify(() => mockNewsRepository.toggleBookmark(tArticle));
      verifyNoMoreInteractions(mockNewsRepository);
    },
  );

  test(
    'should return a failure when the repository call fails',
    () async {
      // arrange
      when(() => mockNewsRepository.toggleBookmark(any()))
          .thenAnswer((_) async => const Left(CacheFailure('Storage Error')));

      // act
      final result = await usecase(tArticle);

      // assert
      expect(result, const Left(CacheFailure('Storage Error')));
      verify(() => mockNewsRepository.toggleBookmark(tArticle));
    },
  );
}
