

import 'package:hive/hive.dart';
import '../../../news/domain/entities/article.dart';

part 'article_hive_model.g.dart';

@HiveType(typeId: 0)
class ArticleHiveModel extends HiveObject {
  @HiveField(0)
  String id = '';

  @HiveField(1)
  String title = '';

  @HiveField(2)
  String? author;

  @HiveField(3)
  String? description;

  @HiveField(4)
  String? content;

  @HiveField(5)
  String url = '';

  @HiveField(6)
  String? imageUrl;

  @HiveField(7)
  String? sourceName;

  @HiveField(8)
  DateTime? publishedAt;

  @HiveField(9)
  bool isBookmarked;

  ArticleHiveModel()
      : isBookmarked = false;

  factory ArticleHiveModel.fromEntity(Article article) {
    return ArticleHiveModel()
      ..id = article.id
      ..title = article.title
      ..author = article.author
      ..description = article.description
      ..content = article.content
      ..url = article.url
      ..imageUrl = article.imageUrl
      ..sourceName = article.sourceName
      ..publishedAt = article.publishedAt
      ..isBookmarked = article.isBookmarked;
  }

  Article toEntity() {
    return Article(
      id: id,
      title: title,
      author: author,
      description: description,
      content: content,
      url: url,
      imageUrl: imageUrl,
      sourceName: sourceName,
      publishedAt: publishedAt,
      isBookmarked: isBookmarked,
    );
  }
}