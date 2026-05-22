import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/news/data/models/article_hive_model.dart';
import 'features/news/presentation/bloc/news_bloc.dart';
import 'features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'features/search/bloc/search_bloc.dart';
import 'features/settings/bloc/theme_bloc.dart';
import 'injection/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ArticleHiveModelAdapter());
  }

  // Open Boxes using AppConstants
  // IMPORTANT: Standardizing names to prevent "Box not found" errors
  await Hive.openBox(AppConstants.newsCacheBox); 
  await Hive.openBox<ArticleHiveModel>(AppConstants.bookmarksBox);
  await Hive.openBox(AppConstants.settingsBox);

  // Initialize Dependency Injection
  await di.init();

  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (_) => di.sl<ThemeBloc>()..add(ThemeLoadEvent()),
        ),
        BlocProvider<BookmarksBloc>(
          create: (_) => di.sl<BookmarksBloc>()..add(LoadBookmarksEvent()),
        ),
        BlocProvider<NewsBloc>(
          create: (_) => di.sl<NewsBloc>(),
        ),
        BlocProvider<SearchBloc>(
          create: (_) => di.sl<SearchBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'News Reader',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
