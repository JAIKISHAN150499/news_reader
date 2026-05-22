import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../../core/widgets/news_card.dart';
import '../bloc/bookmarks_bloc.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookmarksBloc>().add(LoadBookmarksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Articles'),
      ),
      body: BlocBuilder<BookmarksBloc, BookmarksState>(
        builder: (context, state) {
          if (state is BookmarksLoading) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerCard(),
            );
          } else if (state is BookmarksLoaded) {
            if (state.articles.isEmpty) {
              return const Center(
                child: Text('No bookmarked articles yet.'),
              );
            }
            return ListView.builder(
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                final article = state.articles[index];
                return NewsCard(
                  article: article,
                  onTap: () => context.push('/article', extra: article),
                  onBookmarkTap: () {
                    context.read<BookmarksBloc>().add(RemoveBookmarkEvent(article));
                  },
                );
              },
            );
          } else if (state is BookmarksError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<BookmarksBloc>().add(LoadBookmarksEvent());
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
