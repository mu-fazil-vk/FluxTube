import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/domain/channel/channel_services.dart';
import 'package:fluxtube/domain/channel/models/channel_resp.dart';
import 'package:fluxtube/domain/core/api_end_points.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChannelServices)
class ChannelImpl extends ChannelServices {
  @override
  Future<Either<MainFailure, ChannelResp>> getChannelData(
      {required String channelId}) async {
    try {
      final Response response =
          await Dio(BaseOptions()).get("${ApiEndPoints.channel}$channelId");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final ChannelResp result = ChannelResp.fromJson(response.data);

        return Right(result);
      } else {
        log('Err on GetChannelData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on GetChannelData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, ChannelResp>> getMoreChannelVideos(
      {required String channelId, required String? nextPage}) async {
    try {
      final Response response = await Dio(BaseOptions()).get(
          "${ApiEndPoints.moreChannelVideos}$channelId?nextpage=$nextPage");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final ChannelResp result = ChannelResp.fromJson(response.data);

        return Right(result);
      } else {
        log('Err on getMoreChannelVideos: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getMoreChannelVideos: $e');
      return const Left(MainFailure.clientFailure());
    }
  }
}
