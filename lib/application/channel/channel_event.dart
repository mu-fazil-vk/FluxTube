part of 'channel_bloc.dart';

@freezed
class ChannelEvent with _$ChannelEvent {
  const factory ChannelEvent.getChannelData({
    required String serviceType,
    required String channelId,
  }) = GetChannelData;
  const factory ChannelEvent.getMoreChannelVideos({
    required String serviceType,
    required String channelId,
    required String? nextPage,
  }) = GetMoreChannelVideos;
}
