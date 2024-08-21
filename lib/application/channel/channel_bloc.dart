import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/channel/channel_services.dart';
import 'package:fluxtube/domain/channel/models/channel_resp.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'channel_event.dart';
part 'channel_state.dart';
part 'channel_bloc.freezed.dart';

@injectable
class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  ChannelBloc(ChannelServices channelServices)
      : super(ChannelState.initialize()) {
    on<GetChannelData>((event, emit) async {
      //loading
      emit(state.copyWith(channelDetailsFetchStatus: ApiStatus.loading, result: null));

      //get channel info
      final _result =
          await channelServices.getChannelData(channelId: event.channelId);

      //assign data
      final _state = _result.fold(
          (MainFailure f) =>
              state.copyWith(channelDetailsFetchStatus: ApiStatus.error, result: null),
          (ChannelResp resp) =>
              state.copyWith(channelDetailsFetchStatus: ApiStatus.loaded, result: resp));

      //update to ui
      emit(_state);
    });

    // fetch more videos
    on<GetMoreChannelVideos>((event, emit) async {
      //loading
      emit(state.copyWith(
          moreChannelDetailsFetchStatus: ApiStatus.loading,
          isMoreFetchCompleted: false));

      //get channel info
      final _result = await channelServices.getMoreChannelVideos(
          channelId: event.channelId, nextPage: event.nextPage);

      //assign data
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(
              moreChannelDetailsFetchStatus: ApiStatus.error,
              isMoreFetchCompleted: false),
          (ChannelResp resp) {
            if (resp.nextpage == null) {
          return state.copyWith(
            moreChannelDetailsFetchStatus: ApiStatus.loaded,
            isMoreFetchCompleted: true,
          );
        } else if (state.result?.relatedStreams != null) {
          final moreSearch = state.result;

          moreSearch!.relatedStreams!.addAll(resp.relatedStreams!);
          moreSearch.nextpage = resp.nextpage;
          return state.copyWith(moreChannelDetailsFetchStatus: ApiStatus.loaded, result: moreSearch);
        } else {
          return state;
        }
          });

      //update to ui
      emit(_state);
    });
  }
}
