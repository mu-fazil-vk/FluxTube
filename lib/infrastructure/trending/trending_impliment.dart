import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/domain/core/api_end_points.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/trending/models/invidious/invidious_trending_resp.dart';
import 'package:fluxtube/domain/trending/models/piped/trending_resp.dart';
import 'package:fluxtube/domain/trending/trending_service.dart';
import 'package:injectable/injectable.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

@LazySingleton(as: TrendingService)
class TrendingImpliment implements TrendingService {
  ///[getTrendingData] used to fetch Trending data from Piped.
  @override
  Future<Either<MainFailure, List<TrendingResp>>> getTrendingData(
      {required String region}) async {
    final dioClient = Dio();
    try {
      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        ApiEndPoints.trending + region,
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
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
    } finally {
      dioClient.close();
    }
  }

  ///[getInvidiousTrendingData] used to fetch Trending data from Invidious.
  @override
  Future<Either<MainFailure, List<InvidiousTrendingResp>>>
      getInvidiousTrendingData({required String region}) async {
    final dioClient = Dio();
    try {
      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        InvidiousApiEndpoints.trending + region,
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
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
    } finally {
      dioClient.close();
    }
  }
}
