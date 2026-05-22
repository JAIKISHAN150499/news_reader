import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader_app/core/network/network_info.dart';
import 'package:news_reader_app/features/news/data/datasources/news_local_datasource.dart';
import 'package:news_reader_app/features/news/data/datasources/news_remote_datasource.dart';
import 'package:news_reader_app/features/news/data/models/article_dto.dart';
import 'package:news_reader_app/features/news/data/models/article_hive_model.dart';
import 'package:news_reader_app/features/news/data/repositories/news_repository_impl.dart';

class MockRemoteDataSource extends Mock implements NewsRemoteDataSource {}
class MockLocalDataSource extends Mock implements NewsLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NewsRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NewsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tCategory = 'general';
  const tPage = 1;

  final tArticleDto = ArticleDto(
    title: 'Test Title',
    url: 'https://test.com',
    image: 'https://test.com/image.jpg',
    publishedAt: '2023-01-01T00:00:00Z',
    source: const SourceDto(name: 'Test Source'),
  );

  final tArticle = tArticleDto.toEntity();
  final tArticles = [tArticle];
  final tArticleDtos = [tArticleDto];
  final tHiveModels = [ArticleHiveModel.fromEntity(tArticle)];

  group('getTopHeadlines', () {
    test('should check if the device is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getTopHeadlines(
            category: any(named: 'category'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => tArticleDtos);
      when(() => mockLocalDataSource.isBookmarked(any())).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.cacheArticles(any(), any())).thenAnswer((_) async => {});

      // act
      await repository.getTopHeadlines(category: tCategory, page: tPage);

      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return remote data and cache it when successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getTopHeadlines(
              category: tCategory,
              page: tPage,
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => tArticleDtos);
        when(() => mockLocalDataSource.isBookmarked(any())).thenAnswer((_) async => false);
        when(() => mockLocalDataSource.cacheArticles(any(), any())).thenAnswer((_) async => {});

        // act
        final result = await repository.getTopHeadlines(category: tCategory, page: tPage);

        // assert
        verify(() => mockRemoteDataSource.getTopHeadlines(
              category: tCategory,
              page: tPage,
              pageSize: any(named: 'pageSize'),
            ));
        
        // Use fold for type-safe comparison
        result.fold(
          (failure) => fail('Should not return failure'),
          (articles) => expect(articles, tArticles),
        );
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return cached data when present', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedArticles(tCategory)).thenAnswer((_) async => tHiveModels);
        when(() => mockLocalDataSource.isBookmarked(any())).thenAnswer((_) async => false);

        // act
        final result = await repository.getTopHeadlines(category: tCategory, page: tPage);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getCachedArticles(tCategory));
        
        result.fold(
          (failure) => fail('Should not return failure'),
          (articles) => expect(articles, tArticles),
        );
      });
    });
  });
}
