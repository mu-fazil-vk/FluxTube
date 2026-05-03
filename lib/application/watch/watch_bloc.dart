import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/sponsorblock/models/sponsor_segment.dart';
import 'package:fluxtube/domain/sponsorblock/sponsorblock_service.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/domain/watch/models/invidious/comments/invidious_comments_resp.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_comments_resp.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
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
  int _newPipeWatchRequestSerial = 0;

  WatchBloc(
    WatchService watchService,
    SponsorBlockService sponsorBlockService,
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
      // Toggle comments - store the new value before emit
      final newTapCommentsValue = !state.isTapComments;

      //initialte loading, and toggle comments
      final loadingState = state.copyWith(
          fetchCommentsStatus: ApiStatus.loading,
          isTapComments: newTapCommentsValue);
      emit(loadingState);

      //get comments list

      if (newTapCommentsValue == true) {
        final _result = await watchService.getCommentsData(id: event.id);

        final _state = _result.fold(
            (MainFailure failure) =>
                loadingState.copyWith(fetchCommentsStatus: ApiStatus.error),
            (CommentsResp resp) => loadingState.copyWith(
                fetchCommentsStatus: ApiStatus.loaded, comments: resp));

        //update to ui
        emit(_state);
      } else {
        emit(loadingState.copyWith(fetchCommentsStatus: ApiStatus.initial));
      }
    });

    // Force fetch comments without toggle (for shorts)
    on<ForceFetchCommentData>((event, emit) async {
      // Clear old comments and set loading
      emit(state.copyWith(
        comments: CommentsResp(
            comments: [], nextpage: null, disabled: false, commentCount: 0),
        fetchCommentsStatus: ApiStatus.loading,
        isMoreCommentsFetchCompleted: false,
      ));

      final _result = await watchService.getCommentsData(id: event.id);

      final _state = _result.fold(
        (MainFailure failure) =>
            state.copyWith(fetchCommentsStatus: ApiStatus.error),
        (CommentsResp resp) => state.copyWith(
          fetchCommentsStatus: ApiStatus.loaded,
          comments: resp,
        ),
      );

      emit(_state);
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
      emit(state.copyWith(
        fetchCommentRepliesStatus: ApiStatus.loading,
        fetchMoreCommentRepliesStatus: ApiStatus.initial,
        isMoreReplyCommentsFetchCompleted: false,
      ));

      //get reply comments list

      final _result = await watchService.getCommentRepliesData(
          id: event.id, repliesPage: event.nextPage);

      final _state = _result.fold(
          (MainFailure failure) => state.copyWith(
                fetchCommentRepliesStatus: ApiStatus.error,
              ),
          (CommentsResp resp) => state.copyWith(
              fetchCommentRepliesStatus: ApiStatus.loaded,
              commentReplies: resp,
              // Mark as completed if no more pages (null or empty)
              isMoreReplyCommentsFetchCompleted:
                  resp.nextpage == null || resp.nextpage!.isEmpty));

      //update to ui
      emit(_state);
    });

    // GET MORE COMMENTS
    on<GetMoreCommentsData>((event, emit) async {
      //initialte loading, and toggle comments
      emit(state.copyWith(
        fetchMoreCommentsStatus: ApiStatus.loading,
        isMoreCommentsFetchCompleted: false,
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
            isMoreCommentsFetchCompleted: true,
          );
        } else {
          final updatedComments = CommentsResp(
            comments: [...state.comments.comments, ...resp.comments],
            nextpage: resp.nextpage,
            disabled: state.comments.disabled,
            commentCount: state.comments.commentCount,
          );
          return state.copyWith(
            fetchMoreCommentsStatus: ApiStatus.loaded,
            comments: updatedComments,
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
        isMoreReplyCommentsFetchCompleted: false,
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
            isMoreReplyCommentsFetchCompleted: true,
          );
        } else {
          final updatedReplies = CommentsResp(
            comments: [...state.commentReplies.comments, ...resp.comments],
            nextpage: resp.nextpage,
            disabled: state.commentReplies.disabled,
            commentCount: state.commentReplies.commentCount,
          );
          return state.copyWith(
              fetchMoreCommentRepliesStatus: ApiStatus.loaded,
              commentReplies: updatedReplies);
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
      // Disable PiP when navigating to a new video to stop any currently playing PiP
      final newState = state.copyWith(
        selectedVideoBasicDetails: event.details,
        isPipEnabled: false,
      );
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

    // Force fetch Invidious comments without toggle (for shorts)
    on<ForceFetchInvidiousComments>((event, emit) async {
      emit(state.copyWith(
        invidiousComments: InvidiousCommentsResp(),
        fetchInvidiousCommentsStatus: ApiStatus.loading,
        isMoreInvidiousCommentsFetchCompleted: false,
      ));

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
        isMoreInvidiousCommentsFetchCompleted: false,
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
              isMoreInvidiousCommentsFetchCompleted: true,
            );
          } else {
            final updatedComments = InvidiousCommentsResp(
              commentCount: state.invidiousComments.commentCount,
              videoId: state.invidiousComments.videoId,
              comments: [
                ...(state.invidiousComments.comments ?? []),
                ...(resp.comments ?? [])
              ],
              continuation: resp.continuation,
            );
            return state.copyWith(
              fetchMoreInvidiousCommentsStatus: ApiStatus.loaded,
              invidiousComments: updatedComments,
            );
          }
        },
      );

      emit(_state);
    });

    on<GetMoreInvidiousReplyComments>((event, emit) async {
      emit(state.copyWith(
        fetchMoreInvidiousCommentRepliesStatus: ApiStatus.loading,
        isMoreInvidiousReplyCommentsFetchCompleted: false,
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
              isMoreInvidiousReplyCommentsFetchCompleted: true,
            );
          } else {
            final updatedReplies = InvidiousCommentsResp(
              commentCount: state.invidiousCommentReplies.commentCount,
              videoId: state.invidiousCommentReplies.videoId,
              comments: [
                ...(state.invidiousCommentReplies.comments ?? []),
                ...(resp.comments ?? [])
              ],
              continuation: resp.continuation,
            );
            return state.copyWith(
              fetchMoreInvidiousCommentRepliesStatus: ApiStatus.loaded,
              invidiousCommentReplies: updatedReplies,
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

    // NEWPIPE
    on<GetNewPipeWatchInfo>((event, emit) async {
      final requestSerial = ++_newPipeWatchRequestSerial;
      emit(state.copyWith(
        newPipeWatchResp: NewPipeWatchResp(),
        fetchNewPipeWatchInfoStatus: ApiStatus.loading,
        isTapComments: false,
        isDescriptionTapped: false,
      ));

      final stopwatch = Stopwatch()..start();
      final result = await watchService.getNewPipeVideoData(id: event.id);
      if (requestSerial != _newPipeWatchRequestSerial) return;

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchNewPipeWatchInfoStatus: ApiStatus.error,
        ),
        (NewPipeWatchResp resp) => state.copyWith(
          newPipeWatchResp: resp,
          fetchNewPipeWatchInfoStatus: ApiStatus.loaded,
          oldId: event.id,
        ),
      );

      stopwatch.stop();
      // ignore: avoid_print
      print(
          '[WatchBloc] NewPipe full watch ${event.id}: ${stopwatch.elapsedMilliseconds}ms');
      emit(_state);
    });

    // NewPipe video info with parallel SponsorBlock fetch
    on<GetNewPipeWatchInfoFast>((event, emit) async {
      final requestSerial = ++_newPipeWatchRequestSerial;
      emit(state.copyWith(
        newPipeWatchResp: NewPipeWatchResp(),
        fetchNewPipeWatchInfoStatus: ApiStatus.loading,
        fetchSponsorSegmentsStatus: event.sponsorBlockCategories.isNotEmpty
            ? ApiStatus.loading
            : ApiStatus.initial,
        sponsorSegments: [],
        isTapComments: false,
        isDescriptionTapped: false,
      ));

      // Fetch video info and SponsorBlock segments in parallel
      final stopwatch = Stopwatch()..start();
      final List<Future<dynamic>> futures = [
        watchService.getNewPipeVideoDataFast(id: event.id),
      ];

      // Only fetch SponsorBlock if categories are provided
      if (event.sponsorBlockCategories.isNotEmpty) {
        futures.add(sponsorBlockService.getSegments(
          videoId: event.id,
          categories: event.sponsorBlockCategories,
        ));
      }

      final results = await Future.wait(futures);
      if (requestSerial != _newPipeWatchRequestSerial) return;

      final videoResult = results[0] as Either<MainFailure, NewPipeWatchResp>;

      // Process video result
      var newState = videoResult.fold(
        (MainFailure failure) => state.copyWith(
          fetchNewPipeWatchInfoStatus: ApiStatus.error,
          newPipeErrorMessage: failure.maybeWhen(
            unknown: (message) => message,
            orElse: () => null,
          ),
        ),
        (NewPipeWatchResp resp) => state.copyWith(
          newPipeWatchResp: resp,
          fetchNewPipeWatchInfoStatus: ApiStatus.loaded,
          newPipeErrorMessage: null,
          oldId: event.id,
        ),
      );

      // Process SponsorBlock result if fetched
      if (event.sponsorBlockCategories.isNotEmpty && results.length > 1) {
        final sponsorResult =
            results[1] as Either<MainFailure, List<SponsorSegment>>;
        newState = sponsorResult.fold(
          (MainFailure failure) => newState.copyWith(
            fetchSponsorSegmentsStatus: ApiStatus.error,
            sponsorSegments: [],
          ),
          (List<SponsorSegment> segments) => newState.copyWith(
            sponsorSegments: segments,
            fetchSponsorSegmentsStatus: ApiStatus.loaded,
          ),
        );
      }

      stopwatch.stop();
      // ignore: avoid_print
      print(
          '[WatchBloc] NewPipe fast watch ${event.id}: ${stopwatch.elapsedMilliseconds}ms');
      emit(newState);

      final shouldFetchFullWatch = videoResult.fold(
        (_) => false,
        (resp) => (resp.relatedStreams == null || resp.relatedStreams!.isEmpty),
      );
      if (!shouldFetchFullWatch) return;

      final fullStopwatch = Stopwatch()..start();
      final fullResult = await watchService.getNewPipeVideoData(id: event.id);
      if (requestSerial != _newPipeWatchRequestSerial) return;

      fullResult.fold(
        (_) {
          fullStopwatch.stop();
          // ignore: avoid_print
          print(
              '[WatchBloc] NewPipe full follow-up ${event.id} failed after ${fullStopwatch.elapsedMilliseconds}ms');
        },
        (resp) {
          fullStopwatch.stop();
          // ignore: avoid_print
          print(
              '[WatchBloc] NewPipe full follow-up ${event.id}: ${fullStopwatch.elapsedMilliseconds}ms');
          emit(state.copyWith(
            newPipeWatchResp: resp,
            fetchNewPipeWatchInfoStatus: ApiStatus.loaded,
            newPipeErrorMessage: null,
            oldId: event.id,
          ));
        },
      );
    });

    on<GetNewPipeComments>((event, emit) async {
      // Toggle comments - store the new value before emit
      final newTapCommentsValue = !state.isTapComments;

      // Create the new state with loading status
      final loadingState = state.copyWith(
        newPipeComments: NewPipeCommentsResp(),
        fetchNewPipeCommentsStatus: ApiStatus.loading,
        isTapComments: newTapCommentsValue,
      );
      emit(loadingState);

      if (newTapCommentsValue == true) {
        final result = await watchService.getNewPipeCommentsData(id: event.id);

        final _state = result.fold(
          (MainFailure failure) => loadingState.copyWith(
            fetchNewPipeCommentsStatus: ApiStatus.error,
          ),
          (NewPipeCommentsResp resp) => loadingState.copyWith(
            newPipeComments: resp,
            fetchNewPipeCommentsStatus: ApiStatus.loaded,
          ),
        );

        emit(_state);
      } else {
        emit(loadingState.copyWith(
            fetchNewPipeCommentsStatus: ApiStatus.initial));
      }
    });

    // Force fetch NewPipe comments without toggle (for shorts)
    on<ForceFetchNewPipeComments>((event, emit) async {
      emit(state.copyWith(
        newPipeComments: NewPipeCommentsResp(),
        fetchNewPipeCommentsStatus: ApiStatus.loading,
        isMoreNewPipeCommentsFetchCompleted: false,
      ));

      final result = await watchService.getNewPipeCommentsData(id: event.id);

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchNewPipeCommentsStatus: ApiStatus.error,
        ),
        (NewPipeCommentsResp resp) => state.copyWith(
          newPipeComments: resp,
          fetchNewPipeCommentsStatus: ApiStatus.loaded,
        ),
      );

      emit(_state);
    });

    on<GetMoreNewPipeComments>((event, emit) async {
      emit(state.copyWith(
        fetchMoreNewPipeCommentsStatus: ApiStatus.loading,
        isMoreNewPipeCommentsFetchCompleted: false,
      ));

      final result = await watchService.getNewPipeMoreCommentsData(
        id: event.id,
        nextPage: event.nextPage!,
      );

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchMoreNewPipeCommentsStatus: ApiStatus.error,
        ),
        (NewPipeCommentsResp resp) {
          if (resp.nextPage == null) {
            return state.copyWith(
              fetchMoreNewPipeCommentsStatus: ApiStatus.loaded,
              isMoreNewPipeCommentsFetchCompleted: true,
            );
          } else {
            final updatedComments = NewPipeCommentsResp(
              comments: [
                ...(state.newPipeComments.comments ?? []),
                ...(resp.comments ?? [])
              ],
              nextPage: resp.nextPage,
              commentCount: state.newPipeComments.commentCount,
              isDisabled: state.newPipeComments.isDisabled,
            );
            return state.copyWith(
              fetchMoreNewPipeCommentsStatus: ApiStatus.loaded,
              newPipeComments: updatedComments,
            );
          }
        },
      );

      emit(_state);
    });

    on<GetNewPipeCommentReplies>((event, emit) async {
      emit(state.copyWith(
        newPipeCommentReplies: NewPipeCommentsResp(),
        fetchNewPipeCommentRepliesStatus: ApiStatus.loading,
        isMoreNewPipeReplyCommentsFetchCompleted: false,
      ));

      final result = await watchService.getNewPipeCommentRepliesData(
        videoId: event.videoId,
        repliesPage: event.repliesPage,
      );

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchNewPipeCommentRepliesStatus: ApiStatus.error,
        ),
        (NewPipeCommentsResp resp) => state.copyWith(
          newPipeCommentReplies: resp,
          fetchNewPipeCommentRepliesStatus: ApiStatus.loaded,
        ),
      );

      emit(_state);
    });

    on<GetMoreNewPipeCommentReplies>((event, emit) async {
      emit(state.copyWith(
        fetchMoreNewPipeCommentRepliesStatus: ApiStatus.loading,
        isMoreNewPipeReplyCommentsFetchCompleted: false,
      ));

      final result = await watchService.getNewPipeCommentRepliesData(
        videoId: event.videoId,
        repliesPage: event.nextPage!,
      );

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchMoreNewPipeCommentRepliesStatus: ApiStatus.error,
        ),
        (NewPipeCommentsResp resp) {
          if (resp.nextPage == null) {
            return state.copyWith(
              fetchMoreNewPipeCommentRepliesStatus: ApiStatus.loaded,
              isMoreNewPipeReplyCommentsFetchCompleted: true,
            );
          } else {
            final updatedReplies = NewPipeCommentsResp(
              comments: [
                ...(state.newPipeCommentReplies.comments ?? []),
                ...(resp.comments ?? [])
              ],
              nextPage: resp.nextPage,
              commentCount: state.newPipeCommentReplies.commentCount,
              isDisabled: state.newPipeCommentReplies.isDisabled,
            );
            return state.copyWith(
              fetchMoreNewPipeCommentRepliesStatus: ApiStatus.loaded,
              newPipeCommentReplies: updatedReplies,
            );
          }
        },
      );

      emit(_state);
    });

    // SPONSORBLOCK
    on<GetSponsorSegments>((event, emit) async {
      emit(state.copyWith(
        fetchSponsorSegmentsStatus: ApiStatus.loading,
        sponsorSegments: [],
      ));

      final result = await sponsorBlockService.getSegments(
        videoId: event.videoId,
        categories: event.categories,
      );

      final _state = result.fold(
        (MainFailure failure) => state.copyWith(
          fetchSponsorSegmentsStatus: ApiStatus.error,
          sponsorSegments: [],
        ),
        (List<SponsorSegment> segments) => state.copyWith(
          sponsorSegments: segments,
          fetchSponsorSegmentsStatus: ApiStatus.loaded,
        ),
      );

      emit(_state);
    });
  }
}
