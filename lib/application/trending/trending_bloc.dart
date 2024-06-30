import 'package:flutter_bloc/flutter_bloc.dart';
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
      emit(state.copyWith(isError: false, isLoading: true));

      final result =
          await trendingService.getTrendingData(region: event.region);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(isError: true, isLoading: false),
          (List<TrendingResp> resp) => state.copyWith(
              trendingResult: resp, isLoading: false, isError: false));
      emit(_state);
    });

//get new trending data when refresh
    on<GetForcedTrendingData>((event, emit) async {
      //make loading
      emit(state.copyWith(isError: false, isLoading: true));

      final result =
          await trendingService.getTrendingData(region: event.region);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(isError: true, isLoading: false),
          (List<TrendingResp> resp) => state.copyWith(
              trendingResult: resp, isLoading: false, isError: false));
      emit(_state);
    });

    // home feed call
    on<GetHomeFeedData>((event, emit) async {
      if (state.feedResult.isNotEmpty) {
        return emit(state);
      }

      //make loading
      emit(state.copyWith(isFeedError: false, isLoading: true));

      final result =
          await homeServices.getHomeFeedData(channels: event.channels);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(isFeedError: true, isLoading: false),
          (List<TrendingResp> resp) {
        return state.copyWith(
            feedResult: resp, isLoading: false, isError: false);
      });
      emit(_state);
    });

    // get data when refresh
    on<GetForcedHomeFeedData>((event, emit) async {
      //make loading
      emit(state.copyWith(isFeedError: false, isLoading: true));

      final result =
          await homeServices.getHomeFeedData(channels: event.channels);

      final _state = result.fold(
          (MainFailure failure) =>
              state.copyWith(isFeedError: true, isLoading: false),
          (List<TrendingResp> resp) {
        return state.copyWith(
            feedResult: resp, isLoading: false, isError: false);
      });
      emit(_state);
    });
  }
}
