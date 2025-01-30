import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/search/models/invidious/invidious_search_resp.dart';
import 'package:fluxtube/domain/search/models/piped/search_resp.dart';
import 'package:fluxtube/domain/search/search_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'search_event.dart';
part 'search_state.dart';
part 'search_bloc.freezed.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchService searchService;
  SearchBloc(
    this.searchService,
  ) : super(SearchState.initialize()) {
    on<GetSearchResult>((event, emit) async {
      emit(state.copyWith(isSuggestionDisplay: false));

      if (event.serviceType == YouTubeServices.invidious.name) {
        await _fetchInvidiousSearchResult(event, emit);
      } else {
        await _fetchPipedSearchResult(event, emit);
      }
    });

    //get suggestions
    on<GetSearchSuggestion>((event, emit) async {
      if (event.serviceType == YouTubeServices.invidious.name) {
        await _fetchInvidiousSearchSuggestion(event, emit);
      } else {
        await _fetchPipedSearchSuggestion(event, emit);
      }
    });

    // GET MORE SEARCH RESULT
    on<GetMoreSearchResult>((event, emit) async {
      emit(state.copyWith(isSuggestionDisplay: false));

      if (event.serviceType == YouTubeServices.invidious.name) {
        await _fetchMoreInvidiousSearchResult(event, emit);
      } else {
        await _fetchMorePipedSearchResult(event, emit);
      }
    });
  }

  _fetchPipedSearchResult(event, emit) async {
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
  }

  _fetchInvidiousSearchResult(event, emit) async {
    //loading
    emit(state.copyWith(
      invidiousSearchResult: [],
      invidiousSuggestionResult: [],
      isSuggestionDisplay: false,
      fetchInvidiousSearchResultStatus: ApiStatus.loading,
      fetchInvidiousSuggestionStatus: ApiStatus.initial,
      fetchMoreInvidiousSearchResultStatus: ApiStatus.initial,
    ));

    //get search details
    final _result = await searchService.getInvidiousSearchResult(
        query: event.query, type: event.filter ?? "all");

    //assign data
    final _state = _result.fold(
        (MainFailure failure) => state.copyWith(
              invidiousSearchResult: [],
              fetchInvidiousSearchResultStatus: ApiStatus.error,
            ),
        (List<InvidiousSearchResp> resp) => state.copyWith(
              invidiousSearchResult: resp,
              fetchInvidiousSearchResultStatus: ApiStatus.loaded,
            ));

    //update to ui
    emit(_state);
  }

  _fetchPipedSearchSuggestion(
      GetSearchSuggestion event, Emitter<SearchState> emit) async {
    //loading
    emit(state.copyWith(
      result: null,
      suggestions: [],
      fetchSuggestionStatus: ApiStatus.loading,
    ));

    //get search details
    final _result = await searchService.getSearchSuggestion(query: event.query);

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
  }

  _fetchInvidiousSearchSuggestion(
      GetSearchSuggestion event, Emitter<SearchState> emit) async {
    //loading
    emit(state.copyWith(
      invidiousSearchResult: [],
      invidiousSuggestionResult: [],
      fetchInvidiousSuggestionStatus: ApiStatus.loading,
    ));

    //get search details
    final _result =
        await searchService.getInvidiousSearchSuggestion(query: event.query);

    //assign data
    final _state = _result.fold(
      (MainFailure failure) => state.copyWith(
        invidiousSuggestionResult: [],
        fetchInvidiousSuggestionStatus: ApiStatus.error,
      ),
      (List resp) => state.copyWith(
        invidiousSuggestionResult: resp,
        isSuggestionDisplay: true,
        fetchInvidiousSuggestionStatus: ApiStatus.loaded,
      ),
    );

    //update to ui
    emit(_state);
  }

  _fetchMorePipedSearchResult(
      GetMoreSearchResult event, Emitter<SearchState> emit) async {
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
        return state.copyWith(
            fetchMoreSearchResultStatus: ApiStatus.loaded, result: moreSearch);
      } else {
        return state;
      }
    });

    //update to ui
    emit(_state);
  }

  _fetchMoreInvidiousSearchResult(
      GetMoreSearchResult event, Emitter<SearchState> emit) async {
    //also incriment page and pass page instead of nextPage
    emit(state.copyWith(
        fetchMoreInvidiousSearchResultStatus: ApiStatus.loading,
        isMoreInvidiousFetchCompleted: false));

    //get search details
    final _result = await searchService.getMoreInvidiousSearchResult(
        query: event.query, type: event.filter ?? "all", page: state.page);

    //assign data
    final _state = _result.fold(
        (MainFailure failure) => state.copyWith(
            fetchMoreInvidiousSearchResultStatus: ApiStatus.error),
        (List<InvidiousSearchResp> resp) {
      if (resp.isEmpty) {
        return state.copyWith(
          fetchMoreInvidiousSearchResultStatus: ApiStatus.loaded,
          isMoreInvidiousFetchCompleted: true,
        );
      } else {
        final List<InvidiousSearchResp> moreSearch =
            List.from(state.invidiousSearchResult);
        moreSearch.addAll(resp);
        return state.copyWith(
            fetchMoreInvidiousSearchResultStatus: ApiStatus.loaded,
            invidiousSearchResult: moreSearch,
            page: state.page! + 1);
      }
    });

    //update to ui
    emit(_state);
  }
}
