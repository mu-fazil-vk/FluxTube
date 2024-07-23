import 'package:flutter_bloc/flutter_bloc.dart';
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
      emit(state.copyWith(isLoading: true, isError: false, result: null));

      //get channel info
      final _result =
          await channelServices.getChannelData(channelId: event.channelId);

      //assign data
      final _state = _result.fold(
          (MainFailure f) =>
              state.copyWith(isLoading: false, isError: true, result: null),
          (ChannelResp resp) =>
              state.copyWith(isLoading: false, isError: false, result: resp));

      //update to ui
      emit(_state);
    });

    // fetch more videos
    on<GetMoreChannelVideos>((event, emit) async {
      //loading
      emit(state.copyWith(
          isMoreFetchLoading: true,
          isMoreFetchError: false,
          isMoreFetchCompleted: false));

      //get channel info
      final _result = await channelServices.getMoreChannelVideos(
          channelId: event.channelId, nextPage: event.nextPage);

      //assign data
      final _state = _result.fold(
          (MainFailure f) => state.copyWith(
              isMoreFetchLoading: false,
              isMoreFetchError: true,
              isMoreFetchCompleted: false),
          (ChannelResp resp) {
            if (resp.nextpage == null) {
          return state.copyWith(
            isMoreFetchLoading: false,
            isMoreFetchError: false,
            isMoreFetchCompleted: true,
          );
        } else if (state.result?.relatedStreams != null) {
          final moreSearch = state.result;

          moreSearch!.relatedStreams!.addAll(resp.relatedStreams!);
          moreSearch.nextpage = resp.nextpage;
          return state.copyWith(isMoreFetchLoading: false, result: moreSearch);
        } else {
          return state;
        }
          });

      //update to ui
      emit(_state);
    });
  }
}
