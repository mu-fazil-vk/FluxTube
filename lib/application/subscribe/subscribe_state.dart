part of 'subscribe_bloc.dart';

@freezed
class SubscribeState with _$SubscribeState {
  const factory SubscribeState({
    required bool isLoading,
    required bool isError,
    required Subscribe? channelInfo,
    required List<Subscribe> subscribedChannels,
  }) = _Initial;

  factory SubscribeState.initialize() => const SubscribeState(
      isLoading: false,
      isError: false,
      channelInfo: null,
      subscribedChannels: []);
}
