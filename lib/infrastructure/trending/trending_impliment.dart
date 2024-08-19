import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/domain/core/api_end_points.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/trending/models/trending_resp.dart';
import 'package:fluxtube/domain/trending/trending_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TrendingService)
class TrendingImpliment implements TrendingService {
  @override
  Future<Either<MainFailure, List<TrendingResp>>> getTrendingData(
      {required String region}) async {
    try {
      final Response response =
          await Dio(BaseOptions()).get(ApiEndPoints.trending + region);
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
}
