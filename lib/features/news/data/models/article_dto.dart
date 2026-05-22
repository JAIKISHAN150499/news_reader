
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/article.dart';

part 'article_dto.g.dart';

@JsonSerializable()
class ArticleDto {
  final String? id;
  final String? title;
  final String? description;
  final String? content;
  final String? url;
  final String? image;
  final String? publishedAt;
  final SourceDto? source;

  const ArticleDto({
    this.id,
    this.title,
    this.description,
    this.content,
    this.url,
    this.image,
    this.publishedAt,
    this.source,
  });

  factory ArticleDto.fromJson(Map<String, dynamic> json) =>
      _$ArticleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleDtoToJson(this);

  Article toEntity() {
    return Article(
      id: id ?? url ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'No Title',
      author: null,
      description: description,
      content: content,
      url: url ?? '',
      imageUrl: image,
      sourceName: source?.name,
      publishedAt: publishedAt != null ? DateTime.tryParse(publishedAt!) : null,
      isBookmarked: false,
    );
  }
}

@JsonSerializable()
class SourceDto {
  final String? id;
  final String? name;
  final String? url;

  const SourceDto({this.id, this.name, this.url});

  factory SourceDto.fromJson(Map<String, dynamic> json) =>
      _$SourceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SourceDtoToJson(this);
}

@JsonSerializable()
class NewsApiResponseDto {
  final int? totalArticles;
  final List<ArticleDto>? articles;

  const NewsApiResponseDto({this.totalArticles, this.articles});

  factory NewsApiResponseDto.fromJson(Map<String, dynamic> json) =>
      _$NewsApiResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$NewsApiResponseDtoToJson(this);
}
