import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/article.dart';
import '../../../../core/utils/date_formatter.dart';
import '../bloc/news_bloc.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.sourceName ?? 'Article'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.share),
        //     onPressed: () {
        //       // TODO: Implement share
        //     },
        //   ),
        //   IconButton(
        //     icon: Icon(
        //       article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        //     ),
        //     onPressed: () {
        //       // TODO: Implement bookmark toggle
        //     },
        //   ),
        // ],
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Article',
            onPressed: () async {
              // await Share.share(
              //   '${article.title}\n\n${article.url}',
              //   subject: article.title,
              // );
              await SharePlus.instance.share(
                ShareParams(
                  text: article.url,
                ),
              );
            },
          ),

          BlocBuilder<NewsBloc, NewsState>(
            builder: (context, state) {
              bool isBookmarked = article.isBookmarked;

              if (state is NewsLoaded) {
                final updatedArticle = state.articles
                    .where((a) => a.id == article.id)
                    .cast<Article?>()
                    .firstOrNull;

                if (updatedArticle != null) {
                  isBookmarked = updatedArticle.isBookmarked;
                }
              }

              return IconButton(
                tooltip: isBookmarked
                    ? 'Remove Bookmark'
                    : 'Add Bookmark',
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                onPressed: () {
                  context.read<NewsBloc>().add(
                    ToggleBookmarkEvent(
                      article: article,
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBookmarked
                            ? 'Removed from bookmarks'
                            : 'Added to bookmarks',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              CachedNetworkImage(
                imageUrl: article.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[300]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.author ?? article.sourceName ?? 'Unknown',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (article.publishedAt != null)
                        Text(
                          DateFormatter.formatShortDate(article.publishedAt!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const Divider(height: 32),
                  if (article.description != null) ...[
                    Text(
                      article.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (article.content != null)
                    Text(
                      article.content!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final uri = Uri.parse(article.url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      child: const Text('Read Full Article'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
