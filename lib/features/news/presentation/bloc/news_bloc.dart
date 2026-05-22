import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/article.dart';
import '../../domain/usecases/news_usecases.dart';
import '../../../../core/constants/app_constants.dart';

abstract class NewsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNewsEvent extends NewsEvent {
  final String category;
  LoadNewsEvent({required this.category});
  @override
  List<Object> get props => [category];
}

class RefreshNewsEvent extends NewsEvent {
  final String category;
  RefreshNewsEvent({required this.category});
  @override
  List<Object> get props => [category];
}

class LoadMoreNewsEvent extends NewsEvent {
  final String category;
  LoadMoreNewsEvent({required this.category});
  @override
  List<Object> get props => [category];
}

class ToggleBookmarkEvent extends NewsEvent {
  final Article article;
  ToggleBookmarkEvent({required this.article});
  @override
  List<Object> get props => [article];
}

abstract class NewsState extends Equatable {
  const NewsState();
  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {
  const NewsInitial();
}

class NewsLoading extends NewsState {
  const NewsLoading();
}

class NewsRefreshing extends NewsState {
  final List<Article> currentArticles;
  const NewsRefreshing({required this.currentArticles});
  @override
  List<Object> get props => [currentArticles];
}

class NewsLoaded extends NewsState {
  final List<Article> articles;
  final bool hasMore;
  final bool isOnline;
  final bool isLoadingMore;

  const NewsLoaded({
    required this.articles,
    this.hasMore = true,
    this.isOnline = true,
    this.isLoadingMore = false,
  });

  NewsLoaded copyWith({
    List<Article>? articles,
    bool? hasMore,
    bool? isOnline,
    bool? isLoadingMore,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasMore: hasMore ?? this.hasMore,
      isOnline: isOnline ?? this.isOnline,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [articles, hasMore, isOnline, isLoadingMore];
}

class NewsError extends NewsState {
  final String message;
  final bool hasCachedData;
  const NewsError({required this.message, this.hasCachedData = false});
  @override
  List<Object> get props => [message, hasCachedData];
}

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetTopHeadlines getTopHeadlines;
  final ToggleBookmark toggleBookmark;

  int _currentPage = 1;
  String _currentCategory = 'general';

  NewsBloc({
    required this.getTopHeadlines,
    required this.toggleBookmark,
  }) : super(const NewsInitial()) {
    on<LoadNewsEvent>(_onLoadNews);
    on<RefreshNewsEvent>(_onRefresh);
    on<LoadMoreNewsEvent>(_onLoadMore);
    on<ToggleBookmarkEvent>(_onToggleBookmark);
  }

  Future<void> _onLoadNews(LoadNewsEvent event, Emitter<NewsState> emit) async {
    _currentPage = 1;
    _currentCategory = event.category;
    emit(const NewsLoading());

    final result = await getTopHeadlines(
      TopHeadlineParams(category: event.category, page: 1),
    );

    result.fold(
      (failure) => emit(NewsError(message: failure.message)),
      (articles) => emit(NewsLoaded(
        articles: articles,
        hasMore: articles.isNotEmpty,
        isOnline: true,
      )),
    );
  }

  Future<void> _onRefresh(RefreshNewsEvent event, Emitter<NewsState> emit) async {
    final currentState = state;
    if (currentState is NewsLoaded) {
      emit(NewsRefreshing(currentArticles: currentState.articles));
    }

    _currentPage = 1;
    final result = await getTopHeadlines(
      TopHeadlineParams(category: event.category, page: 1),
    );

    result.fold(
      (failure) {
        if (currentState is NewsLoaded) emit(currentState);
        emit(NewsError(message: failure.message, hasCachedData: true));
      },
      (articles) => emit(NewsLoaded(
        articles: articles,
        hasMore: articles.isNotEmpty,
      )),
    );
  }

  Future<void> _onLoadMore(LoadMoreNewsEvent event, Emitter<NewsState> emit) async {
    final currentState = state;
    if (currentState is! NewsLoaded || !currentState.hasMore || currentState.isLoadingMore) return;

    final nextPage = _currentPage + 1;
    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getTopHeadlines(
      TopHeadlineParams(category: _currentCategory, page: nextPage),
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (newArticles) {
        if (newArticles.isEmpty) {
          emit(currentState.copyWith(isLoadingMore: false, hasMore: false));
        } else {
          _currentPage = nextPage;
          emit(NewsLoaded(
            articles: [...currentState.articles, ...newArticles],
            hasMore: newArticles.length >= (AppConstants.pageSize / 2),
            isOnline: currentState.isOnline,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkEvent event,
    Emitter<NewsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NewsLoaded) return;

    final updatedArticles = currentState.articles.map((a) {
      if (a.id == event.article.id) {
        return a.copyWith(isBookmarked: !a.isBookmarked);
      }
      return a;
    }).toList();
    emit(currentState.copyWith(articles: updatedArticles));

    final result = await toggleBookmark(event.article);
    result.fold(
      (failure) => emit(currentState),
      (_) => null,
    );
  }
}
