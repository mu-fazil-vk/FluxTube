import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/channel/models/channel_resp.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';

abstract class ChannelServices {
  Future<Either<MainFailure, ChannelResp>> getChannelData(
      {required String channelId});
  Future<Either<MainFailure, ChannelResp>> getMoreChannelVideos(
      {required String channelId,
      required String? nextPage});
}
