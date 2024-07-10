import 'package:flutter_bloc/flutter_bloc.dart';
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
          isLoading: true,
          isError: false,
          result: null,
          suggestions: [],
          isSuggestionError: false,
          isSuggestionDisplay: false));

      //get search details
      final _result = await searchService.getSearchResult(
          query: event.query, filter: event.filter ?? "all");

      //assign data
      final _state = _result.fold(
          (MainFailure failure) => state.copyWith(
                result: null,
                isLoading: false,
                isError: true,
                suggestions: [],
                isSuggestionDisplay: false,
                isSuggestionError: false,
              ),
          (SearchResp resp) => state.copyWith(
              result: resp,
              isLoading: false,
              isError: false,
              suggestions: [],
              isSuggestionDisplay: false,
              isSuggestionError: false));

      //update to ui
      emit(_state);
    });

    //get suggestions
    on<GetSearchSuggestion>((event, emit) async {
      //loading
      emit(state.copyWith(
          isLoading: false,
          isError: false,
          result: null,
          suggestions: [],
          isSuggestionError: false,
          isSuggestionDisplay: true));

      //get search details
      final _result =
          await searchService.getSearchSuggestion(query: event.query);

      //assign data
      final _state = _result.fold(
        (MainFailure failure) => state.copyWith(
          suggestions: [],
          isSuggestionError: false,
        ),
        (List resp) => state.copyWith(
          suggestions: resp,
          isSuggestionError: false,
        ),
      );

      //update to ui
      emit(_state);
    });

    // GET MORE SEARCH RESULT
    on<GetMoreSearchResult>((event, emit) async {
      //loading
      emit(state.copyWith(
          isMoreFetchLoading: true,
          isMoreFetchError: false,
          isMoreFetchCompleted: false));

      //get search details
      final _result = await searchService.getMoreSearchResult(
          query: event.query,
          filter: event.filter ?? "all",
          nextPage: event.nextPage);

      //assign data
      final _state = _result.fold(
          (MainFailure failure) =>
              state.copyWith(isMoreFetchLoading: false, isMoreFetchError: true),
          (SearchResp resp) {
        if (resp.nextpage == null) {
          return state.copyWith(
            isMoreFetchLoading: false,
            isMoreFetchCompleted: true,
          );
        } else if (state.result?.items != null) {
          final moreSearch = state.result;

          moreSearch!.items.addAll(resp.items);
          moreSearch.nextpage = resp.nextpage;
          return state.copyWith(isMoreFetchLoading: false, result: moreSearch);
        } else {
          return state;
        }
      });

      //update to ui
      emit(_state);
    });
  }
}
