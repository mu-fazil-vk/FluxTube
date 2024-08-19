import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/domain/watch/models/comments/comments_resp.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/domain/watch/watch_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/watch/models/video/watch_resp.dart';

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
            isLoading: true,
            isWatchInfoError: false,
            initialVideoPause: true,
            isTapComments: false,
            isDescriptionTapped: false));

        //get stream info data
        final result = await watchService.getVideoData(id: event.id);

        final _state = result.fold(
            (MainFailure failure) => state.copyWith(
                  isWatchInfoError: true,
                  isLoading: false,
                ),
            (WatchResp resp) => state.copyWith(
                watchResp: resp, isLoading: false, oldId: event.id));
        //update to ui
        emit(_state);
      },
    );
    //toggle comments
    on<GetCommentData>((event, emit) async {
      //initialte loading, and toggle comments
      emit(state.copyWith(
          isCommentsLoading: true, isTapComments: !state.isTapComments));

      //get comments list

      if (state.isTapComments == true) {
        final _result = await watchService.getCommentsData(id: event.id);

        final _state = _result.fold(
            (MainFailure failure) =>
                state.copyWith(isCommentError: true, isCommentsLoading: false),
            (CommentsResp resp) => state.copyWith(
                isCommentError: false,
                isCommentsLoading: false,
                comments: resp));

        //update to ui
        emit(_state);
      } else {
        emit(state.copyWith(isCommentsLoading: false));
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
      emit(state.copyWith(isCommentRepliesLoading: true));

      //get reply comments list

      final _result = await watchService.getCommentRepliesData(
          id: event.id, repliesPage: event.nextPage);

      final _state = _result.fold(
          (MainFailure failure) => state.copyWith(
              isCommentRepliesError: true, isCommentRepliesLoading: false),
          (CommentsResp resp) => state.copyWith(
              isCommentRepliesError: false,
              isCommentRepliesLoading: false,
              commentReplies: resp));

      //update to ui
      emit(_state);
    });

    // GET MORE COMMENTS
    on<GetMoreCommentsData>((event, emit) async {
      //initialte loading, and toggle comments
      emit(state.copyWith(
          isMoreCommetsFetchLoading: true,
          isMoreCommetsFetchCompleted: false,
          isMoreCommetsFetchError: false));

      //get reply comments list

      final _result = await watchService.getMoreCommentsData(
          id: event.id, nextPage: event.nextPage);

      final _state = _result.fold(
          (MainFailure failure) => state.copyWith(
              isMoreCommetsFetchLoading: false,
              isMoreCommetsFetchError: true), (CommentsResp resp) {
        if (resp.nextpage == null) {
          return state.copyWith(
            isMoreCommetsFetchLoading: false,
            isMoreCommetsFetchCompleted: true,
          );
        } else {
          final commentsModel = state.comments;
          commentsModel.comments.addAll(resp.comments);
          commentsModel.nextpage = resp.nextpage;
          return state.copyWith(
              isMoreCommetsFetchLoading: false, comments: commentsModel);
        }
      });

      //update to ui
      emit(_state);
    });

    // GET MORE REPLY COMMENTS
    on<GetMoreReplyCommentsData>((event, emit) async {
      //initialte loading, and toggle comments
      emit(state.copyWith(
          isMoreReplyCommetsFetchLoading: true,
          isMoreReplyCommetsFetchCompleted: false,
          isMoreReplyCommetsFetchError: false));

      //get reply comments list

      final _result = await watchService.getMoreCommentsData(
          id: event.id, nextPage: event.nextPage);

      final _state = _result.fold(
          (MainFailure failure) => state.copyWith(
              isMoreReplyCommetsFetchLoading: false,
              isMoreReplyCommetsFetchError: true), (CommentsResp resp) {
        if (resp.nextpage == null) {
          return state.copyWith(
            isMoreReplyCommetsFetchLoading: false,
            isMoreReplyCommetsFetchCompleted: true,
          );
        } else {
          final replyCommentsModel = state.commentReplies;
          replyCommentsModel.comments.addAll(resp.comments);
          replyCommentsModel.nextpage = resp.nextpage;
          return state.copyWith(
              isMoreReplyCommetsFetchLoading: false,
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
          isSubtitleLoading: true,
          isSubtitleError: false,
        ));

        //get stream info data
        final result = await watchService.getSubtitles(id: event.id);

        final _state = result.fold(
            (MainFailure failure) => state.copyWith(
                  isSubtitleError: true,
                  isSubtitleLoading: false,
                ),
            (List<Map<String, String>> resp) =>
                state.copyWith(subtitles: resp, isSubtitleLoading: false));
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
        isLoading: true,
        isWatchInfoError: false,
        initialVideoPause: true,
        isTapComments: false,
        isDescriptionTapped: false,
      ));

      // Get video data using watchService
      final result = await watchService.getExplodeVideoData(id: event.id);

      // Handle the result
      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          isWatchInfoError: true,
          isLoading: false,
        ),
        (ExplodeWatchResp resp) => state.copyWith(
          explodeWatchResp: resp,
          isLoading: false,
          oldId: event.id,
        ),
      );

      // Emit the updated state
      emit(_state);
    });
    
    on<GetExplodeRelatedVideoInfo>((event, emit) async {
      emit(state.copyWith(
          isRelatedVideosLoading: true, isRelatedVideosError: false));
      final result = await watchService.getExplodeRelatedVideosData(id: event.id);
      final newState = result.fold(
        (failure) => state.copyWith(
            isRelatedVideosError: true, isRelatedVideosLoading: false),
        (relatedVideos) => state.copyWith(
            relatedVideos: relatedVideos, isRelatedVideosLoading: false),
      );
      emit(newState);
    });

    on<GetExplodeMuxStreamInfo>((event, emit) async {
      emit(state.copyWith(isMuxedStreamsLoading: true, isMuxedStreamsError: false, muxedStreams: null));
      final result = await watchService.getExplodeMuxedStreamData(id: event.id);
      final newState = result.fold(
        (failure) => state.copyWith(
            isMuxedStreamsError: true, isMuxedStreamsLoading: false),
        (muxedStreams) => state.copyWith(
            muxedStreams: muxedStreams, isMuxedStreamsLoading: false),
      );
      emit(newState);
    });
  

    on<GetExplodeLiveVideoInfo>((event, emit) async {
      emit(state.copyWith(isLiveStreamLoading: true, isLiveStreamError: false));
      final result = await watchService.getExplodeLiveStreamUrl(id: event.id);
      final newState = result.fold(
        (failure) => state.copyWith(
            isLiveStreamError: true, isLiveStreamLoading: false),
        (liveStreamUrl) => state.copyWith(
            liveStreamUrl: liveStreamUrl, isLiveStreamLoading: false),
      );
      emit(newState);
    });

    on<SetSelectedVideoBasicDetails>((event, emit) async {
      final newState = state.copyWith(selectedVideoBasicDetails: event.details);
      emit(newState);
    });
  }
}
