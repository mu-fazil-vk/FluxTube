part of 'watch_bloc.dart';

@freezed
class WatchState with _$WatchState {
  const factory WatchState({
    required WatchResp watchResp,
    required CommentsResp comments,
    required CommentsResp commentReplies,
    String? oldId,
    required bool isLoading,
    required bool isWatchInfoError,
    required bool initialVideoPause,
    required bool isTapComments,
    required bool isCommentsLoading,
    required bool isCommentRepliesLoading,
    required bool isCommentError,
    required bool isCommentRepliesError,
    required bool isDescriptionTapped,
  }) = _Initial;

  factory WatchState.initialize() => WatchState(
        watchResp: WatchResp(),
        comments: CommentsResp(),
        commentReplies: CommentsResp(),
        oldId: null,
        isLoading: false,
        isWatchInfoError: false,
        initialVideoPause: true,
        isTapComments: false,
        isCommentsLoading: false,
        isCommentRepliesLoading: false,
        isCommentError: false,
        isCommentRepliesError: false,
        isDescriptionTapped: false,
      );
}
