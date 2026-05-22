import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../core/constants/app_constants.dart';
import '../features/news/data/datasources/news_remote_datasource.dart';
import '../features/news/data/datasources/news_local_datasource.dart';
import '../features/news/data/repositories/news_repository_impl.dart';
import '../features/news/domain/repositories/news_repository.dart';
import '../features/news/domain/usecases/news_usecases.dart';
import '../features/news/presentation/bloc/news_bloc.dart';
import '../features/search/bloc/search_bloc.dart';
import '../features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import '../features/settings/bloc/theme_bloc.dart';
import '../features/news/data/models/article_hive_model.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── EXTERNAL ───────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());

  // ── HIVE BOXES ─────────────────────────────────────────────
  // Register the already opened boxes into sl for safe injection
  sl.registerLazySingleton<Box>(
    () => Hive.box(AppConstants.newsCacheBox),
    instanceName: AppConstants.newsCacheBox,
  );
  sl.registerLazySingleton<Box<ArticleHiveModel>>(
    () => Hive.box<ArticleHiveModel>(AppConstants.bookmarksBox),
    instanceName: AppConstants.bookmarksBox,
  );

  // ── CORE ───────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => DioClient());

  // ── DATA SOURCES ───────────────────────────────────────────
  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(dioClient: sl()),
  );
  
  sl.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(
      newsBox: sl<Box>(instanceName: AppConstants.newsCacheBox),
      bookmarkBox: sl<Box<ArticleHiveModel>>(instanceName: AppConstants.bookmarksBox),
    ),
  );

  // ── REPOSITORY ─────────────────────────────────────────────
  sl.registerLazySingleton<NewsRepository>(() => NewsRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));

  // ── USE CASES ──────────────────────────────────────────────
  sl.registerLazySingleton(() => GetTopHeadlines(sl()));
  sl.registerLazySingleton(() => SearchArticles(sl()));
  sl.registerLazySingleton(() => ToggleBookmark(sl()));
  sl.registerLazySingleton(() => GetBookmarks(sl()));

  // ── BLOCS ──────────────────────────────────────────────────
  sl.registerFactory(() => NewsBloc(
        getTopHeadlines: sl(),
        toggleBookmark: sl(),
      ));
  sl.registerFactory(() => SearchBloc(searchArticles: sl()));
  sl.registerFactory(() => BookmarksBloc(
        getBookmarks: sl(),
        toggleBookmark: sl(),
      ));
  sl.registerFactory(() => ThemeBloc(prefs: sl()));
}
