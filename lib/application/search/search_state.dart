part of 'search_bloc.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    required SearchResp? result,
    required ApiStatus fetchSearchResultStatus,
    required List suggestions,
    required bool isSuggestionDisplay,
    required bool isMoreFetchCompleted,
    required ApiStatus fetchSuggestionStatus,
    required ApiStatus fetchMoreSearchResultStatus,
  }) = _SearchState;

  factory SearchState.initialize() => const SearchState(
        result: null,
        suggestions: [],
        isSuggestionDisplay: false,
        isMoreFetchCompleted: false,
        fetchSearchResultStatus: ApiStatus.initial,
        fetchSuggestionStatus: ApiStatus.initial,
        fetchMoreSearchResultStatus: ApiStatus.initial,
      );
}
