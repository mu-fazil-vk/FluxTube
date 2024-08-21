part of 'channel_bloc.dart';

@freezed
class ChannelState with _$ChannelState {
  factory ChannelState({
    required ApiStatus channelDetailsFetchStatus,
    required ChannelResp? result,
    required ApiStatus moreChannelDetailsFetchStatus,
    required bool isMoreFetchCompleted,
  }) = _ChannelState;

  factory ChannelState.initialize() => ChannelState(
        result: null,
        channelDetailsFetchStatus: ApiStatus.initial,
        moreChannelDetailsFetchStatus: ApiStatus.initial,
        isMoreFetchCompleted: false,
      );
}
