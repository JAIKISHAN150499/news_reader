import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../features/news/domain/entities/article.dart';
import '../../core/services/image_cache_manager.dart';
import '../../core/utils/read_time_estimator.dart';
import '../../core/theme/news_theme_extension.dart';

class NewsCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<NewsThemeExtension>()!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ext.cardRadius),
      ),
      elevation: ext.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ext.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ext.cardRadius),
                ),
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  cacheManager: NewsImageCacheManager.instance,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, error) => Container(
                    height: 180,
                    color: ext.shimmerBaseColor,
                  ),
                  errorWidget: (context, error, stackTrace) => Container(
                    height: 120,
                    color: ext.shimmerBaseColor,
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (article.sourceName != null) ...[
                        Expanded(
                          child: Text(
                            article.sourceName!.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                              color: ext.brandPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ext.brandPrimary.withValues(alpha:0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ReadTimeEstimator.estimate(article.content),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                            color: ext.brandPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // ── ARTICLE TITLE ──────────────────────────────
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      article.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha:0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (article.publishedAt != null)
                        Text(
                          _formatDate(article.publishedAt!),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha:0.5),
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          article.isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: article.isBookmarked ? ext.brandPrimary : null,
                        ),
                        onPressed: onBookmarkTap,
                        tooltip: article.isBookmarked
                            ? 'Remove bookmark'
                            : 'Bookmark article',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}