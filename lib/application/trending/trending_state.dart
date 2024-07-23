part of 'trending_bloc.dart';

@freezed
class TrendingState with _$TrendingState {
  const factory TrendingState({
    required List<TrendingResp> trendingResult,
    required List<TrendingResp> feedResult,
    required bool isLoading,
    required bool isError,
    required bool isFeedError,
  }) = _Initial;

  factory TrendingState.initialize() => const TrendingState(
      trendingResult: [],
      feedResult: [],
      isLoading: false,
      isError: false,
      isFeedError: false);
}
