import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:fluxtube/domain/channel/channel_services.dart';
import 'package:fluxtube/domain/channel/models/invidious/invidious_channel_resp.dart';
import 'package:fluxtube/domain/channel/models/invidious/latest_video.dart';
import 'package:fluxtube/domain/channel/models/newpipe/newpipe_channel_resp.dart';
import 'package:fluxtube/domain/channel/models/piped/channel_resp.dart';
import 'package:fluxtube/domain/channel/models/piped/tab_content.dart';
import 'package:fluxtube/domain/core/api_end_points.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/infrastructure/newpipe/newpipe_channel.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChannelServices)
class ChannelImpl extends ChannelServices {
  //Piped

  @override
  Future<Either<MainFailure, ChannelResp>> getChannelData(
      {required String channelId}) async {
    try {
      final Response response =
          await ApiClient.dio.get("${ApiEndPoints.channel}$channelId");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(ChannelResp.fromJson(response.data));
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
      final Response response = await ApiClient.dio.get(
          "${ApiEndPoints.moreChannelVideos}$channelId?nextpage=$nextPage");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(ChannelResp.fromJson(response.data));
      } else {
        log('Err on getMoreChannelVideos: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getMoreChannelVideos: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, TabContent>> getChannelTabContent(
      {required String data}) async {
    try {
      final Response response = await ApiClient.dio
          .get("${ApiEndPoints.channelTabs}${Uri.encodeComponent(data)}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(TabContent.fromJson(response.data));
      } else {
        log('Err on getChannelTabContent: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getChannelTabContent: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  //Invidious

  @override
  Future<Either<MainFailure, InvidiousChannelResp>> getInvidiousChannelData(
      {required String channelId}) async {
    try {
      final Response response = await ApiClient.dio
          .get("${InvidiousApiEndpoints.channel}$channelId");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(InvidiousChannelResp.fromJson(response.data));
      } else {
        log('Err on getInvidiousChannelData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousChannelData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, List<LatestVideo>>> getMoreInvidiousChannelVideos(
      {required String channelId, required int page}) async {
    try {
      final Response response = await ApiClient.dio.get(
          "${InvidiousApiEndpoints.channelVideos}$channelId/videos?page=$page");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['videos'] ?? response.data;
        final List<LatestVideo> videos = data
            .map((json) => LatestVideo.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(videos);
      } else {
        log('Err on getMoreInvidiousChannelVideos: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getMoreInvidiousChannelVideos: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  //NewPipe

  @override
  Future<Either<MainFailure, NewPipeChannelResp>> getNewPipeChannelData(
      {required String channelId}) async {
    try {
      log('NewPipe: Getting channel data for $channelId');
      final result = await NewPipeChannel.getChannel(channelId);
      return Right(result);
    } catch (e) {
      log('Err on getNewPipeChannelData: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }
}
