import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // Pagination - Read from .env
  static int get pageSize => int.parse(dotenv.env['GNEWS_MAX_PER_PAGE'] ?? '20');
  static const int initialPage = 1;

  // Search
  static const int searchDebounceMs = 300;
  static const int minSearchChars = 3;

  // Cache
  static const int cacheTtlDays = 7;
  static const int cacheMaxSizeMb = 100;

  // Hive box names
  static const String newsCacheBox = 'news_cache'; 
  static const String bookmarksBox = 'bookmarks';
  static const String settingsBox = 'settings';

  // SharedPreferences keys
  static const String themeModeKey = 'theme_mode';
  static const String fontSizeKey = 'font_size';

  // News categories for GNews
  static const List<String> newsCategories = [
    'general',
    'business',
    'sports',
    'technology',
    'health',
  ];

  static const List<String> categoryLabels = [
    'Top',
    'Business',
    'Sports',
    'Tech',
    'Health',
  ];
}
