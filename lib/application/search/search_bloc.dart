import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/search/models/search_resp.dart';
import 'package:fluxtube/domain/search/search_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'search_event.dart';
part 'search_state.dart';
part 'search_bloc.freezed.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
    SearchService searchService,
  ) : super(SearchState.initialize()) {
    on<GetSearchResult>((event, emit) async {
      //loading
      emit(state.copyWith(
          result: null,
          suggestions: [],
          isSuggestionDisplay: false,
          fetchSearchResultStatus: ApiStatus.loading,
          fetchSuggestionStatus: ApiStatus.initial,
          fetchMoreSearchResultStatus: ApiStatus.initial,
          ));

      //get search details
      final _result = await searchService.getSearchResult(
          query: event.query, filter: event.filter ?? "all");

      //assign data
      final _state = _result.fold(
          (MainFailure failure) => state.copyWith(
                result: null,
                suggestions: [],
                fetchSearchResultStatus: ApiStatus.error,
              ),
          (SearchResp resp) => state.copyWith(
              result: resp,
              suggestions: [],
              fetchSearchResultStatus: ApiStatus.loaded,
              ));

      //update to ui
      emit(_state);
    });

    //get suggestions
    on<GetSearchSuggestion>((event, emit) async {
      //loading
      emit(state.copyWith(
          result: null,
          suggestions: [],
          fetchSuggestionStatus: ApiStatus.loading,
          ));

      //get search details
      final _result =
          await searchService.getSearchSuggestion(query: event.query);

      //assign data
      final _state = _result.fold(
        (MainFailure failure) => state.copyWith(
          suggestions: [],
          fetchSuggestionStatus: ApiStatus.error,
        ),
        (List resp) => state.copyWith(
          suggestions: resp,
          isSuggestionDisplay: true,
          fetchSuggestionStatus: ApiStatus.loaded,
        ),
      );

      //update to ui
      emit(_state);
    });

    // GET MORE SEARCH RESULT
    on<GetMoreSearchResult>((event, emit) async {
      //loading
      emit(state.copyWith(
          fetchMoreSearchResultStatus: ApiStatus.loading,
          isMoreFetchCompleted: false));

      //get search details
      final _result = await searchService.getMoreSearchResult(
          query: event.query,
          filter: event.filter ?? "all",
          nextPage: event.nextPage);

      //assign data
      final _state = _result.fold(
          (MainFailure failure) =>
              state.copyWith(fetchMoreSearchResultStatus: ApiStatus.error),
          (SearchResp resp) {
        if (resp.nextpage == null) {
          return state.copyWith(
            fetchMoreSearchResultStatus: ApiStatus.loaded,
            isMoreFetchCompleted: true,
          );
        } else if (state.result?.items != null) {
          final moreSearch = state.result;

          moreSearch!.items.addAll(resp.items);
          moreSearch.nextpage = resp.nextpage;
          return state.copyWith(fetchMoreSearchResultStatus: ApiStatus.loaded, result: moreSearch);
        } else {
          return state;
        }
      });

      //update to ui
      emit(_state);
    });
  }
}
