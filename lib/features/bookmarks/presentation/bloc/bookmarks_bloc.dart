import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../news/domain/entities/article.dart';
import '../../../news/domain/usecases/news_usecases.dart';

abstract class BookmarksEvent extends Equatable {
  const BookmarksEvent();
  @override
  List<Object?> get props => [];
}

class LoadBookmarksEvent extends BookmarksEvent {
  const LoadBookmarksEvent();
}

class RemoveBookmarkEvent extends BookmarksEvent {
  final Article article;
  const RemoveBookmarkEvent(this.article);
  @override
  List<Object> get props => [article];
}

abstract class BookmarksState extends Equatable {
  const BookmarksState();
  @override
  List<Object?> get props => [];
}

class BookmarksInitial extends BookmarksState {
  const BookmarksInitial();
}

class BookmarksLoading extends BookmarksState {
  const BookmarksLoading();
}

class BookmarksLoaded extends BookmarksState {
  final List<Article> articles;
  const BookmarksLoaded(this.articles);
  @override
  List<Object> get props => [articles];
}

class BookmarksError extends BookmarksState {
  final String message;
  const BookmarksError(this.message);
  @override
  List<Object> get props => [message];
}

class BookmarksBloc extends Bloc<BookmarksEvent, BookmarksState> {
  final GetBookmarks getBookmarks;
  final ToggleBookmark toggleBookmark;

  BookmarksBloc({
    required this.getBookmarks,
    required this.toggleBookmark,
  }) : super(const BookmarksInitial()) {
    on<LoadBookmarksEvent>(_onLoadBookmarks);
    on<RemoveBookmarkEvent>(_onRemoveBookmark);
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarksEvent event,
    Emitter<BookmarksState> emit,
  ) async {
    emit(const BookmarksLoading());
    final result = await getBookmarks();
    result.fold(
      (failure) => emit(BookmarksError(failure.message)),
      (articles) => emit(BookmarksLoaded(articles)),
    );
  }

  Future<void> _onRemoveBookmark(
    RemoveBookmarkEvent event,
    Emitter<BookmarksState> emit,
  ) async {
    final result = await toggleBookmark(event.article);
    result.fold(
      (failure) => emit(BookmarksError(failure.message)),
      (_) => add(const LoadBookmarksEvent()),
    );
  }
}
