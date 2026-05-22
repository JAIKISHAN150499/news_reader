import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader_app/core/errors/failures.dart';
import 'package:news_reader_app/features/news/domain/entities/article.dart';
import 'package:news_reader_app/features/news/domain/usecases/news_usecases.dart';
import 'package:news_reader_app/features/bookmarks/presentation/bloc/bookmarks_bloc.dart';

class MockGetBookmarks extends Mock implements GetBookmarks {}
class MockToggleBookmark extends Mock implements ToggleBookmark {}

void main() {
  late BookmarksBloc bloc;
  late MockGetBookmarks mockGetBookmarks;
  late MockToggleBookmark mockToggleBookmark;

  setUp(() {
    mockGetBookmarks = MockGetBookmarks();
    mockToggleBookmark = MockToggleBookmark();
    bloc = BookmarksBloc(
      getBookmarks: mockGetBookmarks,
      toggleBookmark: mockToggleBookmark,
    );
  });

  setUpAll(() {
    registerFallbackValue(Article(
      id: '1',
      title: 'Test',
      url: 'https://test.com',
    ));
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

  group('LoadBookmarksEvent', () {
    blocTest<BookmarksBloc, BookmarksState>(
      'should emit [BookmarksLoading, BookmarksLoaded] when data is gotten successfully',
      build: () {
        when(() => mockGetBookmarks()).thenAnswer((_) async => Right(tArticles));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadBookmarksEvent()),
      expect: () => [
        BookmarksLoading(),
        BookmarksLoaded(tArticles),
      ],
    );

    blocTest<BookmarksBloc, BookmarksState>(
      'should emit [BookmarksLoading, BookmarksError] when getting data fails',
      build: () {
        when(() => mockGetBookmarks()).thenAnswer((_) async => const Left(CacheFailure('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadBookmarksEvent()),
      expect: () => [
        BookmarksLoading(),
        const BookmarksError('Error'),
      ],
    );
   group('RemoveBookmarkEvent', () {
    final tArticle = tArticles[0];
    
    blocTest<BookmarksBloc, BookmarksState>(
      'should call toggleBookmark and then trigger LoadBookmarksEvent',
      build: () {
        when(() => mockToggleBookmark(any())).thenAnswer((_) async => const Right(null));
        when(() => mockGetBookmarks()).thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(RemoveBookmarkEvent(tArticle)),
      verify: (_) {
        verify(() => mockToggleBookmark(tArticle)).called(1);
      },
    );
  });
  });
}
