import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/home/home_services.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/trending/models/piped/trending_resp.dart';
import 'package:injectable/injectable.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

import '../../domain/core/api_end_points.dart';

@LazySingleton(as: HomeServices)
class HomeImpliment extends HomeServices {
  @override
  Future<Either<MainFailure, List<TrendingResp>>> getHomeFeedData(
      {required List<Subscribe> channels}) async {
    final dioClient = Dio();
    try {
      final subscribedChannelIds =
          channels.map((channel) => channel.id.toString()).toList();
      final String idsAsString = subscribedChannelIds.join(",");

      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        ApiEndPoints.feed + idsAsString,
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
        log('Err on getHomeFeedData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getHomeFeedData: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      dioClient.close();
    }
  }
}
