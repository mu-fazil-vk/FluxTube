part of 'search_bloc.dart';

@freezed
class SearchEvent with _$SearchEvent {
  const factory SearchEvent.getSearchResult({
    required String query,
    required String? filter,
  }) = GetSearchResult;

  const factory SearchEvent.getMoreSearchResult(
      {required String query,
      required String? filter,
      required String? nextPage}) = GetMoreSearchResult;

  const factory SearchEvent.getSearchSuggestion({
    required String query,
  }) = GetSearchSuggestion;
}
