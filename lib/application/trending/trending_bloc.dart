// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/home/home_services.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/trending/models/invidious/invidious_trending_resp.dart';
import 'package:fluxtube/domain/trending/trending_service.dart';

import '../../domain/trending/models/piped/trending_resp.dart';

part 'trending_bloc.freezed.dart';
part 'trending_event.dart';
part 'trending_state.dart';

@injectable
class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  final SettingsBloc settingsBloc;
  final TrendingService trendingService;
  final HomeServices homeServices;  
  TrendingBloc(
    this.settingsBloc,
    this.trendingService,
    this.homeServices,
  ) : super(TrendingState.initialize()) {


    // fetch trending videos
    on<GetTrendingData>((event, emit) async {


      if (event.serviceType == YouTubeServices.piped.name) {
        if (state.trendingResult.isNotEmpty) {
          return emit(state);
        }
      } else {
        if (state.invidiousTrendingResult.isNotEmpty) {
          return emit(state);
        }
      }

      if (event.serviceType == YouTubeServices.piped.name) {
        await _fetchPipedTrendingInfo(event, emit);
      } else {
        await _fetchInvidiousTrendingInfo(event, emit);
      }
    });

    //get new trending data when refresh
    on<GetForcedTrendingData>((event, emit) async {

      if (event.serviceType == YouTubeServices.piped.name) {
        await _fetchPipedTrendingInfo(event, emit);
      } else {
        await _fetchInvidiousTrendingInfo(event, emit);
      }
    });

    // home feed call
    on<GetHomeFeedData>((event, emit) async {
      if (state.feedResult.isNotEmpty) {
        return emit(state);
      }

      //make loading
      emit(state.copyWith(fetchFeedStatus: ApiStatus.loading));

      final result =
          await homeServices.getHomeFeedData(channels: event.channels);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(fetchFeedStatus: ApiStatus.error),
          (List<TrendingResp> resp) {
        return state.copyWith(
            feedResult: resp, fetchFeedStatus: ApiStatus.loaded);
      });
      emit(_state);
    });

    // get data when refresh
    on<GetForcedHomeFeedData>((event, emit) async {
      //make loading
      emit(state.copyWith(fetchFeedStatus: ApiStatus.loading));

      final result =
          await homeServices.getHomeFeedData(channels: event.channels);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(fetchFeedStatus: ApiStatus.error),
          (List<TrendingResp> resp) {
        return state.copyWith(
            feedResult: resp, fetchFeedStatus: ApiStatus.loaded);
      });
      emit(_state);
    });
  }

  _fetchPipedTrendingInfo(event, emit) async {
    emit(state.copyWith(fetchTrendingStatus: ApiStatus.loading));

    final result = await trendingService.getTrendingData(
        region: settingsBloc.state.defaultRegion);

    final _state = result.fold(
        (MainFailure failure) =>
            state.copyWith(fetchTrendingStatus: ApiStatus.error),
        (List<TrendingResp> resp) => state.copyWith(
            trendingResult: resp, fetchTrendingStatus: ApiStatus.loaded));
    emit(_state);
  }

  _fetchInvidiousTrendingInfo(event, emit) async {
    emit(state.copyWith(fetchInvidiousTrendingStatus: ApiStatus.loading));

    final result = await trendingService.getInvidiousTrendingData(
        region: settingsBloc.state.defaultRegion);
    final _state = result.fold(
        (MainFailure failure) =>
            state.copyWith(fetchInvidiousTrendingStatus: ApiStatus.error),
        (List<InvidiousTrendingResp> resp) => state.copyWith(
            invidiousTrendingResult: resp,
            fetchInvidiousTrendingStatus: ApiStatus.loaded));
    emit(_state);
  }
}
