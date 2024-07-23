part of 'channel_bloc.dart';

@freezed
class ChannelState with _$ChannelState {
  factory ChannelState(
      {required bool isLoading,
      required bool isError,
      required ChannelResp? result,
      required bool isMoreFetchLoading,
      required bool isMoreFetchError,
      required bool isMoreFetchCompleted}) = _ChannelState;

  factory ChannelState.initialize() => ChannelState(
      isLoading: false,
      isError: false,
      result: null,
      isMoreFetchLoading: false,
      isMoreFetchError: false,
      isMoreFetchCompleted: false);
}
