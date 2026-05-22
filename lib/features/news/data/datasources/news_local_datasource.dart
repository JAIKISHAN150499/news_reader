import 'package:hive/hive.dart';
import '../models/article_hive_model.dart';

abstract class NewsLocalDataSource {
  Future<List<ArticleHiveModel>> getCachedArticles(String category);
  Future<void> cacheArticles(String category, List<ArticleHiveModel> articles);
  Future<List<ArticleHiveModel>> getBookmarks();
  Future<void> saveBookmark(ArticleHiveModel article);
  Future<void> removeBookmark(String articleId);
  Future<bool> isBookmarked(String articleId);
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final Box newsBox;
  final Box<ArticleHiveModel> bookmarkBox;

  NewsLocalDataSourceImpl({
    required this.newsBox,
    required this.bookmarkBox,
  });

  @override
  Future<void> cacheArticles(String category, List<ArticleHiveModel> articles) async {
    await newsBox.put(category, articles);
  }

  @override
  Future<List<ArticleHiveModel>> getCachedArticles(String category) async {
    final cached = newsBox.get(category);
    if (cached is List) {
      return List<ArticleHiveModel>.from(cached);
    }
    return [];
  }

  @override
  Future<List<ArticleHiveModel>> getBookmarks() async {
    return bookmarkBox.values.toList();
  }

  @override
  Future<void> saveBookmark(ArticleHiveModel article) async {
    await bookmarkBox.put(article.id, article);
  }

  @override
  Future<void> removeBookmark(String articleId) async {
    await bookmarkBox.delete(articleId);
  }

  @override
  Future<bool> isBookmarked(String articleId) async {
    return bookmarkBox.containsKey(articleId);
  }
}
