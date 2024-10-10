part of 'subscribe_bloc.dart';

@freezed
class SubscribeState with _$SubscribeState {
  const factory SubscribeState({
    required ApiStatus subscribeStatus,
    required Subscribe? channelInfo,
    required List<Subscribe> subscribedChannels,
    required List<Subscribe> oldList,
  }) = _Initial;

  factory SubscribeState.initialize() => const SubscribeState(
      subscribeStatus: ApiStatus.initial,
      channelInfo: null,
      subscribedChannels: [],
      oldList: []);
}
