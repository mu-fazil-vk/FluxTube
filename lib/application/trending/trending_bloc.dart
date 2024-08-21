import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/home/home_services.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/trending/trending_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/trending/models/trending_resp.dart';

part 'trending_event.dart';
part 'trending_state.dart';
part 'trending_bloc.freezed.dart';

@injectable
class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  TrendingBloc(
    TrendingService trendingService,
    HomeServices homeServices,
  ) : super(TrendingState.initialize()) {
    // fetch trending videos
    on<GetTrendingData>((event, emit) async {
      if (state.trendingResult.isNotEmpty) {
        return emit(state);
      }

      //make loading
      emit(state.copyWith(fetchTrendingStatus: ApiStatus.loading));

      final result =
          await trendingService.getTrendingData(region: event.region);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(fetchTrendingStatus: ApiStatus.error),
          (List<TrendingResp> resp) => state.copyWith(
              trendingResult: resp, fetchTrendingStatus: ApiStatus.loaded));
      emit(_state);
    });

//get new trending data when refresh
    on<GetForcedTrendingData>((event, emit) async {
      //make loading
      emit(state.copyWith(fetchTrendingStatus: ApiStatus.loading));

      final result =
          await trendingService.getTrendingData(region: event.region);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(fetchTrendingStatus: ApiStatus.error),
          (List<TrendingResp> resp) => state.copyWith(
              trendingResult: resp, fetchTrendingStatus: ApiStatus.loaded));
      emit(_state);
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
}
