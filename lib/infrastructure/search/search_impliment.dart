import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/search/models/search_resp.dart';
import 'package:fluxtube/domain/search/search_service.dart';
import 'package:injectable/injectable.dart';

import '../../domain/core/api_end_points.dart';

@LazySingleton(as: SearchService)
class SearchImplimentation implements SearchService {
  @override
  Future<Either<MainFailure, SearchResp>> getSearchResult(
      {required String query, required String filter}) async {
    try {
      final Response response = await Dio(BaseOptions())
          .get("${ApiEndPoints.search}$query&filter=$filter");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final SearchResp result = SearchResp.fromJson(response.data);

        return Right(result);
      } else {
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, List>> getSearchSuggestion(
      {required String query}) async {
    try {
      final Response response =
          await Dio(BaseOptions()).get("${ApiEndPoints.suggestions}$query");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List result = response.data;

        return Right(result);
      } else {
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      return const Left(MainFailure.clientFailure());
    }
  }
}
