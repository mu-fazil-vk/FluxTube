part of 'search_bloc.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState(
      {required SearchResp? result,
      required bool isLoading,
      required bool isError,
      required List suggestions,
      required bool isSuggestionError,
      required bool isSuggestionDisplay,
      required bool isMoreFetchLoading,
      required bool isMoreFetchError,
      required bool isMoreFetchCompleted}) = _SearchState;

  factory SearchState.initialize() => const SearchState(
        result: null,
        isLoading: false,
        isError: false,
        suggestions: [],
        isSuggestionError: false,
        isSuggestionDisplay: false,
        isMoreFetchLoading: false,
        isMoreFetchError: false,
        isMoreFetchCompleted: false,
      );
}
