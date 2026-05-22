import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/pages/splash_screen.dart';
import '../../features/news/presentation/pages/home_screen.dart';
import '../../features/news/presentation/pages/article_detail_screen.dart';
import '../../features/bookmarks/presentation/pages/bookmarks_screen.dart';
import '../../features/search/pages/search_screen.dart';
import '../../features/settings/pages/settings_screen.dart';
import '../../features/news/domain/entities/article.dart';

class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String home = '/home';
  static const String articleDetail = '/article';
  static const String bookmarks = '/bookmarks';
  static const String search = '/search';
  static const String settings = '/settings';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.articleDetail,
        name: 'article-detail',
        builder: (context, state) {
          final article = state.extra as Article;
          return ArticleDetailScreen(article: article);
        },
      ),
      GoRoute(
        path: AppRoutes.bookmarks,
        name: 'bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: ${state.error}'),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
