import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/animated_news_ticker.dart';
import '../../../../core/widgets/news_card.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../injection/injection_container.dart' as di;
import '../../domain/entities/article.dart';
import '../bloc/news_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late NewsBloc _newsBloc;

  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _newsBloc = di.sl<NewsBloc>();

    _tabController = TabController(
      length: AppConstants.newsCategories.length,
      vsync: this,
    );

    _scrollController = ScrollController();

    // Initial Load: Page 1
    _newsBloc.add(LoadNewsEvent(
      category: AppConstants.newsCategories[0],
    ));

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_currentTabIndex == _tabController.index) return;
      _currentTabIndex = _tabController.index;
      _newsBloc.add(LoadNewsEvent(
        category: AppConstants.newsCategories[_currentTabIndex],
      ));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _newsBloc,
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'NewsReader',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                background: BlocBuilder<NewsBloc, NewsState>(
                  builder: (context, state) {
                    final imageUrl = state is NewsLoaded &&
                        state.articles.isNotEmpty
                        ? state.articles.first.imageUrl
                        : null;
                    return _HeroParallaxImage(imageUrl: imageUrl);
                  },
                ),
                collapseMode: CollapseMode.parallax,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.push(AppRoutes.search),
                  tooltip: 'Search',
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_outline),
                  onPressed: () => context.push(AppRoutes.bookmarks),
                  tooltip: 'Bookmarks',
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push(AppRoutes.settings),
                  tooltip: 'Settings',
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: AppConstants.categoryLabels
                    .map((label) => Tab(text: label))
                    .toList(),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<NewsBloc, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoaded && state.articles.isNotEmpty) {
                    return AnimatedNewsTicker(
                      headlines: state.articles
                          .take(5)
                          .map((a) => a.title)
                          .toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
          body: BlocConsumer<NewsBloc, NewsState>(
            listener: (context, state) {
              if (state is NewsError && state.hasCachedData) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  if (state is NewsLoaded && !state.isOnline)
                    const OfflineBanner(),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        // DETECT BOTTOM: Trigger load-more when 200px from the bottom
                        if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200 &&
                            state is NewsLoaded &&
                            !state.isLoadingMore &&
                            state.hasMore) {
                          _newsBloc.add(LoadMoreNewsEvent(
                            category: AppConstants.newsCategories[_currentTabIndex],
                          ));
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _newsBloc.add(RefreshNewsEvent(
                            category:
                            AppConstants.newsCategories[_currentTabIndex],
                          ));
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: _buildBody(state),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(NewsState state) {
    if (state is NewsLoading) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, error) => const ShimmerCard(),
      );
    }

    if (state is NewsRefreshing) {
      return ListView.builder(
        itemCount: state.currentArticles.length,
        itemBuilder: (_, i) => NewsCard(
          article: state.currentArticles[i],
          onTap: () => _openDetail(state.currentArticles[i]),
          onBookmarkTap: () => _newsBloc.add(
            ToggleBookmarkEvent(article: state.currentArticles[i]),
          ),
        ),
      );
    }

    if (state is NewsLoaded) {
      if (state.articles.isEmpty) {
        return const Center(child: Text('No articles found.'));
      }
      return ListView.builder(
        itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Bottom Loader
          if (index == state.articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final article = state.articles[index];
          return RepaintBoundary(
            child: NewsCard(
              article: article,
              onTap: () => _openDetail(article),
              onBookmarkTap: () => _newsBloc.add(
                ToggleBookmarkEvent(article: article),
              ),
            ),
          );
        },
      );
    }

    if (state is NewsError && !state.hasCachedData) {
      return _ErrorView(
        message: state.message,
        onRetry: () => _newsBloc.add(
          LoadNewsEvent(
            category: AppConstants.newsCategories[_currentTabIndex],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _openDetail(Article article) {
    context.push(
      AppRoutes.articleDetail,
      extra: article,
    );
  }
}

class _HeroParallaxImage extends StatelessWidget {
  final String? imageUrl;
  const _HeroParallaxImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null)
          Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _placeholder(context),
          )
        else
          _placeholder(context),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha:0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Icon(Icons.newspaper_rounded, size: 64),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
