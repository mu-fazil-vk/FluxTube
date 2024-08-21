part of 'trending_bloc.dart';

@freezed
class TrendingState with _$TrendingState {
  const factory TrendingState({
    required List<TrendingResp> trendingResult,
    required List<TrendingResp> feedResult,
    required ApiStatus fetchTrendingStatus,
    required ApiStatus fetchFeedStatus,
  }) = _Initial;

  factory TrendingState.initialize() => const TrendingState(
        trendingResult: [],
        feedResult: [],
        fetchTrendingStatus: ApiStatus.initial,
        fetchFeedStatus: ApiStatus.initial,
      );
}
