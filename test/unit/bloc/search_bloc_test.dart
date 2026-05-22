import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader_app/core/errors/failures.dart';
import 'package:news_reader_app/features/news/domain/entities/article.dart';
import 'package:news_reader_app/features/news/domain/usecases/news_usecases.dart';
import 'package:news_reader_app/features/search/bloc/search_bloc.dart';

class MockSearchArticles extends Mock implements SearchArticles {}

void main() {
  late SearchBloc bloc;
  late MockSearchArticles mockSearchArticles;

  setUp(() {
    mockSearchArticles = MockSearchArticles();
    bloc = SearchBloc(searchArticles: mockSearchArticles);
  });

  setUpAll(() {
    registerFallbackValue(const SearchParams(query: ''));
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

  const tQuery = 'flutter';

  test('initial state should be SearchInitial', () {
    expect(bloc.state, SearchInitial());
  });

  blocTest<SearchBloc, SearchState>(
    'should emit [SearchLoading, SearchLoaded] when data is gotten successfully',
    build: () {
      when(() => mockSearchArticles(any()))
          .thenAnswer((_) async => Right(tArticles));
      return bloc;
    },
    act: (bloc) => bloc.add(SearchQueryChanged(query: tQuery)),
    wait: const Duration(milliseconds: 500), // Account for debounce
    expect: () => [
      SearchLoading(),
      SearchLoaded(results: tArticles, query: tQuery),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'should emit [SearchLoading, SearchEmpty] when an empty list is returned',
    build: () {
      when(() => mockSearchArticles(any()))
          .thenAnswer((_) async => const Right([]));
      return bloc;
    },
    act: (bloc) => bloc.add(SearchQueryChanged(query: tQuery)),
    wait: const Duration(milliseconds: 500),
    expect: () => [
      SearchLoading(),
      SearchEmpty(query: tQuery),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'should emit [SearchLoading, SearchError] when getting data fails',
    build: () {
      when(() => mockSearchArticles(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Server Error')));
      return bloc;
    },
    act: (bloc) => bloc.add(SearchQueryChanged(query: tQuery)),
    wait: const Duration(milliseconds: 500),
    expect: () => [
      SearchLoading(),
      const SearchError(message: 'Server Error'),
    ],
  );
}
