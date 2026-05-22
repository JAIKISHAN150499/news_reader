import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String id;
  final String title;
  final String? author;
  final String? description;
  final String? content;
  final String url;
  final String? imageUrl;
  final String? sourceName;
  final DateTime? publishedAt;
  final bool isBookmarked;

  const Article({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.content,
    required this.url,
    this.imageUrl,
    this.sourceName,
    this.publishedAt,
    this.isBookmarked = false,
  });

  Article copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? content,
    String? url,
    String? imageUrl,
    String? sourceName,
    DateTime? publishedAt,
    bool? isBookmarked,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceName: sourceName ?? this.sourceName,
      publishedAt: publishedAt ?? this.publishedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  List<Object?> get props => [id, url, title, isBookmarked];

  @override
  String toString() => 'Article(title: $title, url: $url)';
}
