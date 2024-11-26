import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/channel/models/invidious/invidious_channel_resp.dart';
import 'package:fluxtube/domain/channel/models/piped/channel_resp.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';

abstract class ChannelServices {
  //Piped

  ///[getChannelData] fetches channel data from the Piped API
  Future<Either<MainFailure, ChannelResp>> getChannelData(
      {required String channelId});

  ///[getMoreChannelVideos] fetches more channel videos from the Piped API
  Future<Either<MainFailure, ChannelResp>> getMoreChannelVideos(
      {required String channelId, required String? nextPage});

  //Invidious

  ///[getInvidiousChannelData] fetches channel data from the Invidious API
  Future<Either<MainFailure, InvidiousChannelResp>> getInvidiousChannelData(
      {required String channelId});
}
