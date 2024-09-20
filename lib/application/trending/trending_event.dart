part of 'trending_bloc.dart';

@freezed
class TrendingEvent with _$TrendingEvent {
  const factory TrendingEvent.getTrendingData({required String serviceType}) = GetTrendingData;
  const factory TrendingEvent.getForcedTrendingData({required String serviceType}) = GetForcedTrendingData;
  const factory TrendingEvent.getHomeFeedData(
      {required List<Subscribe> channels}) = GetHomeFeedData;
  const factory TrendingEvent.getForcedHomeFeedData(
      {required List<Subscribe> channels}) = GetForcedHomeFeedData;
}
