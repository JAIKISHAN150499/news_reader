import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader_app/core/network/dio_client.dart';
import 'package:news_reader_app/features/news/data/datasources/news_remote_datasource.dart';
import 'package:news_reader_app/features/news/data/models/article_dto.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late NewsRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUpAll(() async {
    await dotenv.load(
      mergeWith: {
        'GNEWS_MAX_PER_PAGE': '10',
      },
    );
  });



  setUp(() {
    mockDio = MockDio();
    mockDioClient = MockDioClient();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = NewsRemoteDataSourceImpl(dioClient: mockDioClient);
  });

  const tCategory = 'general';
  const tPage = 1;

  final tResponseData = {
    'articles': [
      {
        'title': 'Test Title',
        'description': 'Test Description',
        'url': 'https://test.com',
        'image': 'https://test.com/image.jpg',
        'publishedAt': '2023-01-01T00:00:00Z',
        'source': {'name': 'Test Source'}
      }
    ]
  };

  group('getTopHeadlines', () {
    test(
      'should perform a GET request on /top-headlines with correct parameters',
      () async {
        // arrange
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: tResponseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/top-headlines'),
            ));

        // act
        await dataSource.getTopHeadlines(category: tCategory, page: tPage);

        // assert
        verify(() => mockDio.get(
              '/top-headlines',
              queryParameters: {
                'category': tCategory,
                'lang': 'en',
                'country': 'us',
                'page': tPage,
                'max': 10,
              },
            ));
      },
    );

    test(
      'should return List<ArticleDto> when the response code is 200',
      () async {
        // arrange
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: tResponseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/top-headlines'),
            ));

        // act
        final result = await dataSource.getTopHeadlines(category: tCategory, page: tPage);

        // assert
        expect(result, isA<List<ArticleDto>>());
        expect(result.length, 1);
        expect(result[0].title, 'Test Title');
      },
    );
  });
}
