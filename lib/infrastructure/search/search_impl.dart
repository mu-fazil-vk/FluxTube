import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/search/models/invidious/invidious_search_resp.dart';
import 'package:fluxtube/domain/search/models/newpipe/newpipe_search_resp.dart';
import 'package:fluxtube/domain/search/models/piped/search_resp.dart';
import 'package:fluxtube/domain/search/search_service.dart';
import 'package:fluxtube/infrastructure/newpipe/newpipe_channel.dart';
import 'package:injectable/injectable.dart';

import '../../domain/core/api_end_points.dart';

@LazySingleton(as: SearchService)
class SearchImpl implements SearchService {
  //Piped

  @override
  Future<Either<MainFailure, SearchResp>> getSearchResult(
      {required String query, required String filter}) async {
    try {
      final Response response =
          await ApiClient.dio.get("${ApiEndPoints.search}$query&filter=$filter");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(SearchResp.fromJson(response.data));
      } else {
        log('Err on getSearchResult: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getSearchResult: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, List>> getSearchSuggestion(
      {required String query}) async {
    try {
      final Response response =
          await ApiClient.dio.get("${ApiEndPoints.suggestions}$query");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(response.data as List);
      } else {
        log('Err on getSearchSuggestion: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getSearchSuggestion: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, SearchResp>> getMoreSearchResult(
      {required String query,
      required String filter,
      required String? nextPage}) async {
    try {
      final Response response = await ApiClient.dio.get(
          "${ApiEndPoints.moreSearch}$query&filter=$filter&nextpage=$nextPage");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(SearchResp.fromJson(response.data));
      } else {
        log('Err on getMoreSearchResult: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getMoreSearchResult: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  //Invidious

  @override
  Future<Either<MainFailure, List<InvidiousSearchResp>>>
      getInvidiousSearchResult(
          {required String query, required String type}) async {
    try {
      final Response response = await ApiClient.dio
          .get("${InvidiousApiEndpoints.search}$query&type=$type");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<InvidiousSearchResp> result = List<InvidiousSearchResp>.from(
            response.data.map((x) => InvidiousSearchResp.fromJson(x)));
        return Right(result);
      } else {
        log('Err on getInvidiousSearchResult: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousSearchResult: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, List>> getInvidiousSearchSuggestion(
      {required String query}) async {
    try {
      final Response response = await ApiClient.dio
          .get("${InvidiousApiEndpoints.suggestions}$query");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(response.data["suggestions"] as List);
      } else {
        log('Err on getInvidiousSearchSuggestion: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousSearchSuggestion: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, List<InvidiousSearchResp>>>
      getMoreInvidiousSearchResult(
          {required String query,
          required String type,
          required int? page}) async {
    try {
      final Response response = await ApiClient.dio.get(
          "${InvidiousApiEndpoints.search}$query&type=$type&page=$page");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<InvidiousSearchResp> result = List<InvidiousSearchResp>.from(
            response.data.map((x) => InvidiousSearchResp.fromJson(x)));
        return Right(result);
      } else {
        log('Err on getMoreInvidiousSearchResult: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getMoreInvidiousSearchResult: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  //NewPipe

  @override
  Future<Either<MainFailure, NewPipeSearchResp>> getNewPipeSearchResult(
      {required String query, required String filter}) async {
    try {
      log('NewPipe: Searching for "$query" with filter $filter');
      final result = await NewPipeChannel.search(query: query, filter: filter);
      return Right(result);
    } catch (e) {
      log('Err on getNewPipeSearchResult: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, NewPipeSearchResp>> getMoreNewPipeSearchResult(
      {required String query,
      required String filter,
      required String nextPage}) async {
    try {
      log('NewPipe: Getting more search results for "$query"');
      final result = await NewPipeChannel.search(
        query: query,
        filter: filter,
        nextPage: nextPage,
      );
      return Right(result);
    } catch (e) {
      log('Err on getMoreNewPipeSearchResult: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, List>> getNewPipeSearchSuggestion(
      {required String query}) async {
    try {
      log('NewPipe: Getting search suggestions for "$query"');
      final result = await NewPipeChannel.getSearchSuggestions(query);
      return Right(result);
    } catch (e) {
      log('Err on getNewPipeSearchSuggestion: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }
}
