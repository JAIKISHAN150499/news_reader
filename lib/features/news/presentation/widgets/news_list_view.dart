import 'package:flutter/material.dart';
import '../../../../core/widgets/news_card.dart';
import '../../domain/entities/article.dart';

class NewsListView extends StatelessWidget {
  final List<Article> articles;
  final VoidCallback? onRefresh;

  const NewsListView({
    super.key,
    required this.articles,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh!(),
        child: _buildList(),
      );
    }
    return _buildList();
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return NewsCard(article: articles[index],onTap: () {

        },
        onBookmarkTap: () {},
        );
      },
    );
  }
}
