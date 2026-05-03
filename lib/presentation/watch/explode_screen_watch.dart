import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/core/player/playback_queue_controller.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/description_section.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/like_section.dart';
import 'package:fluxtube/presentation/watch/widgets/explode/subscribe_section.dart';
import 'package:fluxtube/presentation/watch/widgets/explode_media_kit_player.dart';
import 'package:fluxtube/presentation/watch/widgets/invidious/comment_widgets.dart';
import 'package:fluxtube/presentation/watch/widgets/player_error_widget.dart';
import 'package:fluxtube/widgets/widgets.dart';

import 'widgets/explode/related_video_section.dart';

class ExplodeScreenWatch extends StatefulWidget {
  const ExplodeScreenWatch({
    super.key,
    required this.id,
    required this.channelId,
  });

  final String id;
  final String channelId;

  @override
  State<ExplodeScreenWatch> createState() => _ExplodeScreenWatchState();
}

class _ExplodeScreenWatchState extends State<ExplodeScreenWatch>
    with WidgetsBindingObserver {
  bool _sponsorBlockFetched = false;
  // Track if player should be shown - once shown, keep it shown until video ID changes
  // This prevents the player from being disposed during BlocBuilder rebuilds
  bool _showPlayer = false;
  // Track the video ID for which the player is shown
  String? _playerVideoId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Defer initialization to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeVideo();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
          if (isCurrent) {
            BlocProvider.of<WatchBloc>(context)
                .add(WatchEvent.togglePip(value: false));
          }
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant ExplodeScreenWatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the video ID changed (e.g., user clicked a related video), reinitialize
    if (oldWidget.id != widget.id) {
      debugPrint(
          '[ExplodeScreenWatch] Video ID changed from ${oldWidget.id} to ${widget.id}');
      _sponsorBlockFetched = false;
      // Reset player visibility tracking for new video
      setState(() {
        _showPlayer = false;
        _playerVideoId = null;
      });
      _initializeVideo();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
        if (isCurrent) {
          final globalPlayer = GlobalPlayerController();
          final currentPlayingId = globalPlayer.currentVideoId;

          // If a DIFFERENT video is currently playing, this is an old watch screen
          // that the user navigated back to. Auto-pop it to go to the actual current video.
          if (currentPlayingId != null &&
              currentPlayingId != widget.id &&
              globalPlayer.isPlaying) {
            debugPrint(
                '[ExplodeScreenWatch] Old watch screen detected (this: ${widget.id}, playing: $currentPlayingId). Auto-popping.');
            Navigator.of(context).pop();
            return;
          }

          final watchBloc = BlocProvider.of<WatchBloc>(context);
          if (watchBloc.state.isPipEnabled) {
            watchBloc.add(WatchEvent.togglePip(value: false));
          }
        }
      }
    });
  }

  void _initializeVideo() async {
    final watchBloc = BlocProvider.of<WatchBloc>(context);
    final savedBloc = BlocProvider.of<SavedBloc>(context);
    final subscribeBloc = BlocProvider.of<SubscribeBloc>(context);
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final currentProfile = settingsBloc.state.currentProfile;

    final globalPlayer = GlobalPlayerController();
    final currentPlayingId = globalPlayer.currentVideoId;

    // If a different video is playing, stop it first
    if (currentPlayingId != null && currentPlayingId != widget.id) {
      debugPrint(
          '[ExplodeScreenWatch] Stopping previous video: $currentPlayingId (starting: ${widget.id})');
      await globalPlayer.stopAndClear();
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // Validate before starting any video
    await globalPlayer.validateBeforePlay(widget.id);

    // Check if returning from PiP with same video already loaded
    final isReturningFromPip = globalPlayer.hasVideoLoaded(widget.id) &&
        watchBloc.state.explodeWatchResp.title.isNotEmpty;

    if (!globalPlayer.isSystemPipMode) {
      watchBloc.add(WatchEvent.togglePip(value: false));
    }

    // Only fetch data if not returning from PiP with data already loaded
    if (!isReturningFromPip) {
      watchBloc.add(WatchEvent.getExplodeWatchInfo(id: widget.id));
      watchBloc.add(WatchEvent.getExplodeMuxStreamInfo(id: widget.id));
      watchBloc.add(WatchEvent.getExplodeRelatedVideoInfo(id: widget.id));
      watchBloc.add(WatchEvent.getSubtitles(id: widget.id));
    } else {
      // Already have data, mark sponsor block as fetched if it was already done
      _sponsorBlockFetched = watchBloc.state.sponsorSegments.isNotEmpty ||
          watchBloc.state.fetchSponsorSegmentsStatus == ApiStatus.loaded;
    }

    // Fetch SponsorBlock segments if enabled
    _fetchSponsorBlockIfEnabled();

    // Only fetch all videos list if not returning from PiP
    if (!isReturningFromPip) {
      savedBloc
          .add(SavedEvent.getAllVideoInfoList(profileName: currentProfile));
    }

    // Only check video info if we don't already have it for this video
    // This prevents flickering when returning from PiP
    if (savedBloc.state.videoInfo?.id != widget.id) {
      savedBloc.add(SavedEvent.checkVideoInfo(
          id: widget.id, profileName: currentProfile));
    }

    subscribeBloc.add(SubscribeEvent.checkSubscribeInfo(
        id: widget.channelId, profileName: currentProfile));
  }

  void _fetchSponsorBlockIfEnabled() {
    final settingsState = BlocProvider.of<SettingsBloc>(context).state;
    if (settingsState.isSponsorBlockEnabled && !_sponsorBlockFetched) {
      _sponsorBlockFetched = true;
      BlocProvider.of<WatchBloc>(context).add(
        WatchEvent.getSponsorSegments(
          videoId: widget.id,
          categories: settingsState.sponsorBlockCategories,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final double height = MediaQuery.of(context).size.height;

    return BlocListener<WatchBloc, WatchState>(
      listenWhen: (previous, current) =>
          (previous.fetchExplodeWatchInfoStatus !=
                  current.fetchExplodeWatchInfoStatus &&
              current.fetchExplodeWatchInfoStatus == ApiStatus.loaded) ||
          (previous.fetchExplodedRelatedVideosStatus !=
                  current.fetchExplodedRelatedVideosStatus &&
              current.fetchExplodedRelatedVideosStatus == ApiStatus.loaded),
      listener: (context, state) {
        // Set selectedVideoBasicDetails when video info is loaded
        // This ensures PIP works when navigating from external links
        final watchInfo = state.explodeWatchResp;
        if (watchInfo.title.isNotEmpty) {
          BlocProvider.of<WatchBloc>(context).add(
            WatchEvent.setSelectedVideoBasicDetails(
              details: VideoBasicInfo(
                id: widget.id,
                title: watchInfo.title,
                thumbnailUrl: watchInfo.thumbnailUrl,
                channelName: watchInfo.author,
                channelId: watchInfo.channelId,
              ),
            ),
          );
          PlaybackQueueController.instance.setQueue(
            currentVideoId: widget.id,
            videos: (state.relatedVideos ?? []).map((related) {
              return VideoBasicInfo(
                id: related.id,
                title: related.title,
                thumbnailUrl: related.thumbnailUrl,
                channelName: related.author,
                channelId: related.channelId,
              );
            }),
          );
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
        return BlocBuilder<WatchBloc, WatchState>(
            buildWhen: (previous, current) {
          return previous.fetchExplodeWatchInfoStatus !=
                  current.fetchExplodeWatchInfoStatus ||
              previous.fetchSubtitlesStatus != current.fetchSubtitlesStatus ||
              previous.explodeWatchResp != current.explodeWatchResp ||
              previous.muxedStreams != current.muxedStreams ||
              previous.liveStreamUrl != current.liveStreamUrl ||
              previous.sponsorSegments != current.sponsorSegments;
        }, builder: (context, state) {
          return BlocBuilder<SavedBloc, SavedState>(
            buildWhen: (previous, current) =>
                previous.videoInfo?.id != current.videoInfo?.id ||
                previous.videoInfo?.isSaved != current.videoInfo?.isSaved ||
                previous.videoInfo?.playbackPosition !=
                    current.videoInfo?.playbackPosition,
            builder: (context, savedState) {
              final watchInfo = state.explodeWatchResp;

              bool isSaved = (savedState.videoInfo?.id == widget.id &&
                      savedState.videoInfo?.isSaved == true)
                  ? true
                  : false;

              // Check if there's a stream URL error (no muxed streams and no live URL)
              final bool hasStreamError = state.fetchExplodeWatchInfoStatus ==
                      ApiStatus.loaded &&
                  state.fetchExplodeMuxedStreamsStatus == ApiStatus.loaded &&
                  (state.muxedStreams == null || state.muxedStreams!.isEmpty) &&
                  state.liveStreamUrl == null;

              if (state.fetchExplodeWatchInfoStatus == ApiStatus.error) {
                return ErrorRetryWidget(
                  lottie: 'assets/cat-404.zip',
                  onTap: () {
                    BlocProvider.of<WatchBloc>(context)
                        .add(WatchEvent.getExplodeWatchInfo(id: widget.id));
                    BlocProvider.of<WatchBloc>(context)
                        .add(WatchEvent.getExplodeMuxStreamInfo(id: widget.id));
                    BlocProvider.of<WatchBloc>(context).add(
                        WatchEvent.getExplodeRelatedVideoInfo(id: widget.id));
                  },
                );
              } else {
                return DismissiblePage(
                  direction: DismissiblePageDismissDirection.down,
                  onDismissed: () {
                    if (!settingsState.isPipDisabled) {
                      GlobalPlayerController().enterPipMode();
                      BlocProvider.of<WatchBloc>(context)
                          .add(WatchEvent.togglePip(value: true));
                    }
                    Navigator.pop(context);
                  },
                  isFullScreen: true,
                  key: ValueKey(widget.id),
                  child: PopScope(
                    canPop: true,
                    onPopInvokedWithResult: (didPop, _) {
                      if (!settingsState.isPipDisabled) {
                        GlobalPlayerController().enterPipMode();
                        BlocProvider.of<WatchBloc>(context)
                            .add(WatchEvent.togglePip(value: true));
                      }
                    },
                    child: Scaffold(
                      body: SafeArea(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Use Builder to ensure player visibility is tracked in state
                              // This prevents the player from being disposed during BlocBuilder rebuilds
                              Builder(
                                builder: (context) {
                                  // Determine if we should show loading
                                  final bool isLoading = ((state
                                                  .fetchExplodeWatchInfoStatus ==
                                              ApiStatus.initial ||
                                          state.fetchExplodeWatchInfoStatus ==
                                              ApiStatus.loading ||
                                          state.fetchSubtitlesStatus ==
                                              ApiStatus.loading) &&
                                      state.oldId != widget.id &&
                                      !GlobalPlayerController()
                                          .hasVideoLoaded(widget.id));

                                  // Once player should be shown, track it in state
                                  // This ensures player stays in widget tree during rebuilds
                                  if (!isLoading &&
                                      !hasStreamError &&
                                      !_showPlayer) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted && !_showPlayer) {
                                        setState(() {
                                          _showPlayer = true;
                                          _playerVideoId = widget.id;
                                        });
                                      }
                                    });
                                  }

                                  // Use stable visibility: once shown, keep showing until video changes
                                  final bool shouldShowPlayer = _showPlayer &&
                                      _playerVideoId == widget.id;

                                  if (isLoading && !shouldShowPlayer) {
                                    return Container(
                                      height: 230,
                                      color: kBlackColor,
                                      child: Center(
                                        child: cIndicator(context),
                                      ),
                                    );
                                  } else if (hasStreamError &&
                                      !shouldShowPlayer) {
                                    return PlayerErrorWidget(
                                      message:
                                          'Video streams unavailable. This video may be restricted or age-gated.',
                                      onRetry: () {
                                        BlocProvider.of<WatchBloc>(context).add(
                                            WatchEvent.getExplodeMuxStreamInfo(
                                                id: widget.id));
                                      },
                                    );
                                  } else {
                                    return ExplodeMediaKitPlayer(
                                      videoId: widget.id,
                                      watchInfo: state.explodeWatchResp,
                                      defaultQuality:
                                          settingsState.defaultQuality,
                                      // Only use playback position if it's for the current video
                                      playbackPosition:
                                          savedState.videoInfo?.id == widget.id
                                              ? (savedState.videoInfo
                                                      ?.playbackPosition ??
                                                  0)
                                              : 0,
                                      isSaved: isSaved,
                                      liveUrl: state.liveStreamUrl,
                                      availableVideoTracks:
                                          state.muxedStreams ?? [],
                                      subtitles: (state.fetchSubtitlesStatus ==
                                                  ApiStatus.loading ||
                                              state.fetchSubtitlesStatus ==
                                                  ApiStatus.initial)
                                          ? []
                                          : state.subtitles,
                                      videoFitMode: settingsState.videoFitMode,
                                      skipInterval: settingsState.skipInterval,
                                      isAudioFocusEnabled:
                                          settingsState.isAudioFocusEnabled,
                                      subtitleSize: settingsState.subtitleSize,
                                      sponsorSegments:
                                          settingsState.isSponsorBlockEnabled
                                              ? state.sponsorSegments
                                              : const [],
                                    );
                                  }
                                },
                              ),
                              BlocBuilder<WatchBloc, WatchState>(
                                builder: (context, state) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, left: 20, right: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // * caption row
                                        (state.fetchExplodeWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchExplodeWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? CaptionRowWidget(
                                                caption: state
                                                        .selectedVideoBasicDetails
                                                        ?.title ??
                                                    '',
                                                icon: state.isDescriptionTapped
                                                    ? CupertinoIcons.chevron_up
                                                    : CupertinoIcons
                                                        .chevron_down,
                                              )
                                            : GestureDetector(
                                                onTap: () =>
                                                    BlocProvider.of<WatchBloc>(
                                                            context)
                                                        .add(WatchEvent
                                                            .tapDescription()),
                                                child: CaptionRowWidget(
                                                  caption: watchInfo.title,
                                                  icon:
                                                      state.isDescriptionTapped
                                                          ? CupertinoIcons
                                                              .chevron_up
                                                          : CupertinoIcons
                                                              .chevron_down,
                                                ),
                                              ),

                                        kHeightBox5,

                                        // * views row
                                        (state.fetchExplodeWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchExplodeWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? const SizedBox()
                                            : ViewRowWidget(
                                                views: watchInfo.viewCount,
                                                uploadedDate: watchInfo
                                                    .uploadDate
                                                    .toString(),
                                              ),

                                        kHeightBox10,

                                        // * like row
                                        (state.fetchExplodeWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchExplodeWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? const ShimmerLikeWidget()
                                            : ExplodeLikeSection(
                                                id: widget.id,
                                                state: state,
                                                watchInfo: watchInfo,
                                                pipClicked: () {
                                                  GlobalPlayerController()
                                                      .enterPipMode();
                                                  BlocProvider.of<WatchBloc>(
                                                          context)
                                                      .add(WatchEvent.togglePip(
                                                          value: true));
                                                  Navigator.pop(context);
                                                },
                                              ),

                                        kHeightBox10,

                                        const Divider(),

                                        // * channel info row
                                        (state.fetchExplodeWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchExplodeWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? const ShimmerSubscribeWidget()
                                            : ExplodeChannelInfoSection(
                                                state: state,
                                                watchInfo: watchInfo,
                                                locals: locals),
                                        if (!state.isTapComments)
                                          const Divider(),
                                        kHeightBox10,

                                        // * description
                                        state.isDescriptionTapped
                                            ? ExplodeDescriptionSection(
                                                height: height,
                                                watchInfo: watchInfo,
                                                locals: locals)
                                            :
                                            // * related videos
                                            state.isTapComments == false
                                                ? settingsState.isHideRelated
                                                    ? const SizedBox()
                                                    : (state.fetchExplodedRelatedVideosStatus ==
                                                                ApiStatus
                                                                    .initial ||
                                                            state.fetchExplodedRelatedVideosStatus ==
                                                                ApiStatus
                                                                    .loading)
                                                        ? ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemCount: 3,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return const ShimmerRelatedVideoWidget();
                                                            },
                                                          )
                                                        : ExplodeRelatedVideoSection(
                                                            locals: locals,
                                                            watchInfo:
                                                                watchInfo,
                                                            related: state
                                                                    .relatedVideos ??
                                                                [],
                                                          )
                                                //comments section
                                                : InvidiousCommentSection(
                                                    videoId: widget.id,
                                                    state: state,
                                                    height: height,
                                                    locals: locals,
                                                  ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          );
        });
      }),
    );
  }
}
