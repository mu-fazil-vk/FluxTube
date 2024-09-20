part of 'trending_bloc.dart';

@freezed
class TrendingState with _$TrendingState {
  const factory TrendingState({

    // PIPED
    required List<TrendingResp> trendingResult,
    required List<TrendingResp> feedResult,
    required ApiStatus fetchTrendingStatus,
    required ApiStatus fetchFeedStatus,


    // EXPLODE 
    
    required ApiStatus fetchInvidiousTrendingStatus,
    required List<InvidiousTrendingResp> invidiousTrendingResult,
  }) = _Initial;

  factory TrendingState.initialize() => const TrendingState(

        // PIPED

        trendingResult: [],
        feedResult: [],
        fetchTrendingStatus: ApiStatus.initial,
        fetchFeedStatus: ApiStatus.initial,

        // EXPLODE
        
        fetchInvidiousTrendingStatus: ApiStatus.initial,
        invidiousTrendingResult: [],
      );
}
