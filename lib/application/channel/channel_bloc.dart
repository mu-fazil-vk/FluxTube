import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/channel/channel_services.dart';
import 'package:fluxtube/domain/channel/models/invidious/invidious_channel_resp.dart';
import 'package:fluxtube/domain/channel/models/piped/channel_resp.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'channel_event.dart';
part 'channel_state.dart';
part 'channel_bloc.freezed.dart';

@injectable
class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  final ChannelServices channelServices;

  ChannelBloc(
    this.channelServices,
  ) : super(ChannelState.initialize()) {
    on<GetChannelData>((event, emit) async {
      // Set loading state
      emit(state.copyWith(
          channelDetailsFetchStatus: ApiStatus.loading,
          pipedChannelResp: null,
          invidiousChannelResp: null));

      // Call the appropriate service method based on the serviceType
      if (event.serviceType == YouTubeServices.invidious.name) {
        log("--------invidious bloc---------");
        await _fetchInvidiousChannelInfo(event, emit);
      } else {
        log("--------piped bloc---------");
        await _fetchPipedChannelInfo(event, emit);
      }
    });

    // Fetch more videos
    on<GetMoreChannelVideos>((event, emit) async {
      emit(state.copyWith(
          moreChannelDetailsFetchStatus: ApiStatus.loading,
          isMoreFetchCompleted: false));

      if (event.serviceType == YouTubeServices.invidious.name) {
        await _fetchMoreInvidiousVideos(event, emit);
      } else {
        await _fetchMorePipedVideos(event, emit);
      }
    });
  }

  Future<void> _fetchPipedChannelInfo(
      GetChannelData event, Emitter<ChannelState> emit) async {
    final result =
        await channelServices.getChannelData(channelId: event.channelId);
    final _state = result.fold(
      (failure) => state.copyWith(channelDetailsFetchStatus: ApiStatus.error),
      (response) => state.copyWith(
          channelDetailsFetchStatus: ApiStatus.loaded,
          pipedChannelResp: response),
    );
    emit(_state);
  }

  Future<void> _fetchInvidiousChannelInfo(
      GetChannelData event, Emitter<ChannelState> emit) async {
    final result = await channelServices.getInvidiousChannelData(
        channelId: event.channelId);
    final _state = result.fold(
      (failure) => state.copyWith(channelDetailsFetchStatus: ApiStatus.error),
      (response) => state.copyWith(
          channelDetailsFetchStatus: ApiStatus.loaded,
          invidiousChannelResp: response),
    );
    emit(_state);
  }

  Future<void> _fetchMorePipedVideos(
      GetMoreChannelVideos event, Emitter<ChannelState> emit) async {
    final result = await channelServices.getMoreChannelVideos(
        channelId: event.channelId, nextPage: event.nextPage);

    final _state = result.fold(
      (failure) => state.copyWith(
          moreChannelDetailsFetchStatus: ApiStatus.error,
          isMoreFetchCompleted: false),
      (response) {
        if (response.nextpage == null) {
          return state.copyWith(
              moreChannelDetailsFetchStatus: ApiStatus.loaded,
              isMoreFetchCompleted: true);
        } else {
          final moreSearch = state.pipedChannelResp;
          moreSearch?.relatedStreams?.addAll(response.relatedStreams ?? []);
          moreSearch?.nextpage = response.nextpage;
          return state.copyWith(
              moreChannelDetailsFetchStatus: ApiStatus.loaded,
              pipedChannelResp: moreSearch);
        }
      },
    );
    emit(_state);
  }

  //TODO: Implement the _fetchMoreInvidiousVideos method from videos tab
  Future<void> _fetchMoreInvidiousVideos(
      GetMoreChannelVideos event, Emitter<ChannelState> emit) async {
    // final result = await channelServices.getMoreInvidiousChannelVideos(
    //     channelId: event.channelId, nextPage: event.nextPage);

    // final _state = result.fold(
    //   (failure) => state.copyWith(
    //       moreChannelDetailsFetchStatus: ApiStatus.error, isMoreFetchCompleted: false),
    //   (response) {
    //     if (response.nextpage == null) {
    //       return state.copyWith(
    //           moreChannelDetailsFetchStatus: ApiStatus.loaded,
    //           isMoreFetchCompleted: true);
    //     } else {
    //       final moreSearch = state.invidiousChannelResp;
    //       moreSearch?.relatedStreams?.addAll(response.relatedStreams ?? []);
    //       moreSearch?.nextpage = response.nextpage;
    //       return state.copyWith(
    //           moreChannelDetailsFetchStatus: ApiStatus.loaded,
    //           invidiousChannelResp: moreSearch);
    //     }
    //   },
    // );
    // emit(_state);
  }
}
