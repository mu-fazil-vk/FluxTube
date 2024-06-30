part of 'watch_bloc.dart';

@freezed
class WatchEvent with _$WatchEvent {
  factory WatchEvent.getWatchInfo({
    required String id,
  }) = GetWatchInfo;

  factory WatchEvent.getCommentData({
    required String id,
  }) = GetCommentData;

  factory WatchEvent.getCommentRepliesData({
    required String id,
    required String nextPage,
  }) = GetCommentRepliesData;

  factory WatchEvent.tapDescription() = TapDescription;
}
