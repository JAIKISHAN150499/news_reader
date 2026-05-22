
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../news/domain/entities/article.dart';
import '../../../../../news/domain/usecases/get_bookmarks.dart';
import '../../../../../news/domain/usecases/toggle_bookmark.dart';



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
  List<Object?> get props => [article];
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
  List<Object?> get props => [articles];
}

class BookmarksEmpty extends BookmarksState {
  const BookmarksEmpty();
}

class BookmarksError extends BookmarksState {
  final String message;

  const BookmarksError(this.message);

  @override
  List<Object?> get props => [message];
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
          (articles) {
        if (articles.isEmpty) {
          emit(const BookmarksEmpty());
        } else {
          emit(BookmarksLoaded(articles));
        }
      },
    );
  }

  Future<void> _onRemoveBookmark(
      RemoveBookmarkEvent event,
      Emitter<BookmarksState> emit,
      ) async {
    final currentState = state;

    if (currentState is! BookmarksLoaded) return;

    // Optimistic UI update
    final updatedArticles = currentState.articles
        .where((a) => a.id != event.article.id)
        .toList();

    emit(
      updatedArticles.isEmpty
          ? const BookmarksEmpty()
          : BookmarksLoaded(updatedArticles),
    );

    final result = await toggleBookmark(
      event.article.copyWith(
        isBookmarked: true,
      ),
    );

    result.fold(
          (_) => add(const LoadBookmarksEvent()),
          (_) {},
    );
  }
}





