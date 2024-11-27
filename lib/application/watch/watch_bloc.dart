import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/domain/watch/models/invidious/comments/invidious_comments_resp.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/domain/watch/models/piped/comments/comments_resp.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/domain/watch/watch_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/watch/models/piped/video/watch_resp.dart';

part 'watch_event.dart';
part 'watch_state.dart';
part 'watch_bloc.freezed.dart';

@injectable
class WatchBloc extends Bloc<WatchEvent, WatchState> {
  WatchBloc(
    WatchService watchService,
  ) : super(WatchState.initialize()) {
    on<GetWatchInfo>(
      (event, emit) async {
        emit(state.copyWith(
          fetchWatchInfoStatus: ApiStatus.loading,
          isTapComments: false,
          isDescriptionTapped: false,
        ));

        //get stream info data
        final result = await watchService.getVideoData(id: event.id);

        final _state = result.fold(
            (MainFailure failure) => state.copyWith(
                  fetchWatchInfoStatus: ApiStatus.error,
                ),
            (WatchResp resp) => state.copyWith(
                watchResp: resp,
                fetchWatchInfoStatus: ApiStatus.loaded,
                oldId: event.id));
        //update to ui
        emit(_state);
      },
    );
    //toggle comments
    on<GetCommentData>((event, emit) async {
      //initialte loading, and toggle comments
      emit(state.copyWith(
          fetchCommentsStatus: ApiStatus.loading,
          isTapComments: !state.isTapComments));

      //get comments list

      if (state.isTapComments == true) {
        final _result = await watchService.getCommentsData(id: event.id);

        final _state = _result.fold(
            (MainFailure failure) =>
                state.copyWith(fetchCommentsStatus: ApiStatus.error),
            (CommentsResp resp) => state.copyWith(
                fetchCommentsStatus: ApiStatus.loaded, comments: resp));

        //update to ui
        emit(_state);
      } else {
        emit(state.copyWith(fetchCommentsStatus: ApiStatus.initial));
      }
    });

    //toggle description
    on<TapDescription>((event, emit) async {
      //toggle desctiption update to ui
      emit(state.copyWith(
          isDescriptionTapped: !state.isDescriptionTapped,
          isTapComments: false));
    });

    // comment replies

    on<GetCommentRepliesData>((event, emit) async {
      //initialte loading, and toggle comments
      emit(state.copyWith(fetchCommentRepliesStatus: ApiStatus.loading));

      //get reply comments list

      final _result = await watchService.getCommentRepliesData(
          id: event.id, repliesPage: event.nextPage);

      final _state = _result.fold(
          (MainFailure failure) => state.copyWith(
                fetchCommentRepliesStatus: ApiStatus.error,
              ),
          (CommentsResp resp) => state.copyWith(
              fetchCommentRepliesStatus: ApiStatus.loaded,
              commentReplies: resp));

      //update to ui
      emit(_state);
    });

    // GET MORE COMMENTS
    on<GetMoreCommentsData>((event, emit) async {
      //initialte loading, and toggle comments
      emit(state.copyWith(
        fetchMoreCommentsStatus: ApiStatus.loading,
        isMoreCommetsFetchCompleted: false,
      ));

      //get reply comments list

      final _result = await watchService.getMoreCommentsData(
          id: event.id, nextPage: event.nextPage);

      final _state = _result.fold(
          (MainFailure failure) => state.copyWith(
                fetchMoreCommentsStatus: ApiStatus.error,
              ), (CommentsResp resp) {
        if (resp.nextpage == null) {
          return state.copyWith(
            fetchMoreCommentsStatus: ApiStatus.loaded,
            isMoreCommetsFetchCompleted: true,
          );
        } else {
          final commentsModel = state.comments;
          commentsModel.comments.addAll(resp.comments);
          commentsModel.nextpage = resp.nextpage;
          return state.copyWith(
            fetchMoreCommentsStatus: ApiStatus.loaded,
            comments: commentsModel,
          );
        }
      });

      //update to ui
      emit(_state);
    });

    // GET MORE REPLY COMMENTS
    on<GetMoreReplyCommentsData>((event, emit) async {
      //initialte loading, and toggle comments
      emit(state.copyWith(
        fetchMoreCommentRepliesStatus: ApiStatus.loading,
        isMoreReplyCommetsFetchCompleted: false,
      ));

      //get reply comments list

      final _result = await watchService.getMoreCommentsData(
          id: event.id, nextPage: event.nextPage);

      final _state = _result.fold(
          (MainFailure failure) => state.copyWith(
                fetchMoreCommentRepliesStatus: ApiStatus.error,
              ), (CommentsResp resp) {
        if (resp.nextpage == null) {
          return state.copyWith(
            fetchMoreCommentRepliesStatus: ApiStatus.loaded,
            isMoreReplyCommetsFetchCompleted: true,
          );
        } else {
          final replyCommentsModel = state.commentReplies;
          replyCommentsModel.comments.addAll(resp.comments);
          replyCommentsModel.nextpage = resp.nextpage;
          return state.copyWith(
              fetchMoreCommentRepliesStatus: ApiStatus.loaded,
              commentReplies: replyCommentsModel);
        }
      });

      //update to ui
      emit(_state);
    });

    //GET SUBTITLES
    on<GetSubtitles>(
      (event, emit) async {
        emit(state.copyWith(
          fetchSubtitlesStatus: ApiStatus.loading,
        ));

        //get stream info data
        final result = await watchService.getSubtitles(id: event.id);

        final _state = result.fold(
            (MainFailure failure) => state.copyWith(
                  fetchSubtitlesStatus: ApiStatus.error,
                ),
            (List<Map<String, String>> resp) => state.copyWith(
                subtitles: resp, fetchSubtitlesStatus: ApiStatus.loaded));
        //update to ui
        emit(_state);
      },
    );

    //TOGGLE PIP
    on<TogglePip>(
      (event, emit) async {
        emit(state.copyWith(
          isPipEnabled: event.value,
        ));
      },
    );

    //NOT USED
    on<AssignTitle>(
      (event, emit) async {
        emit(state.copyWith(
          title: event.title,
        ));
      },
    );

    // YOUTUBE EXPLODE
    on<GetExplodeWatchInfo>((event, emit) async {
      emit(state.copyWith(
        explodeWatchResp: ExplodeWatchResp.initial(),
        fetchExplodeWatchInfoStatus: ApiStatus.loading,
        isTapComments: false,
        isDescriptionTapped: false,
      ));

      // Get video data using watchService
      final result = await watchService.getExplodeVideoData(id: event.id);

      // Handle the result
      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchExplodeWatchInfoStatus: ApiStatus.error,
        ),
        (ExplodeWatchResp resp) => state.copyWith(
          explodeWatchResp: resp,
          fetchExplodeWatchInfoStatus: ApiStatus.loaded,
          oldId: event.id,
        ),
      );

      // Emit the updated state
      emit(_state);
    });

    on<GetExplodeRelatedVideoInfo>((event, emit) async {
      emit(state.copyWith(
        fetchExplodedRelatedVideosStatus: ApiStatus.loading,
      ));
      final result =
          await watchService.getExplodeRelatedVideosData(id: event.id);
      final newState = result.fold(
        (failure) => state.copyWith(
          fetchExplodedRelatedVideosStatus: ApiStatus.error,
          relatedVideos: null,
        ),
        (relatedVideos) => state.copyWith(
          relatedVideos: relatedVideos,
          fetchExplodedRelatedVideosStatus: ApiStatus.loaded,
        ),
      );
      emit(newState);
    });

    on<GetExplodeMuxStreamInfo>((event, emit) async {
      emit(state.copyWith(
          fetchExplodeMuxedStreamsStatus: ApiStatus.loading,
          muxedStreams: null));
      final result = await watchService.getExplodeMuxedStreamData(id: event.id);
      final newState = result.fold(
        (failure) => state.copyWith(
          fetchExplodeMuxedStreamsStatus: ApiStatus.error,
          muxedStreams: null,
        ),
        (muxedStreams) => state.copyWith(
          muxedStreams: muxedStreams,
          fetchExplodeMuxedStreamsStatus: ApiStatus.loaded,
        ),
      );
      emit(newState);
    });

    on<GetExplodeLiveVideoInfo>((event, emit) async {
      emit(state.copyWith(fetchExplodeLiveStreamStatus: ApiStatus.loading));
      final result = await watchService.getExplodeLiveStreamUrl(id: event.id);
      final newState = result.fold(
        (failure) => state.copyWith(
          fetchExplodeLiveStreamStatus: ApiStatus.error,
          liveStreamUrl: null,
        ),
        (liveStreamUrl) => state.copyWith(
          liveStreamUrl: liveStreamUrl,
          fetchExplodeLiveStreamStatus: ApiStatus.loaded,
        ),
      );
      emit(newState);
    });

    on<SetSelectedVideoBasicDetails>((event, emit) async {
      final newState = state.copyWith(selectedVideoBasicDetails: event.details);
      emit(newState);
    });

    // INVIDIOUS
    on<GetInvidiousWatchInfo>((event, emit) async {
      emit(state.copyWith(
        invidiousWatchResp: InvidiousWatchResp(),
        fetchInvidiousWatchInfoStatus: ApiStatus.loading,
        isTapComments: false,
        isDescriptionTapped: false,
      ));

      final result = await watchService.getInvidiousVideoData(id: event.id);

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchInvidiousWatchInfoStatus: ApiStatus.error,
        ),
        (InvidiousWatchResp resp) => state.copyWith(
          invidiousWatchResp: resp,
          fetchInvidiousWatchInfoStatus: ApiStatus.loaded,
          oldId: event.id,
        ),
      );

      emit(_state);
    });

    on<GetInvidiousComments>((event, emit) async {
      emit(state.copyWith(
          invidiousComments: InvidiousCommentsResp(),
          fetchInvidiousCommentsStatus: ApiStatus.loading,
          isTapComments: !state.isTapComments));

      final result = await watchService.getInvidiousCommentsData(id: event.id);

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchInvidiousCommentsStatus: ApiStatus.error,
        ),
        (InvidiousCommentsResp resp) => state.copyWith(
          invidiousComments: resp,
          fetchInvidiousCommentsStatus: ApiStatus.loaded,
        ),
      );

      emit(_state);
    });

    on<GetInvidiousCommentReplies>((event, emit) async {
      emit(state.copyWith(
        invidiousCommentReplies: InvidiousCommentsResp(),
        fetchInvidiousCommentRepliesStatus: ApiStatus.loading,
      ));

      final result = await watchService.getInvidiousCommentRepliesData(
        id: event.id,
        continuation: event.continuation,
      );

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchInvidiousCommentRepliesStatus: ApiStatus.error,
        ),
        (InvidiousCommentsResp resp) => state.copyWith(
          invidiousCommentReplies: resp,
          fetchInvidiousCommentRepliesStatus: ApiStatus.loaded,
        ),
      );

      emit(_state);
    });

    on<GetMoreInvidiousComments>((event, emit) async {
      emit(state.copyWith(
        fetchMoreInvidiousCommentsStatus: ApiStatus.loading,
        isMoreInvidiousCommetsFetchCompleted: false,
      ));

      final result = await watchService.getInvidiousMoreCommentsData(
        id: event.id,
        continuation: event.continuation!,
      );

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchMoreInvidiousCommentsStatus: ApiStatus.error,
        ),
        (InvidiousCommentsResp resp) {
          if (resp.continuation == null) {
            return state.copyWith(
              fetchMoreInvidiousCommentsStatus: ApiStatus.loaded,
              isMoreInvidiousCommetsFetchCompleted: true,
            );
          } else {
            final commentsModel = state.invidiousComments;
            commentsModel.comments?.addAll(resp.comments ?? []);
            commentsModel.continuation = resp.continuation;
            return state.copyWith(
              fetchMoreInvidiousCommentsStatus: ApiStatus.loaded,
              invidiousComments: commentsModel,
            );
          }
        },
      );

      emit(_state);
    });

    on<GetMoreInvidiousReplyComments>((event, emit) async {
      emit(state.copyWith(
        fetchMoreInvidiousCommentRepliesStatus: ApiStatus.loading,
        isMoreInvidiousReplyCommetsFetchCompleted: false,
      ));

      final result = await watchService.getInvidiousMoreCommentsData(
        id: event.id,
        continuation: event.continuation!,
      );

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchMoreInvidiousCommentRepliesStatus: ApiStatus.error,
        ),
        (InvidiousCommentsResp resp) {
          if (resp.continuation == null) {
            return state.copyWith(
              fetchMoreInvidiousCommentRepliesStatus: ApiStatus.loaded,
              isMoreInvidiousReplyCommetsFetchCompleted: true,
            );
          } else {
            final replyCommentsModel = state.invidiousCommentReplies;
            replyCommentsModel.comments?.addAll(resp.comments ?? []);
            replyCommentsModel.continuation = resp.continuation;
            return state.copyWith(
              fetchMoreInvidiousCommentRepliesStatus: ApiStatus.loaded,
              invidiousCommentReplies: replyCommentsModel,
            );
          }
        },
      );

      emit(_state);
    });

    on<UpdatePlayBack>((event, emit) async {
      emit(state.copyWith(
        playBack: event.playBack ?? 0,
      ));
    });
  }
}
