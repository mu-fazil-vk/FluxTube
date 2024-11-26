import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/search/models/invidious/invidious_search_resp.dart';
import 'package:fluxtube/domain/search/models/piped/search_resp.dart';

abstract class SearchService {
  //Piped

  ///[getSearchResult] used to fetch search result from Piped.
  Future<Either<MainFailure, SearchResp>> getSearchResult({
    required String query,
    required String filter,
  });

  ///[getMoreSearchResult] used to fetch more search result from Piped.
  Future<Either<MainFailure, SearchResp>> getMoreSearchResult({
    required String query,
    required String filter,
    required String? nextPage,
  });

  ///[getSearchSuggestion] used to fetch search suggestion from Piped.
  Future<Either<MainFailure, List>> getSearchSuggestion({
    required String query,
  });

  //Invidious

  ///[getInvidiousSearchResult] used to fetch search result from Invidious.
  Future<Either<MainFailure, List<InvidiousSearchResp>>>
      getInvidiousSearchResult({
    required String query,
    required String type,
  });

  ///[getMoreInvidiousSearchResult] used to fetch more search result from Invidious.
  Future<Either<MainFailure, List<InvidiousSearchResp>>>
      getMoreInvidiousSearchResult({
    required String query,
    required String type,
    required int? page,
  });

  ///[getInvidiousSearchSuggestion] used to fetch search suggestion from Invidious.
  Future<Either<MainFailure, List>> getInvidiousSearchSuggestion({
    required String query,
  });
}
