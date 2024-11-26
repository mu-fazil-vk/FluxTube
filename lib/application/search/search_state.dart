part of 'search_bloc.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    //
    required bool isSuggestionDisplay,

    // PIPED

    required ApiStatus fetchSearchResultStatus,
    required SearchResp? result,
    required ApiStatus fetchSuggestionStatus,
    required List suggestions,
    required ApiStatus fetchMoreSearchResultStatus,
    required bool isMoreFetchCompleted,

    // INVIDIOUS

    required ApiStatus fetchInvidiousSearchResultStatus,
    required List<InvidiousSearchResp> invidiousSearchResult,
    required ApiStatus fetchInvidiousSuggestionStatus,
    required List invidiousSuggestionResult,
    required ApiStatus fetchMoreInvidiousSearchResultStatus,
    required bool isMoreInvidiousFetchCompleted,
    int? page,
  }) = _SearchState;

  factory SearchState.initialize() => const SearchState(
        //
        isSuggestionDisplay: false,

        // PIPED
        
        fetchSearchResultStatus: ApiStatus.initial,
        result: null,
        fetchSuggestionStatus: ApiStatus.initial,
        suggestions: [],
        fetchMoreSearchResultStatus: ApiStatus.initial,
        isMoreFetchCompleted: false,
        
        // INVIDIOUS

        fetchInvidiousSearchResultStatus: ApiStatus.initial,
        invidiousSearchResult: [],
        fetchInvidiousSuggestionStatus: ApiStatus.initial,
        invidiousSuggestionResult: [],
        fetchMoreInvidiousSearchResultStatus: ApiStatus.initial,
        isMoreInvidiousFetchCompleted: false,
        page: 2,
      );
}
