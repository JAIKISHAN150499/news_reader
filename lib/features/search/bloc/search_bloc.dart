import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../news/domain/entities/article.dart';
import '../../news/domain/usecases/search_articles.dart';

// ── EVENTS ────────────────────────────────────────────────────
abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged({required this.query});
  @override
  List<Object> get props => [query];
}

class SearchCleared extends SearchEvent {}

// ── STATES ────────────────────────────────────────────────────
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<Article> results;
  final String query;
  const SearchLoaded({required this.results, required this.query});
  @override
  List<Object> get props => [results, query];
}

class SearchEmpty extends SearchState {
  final String query;
  const SearchEmpty({required this.query});
  @override
  List<Object> get props => [query];
}

class SearchError extends SearchState {
  final String message;
  const SearchError({required this.message});
  @override
  List<Object> get props => [message];
}

// ── BLOC ──────────────────────────────────────────────────────
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchArticles searchArticles;

  SearchBloc({required this.searchArticles}) : super(const SearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: _debounceTransformer(
        const Duration(milliseconds: AppConstants.searchDebounceMs),
      ),
    );
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.length < AppConstants.minSearchChars) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    final result = await searchArticles(SearchParams(query: query));

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (articles) {
        if (articles.isEmpty) {
          emit(SearchEmpty(query: query));
        } else {
          emit(SearchLoaded(results: articles, query: query));
        }
      },
    );
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchInitial());
  }
}

EventTransformer<T> _debounceTransformer<T>(Duration duration) {
  return (events, mapper) {
    return events.debounceTime(duration).switchMap(mapper);
  };
}
