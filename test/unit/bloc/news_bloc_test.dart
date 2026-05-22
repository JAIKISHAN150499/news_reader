import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader_app/core/errors/failures.dart';
import 'package:news_reader_app/features/news/domain/entities/article.dart';
import 'package:news_reader_app/features/news/domain/usecases/news_usecases.dart';
import 'package:news_reader_app/features/news/presentation/bloc/news_bloc.dart';

class MockGetTopHeadlines extends Mock implements GetTopHeadlines {}
class MockToggleBookmark extends Mock implements ToggleBookmark {}

void main() {
  late NewsBloc bloc;
  late MockGetTopHeadlines mockGetTopHeadlines;
  late MockToggleBookmark mockToggleBookmark;

  setUp(() {
    mockGetTopHeadlines = MockGetTopHeadlines();
    mockToggleBookmark = MockToggleBookmark();
    bloc = NewsBloc(
      getTopHeadlines: mockGetTopHeadlines,
      toggleBookmark: mockToggleBookmark,
    );
  });

  // Necessary for mocktail to handle custom objects in 'any()'
  setUpAll(() {
    registerFallbackValue(const TopHeadlineParams(category: 'general'));
    registerFallbackValue(Article(
      id: '1',
      title: 'Test',
      url: 'https://test.com',
    ));
  });

  tearDown(() {
    bloc.close();
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

  test('initial state should be NewsInitial', () {
    expect(bloc.state, NewsInitial());
  });

  group('LoadNewsEvent', () {
    blocTest<NewsBloc, NewsState>(
      'should emit [NewsLoading, NewsLoaded] when data is gotten successfully',
      build: () {
        when(() => mockGetTopHeadlines(any()))
            .thenAnswer((_) async => Right(tArticles));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadNewsEvent(category: tCategory)),
      expect: () => [
        NewsLoading(),
        isA<NewsLoaded>().having((s) => s.articles, 'articles', tArticles),
      ],
      verify: (_) {
        verify(() => mockGetTopHeadlines(const TopHeadlineParams(category: tCategory, page: 1))).called(1);
      },
    );

    blocTest<NewsBloc, NewsState>(
      'should emit [NewsLoading, NewsError] when getting data fails',
      build: () {
        when(() => mockGetTopHeadlines(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadNewsEvent(category: tCategory)),
      expect: () => [
        NewsLoading(),
        NewsError(message: 'Server error'),
      ],
    );
  });

  group('ToggleBookmarkEvent', () {
    final tArticle = tArticles[0];
    
    blocTest<NewsBloc, NewsState>(
      'should emit NewsLoaded with updated article (optimistic) and call use case',
      build: () {
        when(() => mockToggleBookmark(any()))
            .thenAnswer((_) async => const Right(null));
        // Pre-populate state with loaded articles
        return bloc;
      },
      seed: () => NewsLoaded(articles: [tArticle]),
      act: (bloc) => bloc.add(ToggleBookmarkEvent(article: tArticle)),
      expect: () => [
        isA<NewsLoaded>().having(
          (s) => s.articles[0].isBookmarked, 
          'isBookmarked', 
          true
        ),
      ],
      verify: (_) {
        verify(() => mockToggleBookmark(tArticle)).called(1);
      },
    );
  });
}
