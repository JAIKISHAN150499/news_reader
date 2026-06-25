// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleDto _$ArticleDtoFromJson(Map<String, dynamic> json) => ArticleDto(
  id: json['id'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  content: json['content'] as String?,
  url: json['url'] as String?,
  image: json['image'] as String?,
  publishedAt: json['publishedAt'] as String?,
  source: json['source'] == null
      ? null
      : SourceDto.fromJson(json['source'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ArticleDtoToJson(ArticleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'content': instance.content,
      'url': instance.url,
      'image': instance.image,
      'publishedAt': instance.publishedAt,
      'source': instance.source,
    };

SourceDto _$SourceDtoFromJson(Map<String, dynamic> json) => SourceDto(
  id: json['id'] as String?,
  name: json['name'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$SourceDtoToJson(SourceDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
};

NewsApiResponseDto _$NewsApiResponseDtoFromJson(Map<String, dynamic> json) =>
    NewsApiResponseDto(
      totalArticles: (json['totalArticles'] as num?)?.toInt(),
      articles: (json['articles'] as List<dynamic>?)
          ?.map((e) => ArticleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NewsApiResponseDtoToJson(NewsApiResponseDto instance) =>
    <String, dynamic>{
      'totalArticles': instance.totalArticles,
      'articles': instance.articles,
    };
