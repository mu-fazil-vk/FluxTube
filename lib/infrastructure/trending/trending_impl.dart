import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:fluxtube/domain/core/api_end_points.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/trending/models/invidious/invidious_trending_resp.dart';
import 'package:fluxtube/domain/trending/models/newpipe/newpipe_trending_resp.dart';
import 'package:fluxtube/domain/trending/models/piped/trending_resp.dart';
import 'package:fluxtube/domain/trending/trending_service.dart';
import 'package:fluxtube/infrastructure/newpipe/newpipe_channel.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TrendingService)
class TrendingImpl implements TrendingService {
  ///[getTrendingData] used to fetch Trending data from Piped.
  @override
  Future<Either<MainFailure, List<TrendingResp>>> getTrendingData(
      {required String region}) async {
    log(ApiEndPoints.trending + region);
    try {
      final Response response = await ApiClient.dio.get(
        ApiEndPoints.trending + region,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<TrendingResp> result = (response.data as List)
            .map((e) => TrendingResp.fromJson(e))
            .toList();

        return Right(result);
      } else {
        log('Err on getTrendingData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getTrendingData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  ///[getInvidiousTrendingData] used to fetch Trending data from Invidious.
  @override
  Future<Either<MainFailure, List<InvidiousTrendingResp>>>
      getInvidiousTrendingData({required String region}) async {
    log(InvidiousApiEndpoints.trending + region);
    try {
      final Response response = await ApiClient.dio.get(
        InvidiousApiEndpoints.trending + region,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<InvidiousTrendingResp> result = (response.data as List)
            .map((e) => InvidiousTrendingResp.fromJson(e))
            .toList();

        return Right(result);
      } else {
        log('Err on getInvidiousTrendingData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousTrendingData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  ///[getNewPipeTrendingData] used to fetch Trending data from NewPipe Extractor.
  @override
  Future<Either<MainFailure, List<NewPipeTrendingResp>>>
      getNewPipeTrendingData({required String region}) async {
    try {
      log('NewPipe: Getting trending for region $region');
      final result = await NewPipeChannel.getTrending(region);
      return Right(result);
    } catch (e) {
      log('Err on getNewPipeTrendingData: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }
}
