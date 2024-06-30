import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/search/models/search_resp.dart';

abstract class SearchService {
  Future<Either<MainFailure, SearchResp>> getSearchResult({
    required String query,
    required String filter,
  });

  Future<Either<MainFailure, List>> getSearchSuggestion({
    required String query,
  });
}
