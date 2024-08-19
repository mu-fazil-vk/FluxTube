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

  factory WatchEvent.getMoreCommentsData({
    required String id,
    required String? nextPage,
  }) = GetMoreCommentsData;

  factory WatchEvent.getMoreReplyCommentsData({
    required String id,
    required String? nextPage,
  }) = GetMoreReplyCommentsData;

  factory WatchEvent.getSubtitles({
    required String id,
  }) = GetSubtitles;

  factory WatchEvent.tapDescription() = TapDescription;
  
  factory WatchEvent.togglePip({required bool value}) = TogglePip;

  factory WatchEvent.assignTitle({required String title}) = AssignTitle;

  // YOUTUBE EXPLODE
  factory WatchEvent.getExplodeWatchInfo({
    required String id,
  }) = GetExplodeWatchInfo;

  factory WatchEvent.getExplodeRelatedVideoInfo({
    required String id,
  }) = GetExplodeRelatedVideoInfo;

  factory WatchEvent.getExplodeMuxStreamInfo({
    required String id,
  }) = GetExplodeMuxStreamInfo;

  factory WatchEvent.getExplodeLiveVideoInfo({
    required String id,
  }) = GetExplodeLiveVideoInfo;

  factory WatchEvent.setSelectedVideoBasicDetails({
    required VideoBasicInfo details,
  }) = SetSelectedVideoBasicDetails;
}
