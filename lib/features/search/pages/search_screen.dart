import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/search_bloc.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../core/widgets/news_card.dart';
import '../../news/presentation/bloc/news_bloc.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            if (query.length > 2) {
              context.read<SearchBloc>().add(SearchQueryChanged(query: query));
            }
          },
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerCard(),
            );
          } else if (state is SearchLoaded) {
            if (state.results.isEmpty) {
              return const Center(child: Text('No results found.'));
            }
            return ListView.builder(
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final article = state.results[index];
                return NewsCard(
                  article: article,
                  onTap: () => context.push('/article', extra: article),
                  onBookmarkTap: () {
                    context.read<NewsBloc>().add(ToggleBookmarkEvent(article: article));
                  },
                );
              },
            );
          } else if (state is SearchEmpty) {
            return Center(child: Text('No results for "${state.query}"'));
          } else if (state is SearchError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                // Implement retry if needed
              },
            );
          }
          return const Center(child: Text('Start searching for news!'));
        },
      ),
    );
  }
}
