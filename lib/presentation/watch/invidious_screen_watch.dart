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
import 'package:fluxtube/widgets/widgets.dart';

import 'widgets/invidious/comment_widgets.dart';
import 'widgets/invidious/description_section.dart';
import 'widgets/invidious/like_section.dart';
import 'widgets/invidious/related_video_section.dart';
import 'widgets/invidious/subscribe_section.dart';
import 'widgets/invidious_media_kit_player.dart';
import 'widgets/player_error_widget.dart';

class InvidiousScreenWatch extends StatefulWidget {
  const InvidiousScreenWatch({
    super.key,
    required this.id,
    required this.channelId,
  });

  final String id;
  final String channelId;

  @override
  State<InvidiousScreenWatch> createState() => _InvidiousScreenWatchState();
}

class _InvidiousScreenWatchState extends State<InvidiousScreenWatch>
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
  void didUpdateWidget(covariant InvidiousScreenWatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the video ID changed (e.g., user clicked a related video), reinitialize
    if (oldWidget.id != widget.id) {
      debugPrint(
          '[InvidiousScreenWatch] Video ID changed from ${oldWidget.id} to ${widget.id}');
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
                '[InvidiousScreenWatch] Old watch screen detected (this: ${widget.id}, playing: $currentPlayingId). Auto-popping.');
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
          '[InvidiousScreenWatch] Stopping previous video: $currentPlayingId (starting: ${widget.id})');
      await globalPlayer.stopAndClear();
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // Validate before starting any video
    await globalPlayer.validateBeforePlay(widget.id);

    // Check if returning from PiP with same video already loaded
    final isReturningFromPip = globalPlayer.hasVideoLoaded(widget.id) &&
        watchBloc.state.invidiousWatchResp.title != null;

    if (!globalPlayer.isSystemPipMode) {
      watchBloc.add(WatchEvent.togglePip(value: false));
    }

    // Only fetch data if not returning from PiP with data already loaded
    if (!isReturningFromPip) {
      watchBloc.add(WatchEvent.getInvidiousWatchInfo(id: widget.id));
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
          previous.fetchInvidiousWatchInfoStatus !=
              current.fetchInvidiousWatchInfoStatus &&
          current.fetchInvidiousWatchInfoStatus == ApiStatus.loaded,
      listener: (context, state) {
        // Set selectedVideoBasicDetails when video info is loaded
        // This ensures PIP works when navigating from external links
        final watchInfo = state.invidiousWatchResp;
        if (watchInfo.title != null && watchInfo.title!.isNotEmpty) {
          BlocProvider.of<WatchBloc>(context).add(
            WatchEvent.setSelectedVideoBasicDetails(
              details: VideoBasicInfo(
                id: widget.id,
                title: watchInfo.title,
                thumbnailUrl: watchInfo.videoThumbnails?.isNotEmpty == true
                    ? watchInfo.videoThumbnails!.first.url
                    : null,
                channelName: watchInfo.author,
                channelId: watchInfo.authorId,
              ),
            ),
          );
          PlaybackQueueController.instance.setQueue(
            currentVideoId: widget.id,
            videos: (watchInfo.recommendedVideos ?? []).map((related) {
              return VideoBasicInfo(
                id: related.videoId ?? '',
                title: related.title,
                thumbnailUrl: related.videoThumbnails?.isNotEmpty == true
                    ? related.videoThumbnails!.first.url
                    : null,
                channelName: related.author,
                channelId: related.authorId,
                uploaderVerified: related.authorVerified,
              );
            }),
          );
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            previous.defaultQuality != current.defaultQuality ||
            previous.isHlsPlayer != current.isHlsPlayer ||
            previous.isPipDisabled != current.isPipDisabled ||
            previous.isHideRelated != current.isHideRelated ||
            previous.videoFitMode != current.videoFitMode ||
            previous.skipInterval != current.skipInterval,
        builder: (context, settingsState) {
          return BlocBuilder<WatchBloc, WatchState>(
            buildWhen: (previous, current) =>
                previous.fetchInvidiousWatchInfoStatus !=
                    current.fetchInvidiousWatchInfoStatus ||
                previous.fetchSubtitlesStatus != current.fetchSubtitlesStatus ||
                previous.invidiousWatchResp != current.invidiousWatchResp ||
                previous.isDescriptionTapped != current.isDescriptionTapped ||
                previous.isTapComments != current.isTapComments ||
                previous.subtitles != current.subtitles ||
                previous.sponsorSegments != current.sponsorSegments,
            builder: (context, state) {
              return BlocBuilder<SavedBloc, SavedState>(
                buildWhen: (previous, current) =>
                    previous.videoInfo?.id != current.videoInfo?.id ||
                    previous.videoInfo?.isSaved != current.videoInfo?.isSaved ||
                    previous.videoInfo?.playbackPosition !=
                        current.videoInfo?.playbackPosition,
                builder: (context, savedState) {
                  final watchInfo = state.invidiousWatchResp;

                  bool isSaved = (savedState.videoInfo?.id == widget.id &&
                          savedState.videoInfo?.isSaved == true)
                      ? true
                      : false;

                  // Check if there's a player URL issue (DASH null when HLS/DASH mode enabled)
                  final bool hasPlayerUrlError =
                      state.fetchInvidiousWatchInfoStatus == ApiStatus.loaded &&
                          settingsState.isHlsPlayer &&
                          watchInfo.dashUrl == null;

                  // Only show full-screen error for API fetch failures
                  if (state.fetchInvidiousWatchInfoStatus == ApiStatus.error) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(locals.retry),
                      ),
                      body: SafeArea(
                        child: SingleChildScrollView(
                          child: InstanceAutoCheckWidget(
                            videoId: widget.id,
                            lottie: 'assets/cat-404.zip',
                            onRetry: () => BlocProvider.of<WatchBloc>(context)
                                .add(WatchEvent.getInvidiousWatchInfo(
                                    id: widget.id)),
                          ),
                        ),
                      ),
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
                                      final bool isLoading =
                                          ((state.fetchInvidiousWatchInfoStatus ==
                                                      ApiStatus.initial ||
                                                  state.fetchInvidiousWatchInfoStatus ==
                                                      ApiStatus.loading ||
                                                  state.fetchSubtitlesStatus ==
                                                      ApiStatus.loading) &&
                                              state.oldId != widget.id &&
                                              !GlobalPlayerController()
                                                  .hasVideoLoaded(widget.id));

                                      // Once player should be shown, track it in state
                                      // This ensures player stays in widget tree during rebuilds
                                      if (!isLoading &&
                                          !hasPlayerUrlError &&
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
                                      final bool shouldShowPlayer =
                                          _showPlayer &&
                                              _playerVideoId == widget.id;

                                      if (isLoading && !shouldShowPlayer) {
                                        return Container(
                                          height: 200,
                                          color: kBlackColor,
                                          child: Center(
                                            child: cIndicator(context),
                                          ),
                                        );
                                      } else if (hasPlayerUrlError &&
                                          !shouldShowPlayer) {
                                        return PlayerErrorWidget(
                                          message:
                                              'DASH stream unavailable for this video. Try disabling HLS in settings.',
                                          onRetry: () =>
                                              BlocProvider.of<WatchBloc>(
                                                      context)
                                                  .add(WatchEvent
                                                      .getInvidiousWatchInfo(
                                                          id: widget.id)),
                                        );
                                      } else {
                                        return InvidiousMediaKitPlayer(
                                          videoId: widget.id,
                                          watchInfo: state.invidiousWatchResp,
                                          defaultQuality:
                                              settingsState.defaultQuality,
                                          // Only use playback position if it's for the current video
                                          playbackPosition:
                                              savedState.videoInfo?.id ==
                                                      widget.id
                                                  ? (savedState.videoInfo
                                                          ?.playbackPosition ??
                                                      0)
                                                  : 0,
                                          isSaved: isSaved,
                                          isHlsPlayer:
                                              settingsState.isHlsPlayer,
                                          subtitles:
                                              state.fetchSubtitlesStatus ==
                                                      ApiStatus.loading
                                                  ? []
                                                  : state.subtitles,
                                          videoFitMode:
                                              settingsState.videoFitMode,
                                          skipInterval:
                                              settingsState.skipInterval,
                                          isAudioFocusEnabled:
                                              settingsState.isAudioFocusEnabled,
                                          subtitleSize:
                                              settingsState.subtitleSize,
                                          sponsorSegments: settingsState
                                                  .isSponsorBlockEnabled
                                              ? state.sponsorSegments
                                              : const [],
                                        );
                                      }
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, left: 20, right: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // * caption row
                                        (state.fetchInvidiousWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchInvidiousWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? CaptionRowWidget(
                                                caption: state
                                                        .selectedVideoBasicDetails
                                                        ?.title ??
                                                    locals.noVideoTitle,
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
                                                  caption: watchInfo.title ??
                                                      locals.noVideoTitle,
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
                                        (state.fetchInvidiousWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchInvidiousWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? const SizedBox()
                                            : ViewRowWidget(
                                                views: watchInfo.viewCount,
                                                uploadedDate: watchInfo
                                                    .published
                                                    .toString(),
                                              ),

                                        kHeightBox10,

                                        // * like row
                                        (state.fetchInvidiousWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchInvidiousWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? const ShimmerLikeWidget()
                                            : InvidiousLikeSection(
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
                                        (state.fetchInvidiousWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchInvidiousWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? const ShimmerSubscribeWidget()
                                            : InvidiousChannelInfoSection(
                                                state: state,
                                                watchInfo: watchInfo,
                                                locals: locals),
                                        if (!state.isTapComments)
                                          const Divider(),
                                        kHeightBox10,

                                        // * description
                                        state.isDescriptionTapped
                                            ? InvidiousDescriptionSection(
                                                height: height,
                                                watchInfo: watchInfo,
                                                locals: locals)
                                            :
                                            // * related videos
                                            state.isTapComments == false
                                                ? settingsState.isHideRelated
                                                    ? const SizedBox()
                                                    : (state.fetchInvidiousWatchInfoStatus ==
                                                                ApiStatus
                                                                    .initial ||
                                                            state.fetchInvidiousWatchInfoStatus ==
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
                                                        : InvidiousRelatedVideoSection(
                                                            locals: locals,
                                                            watchInfo:
                                                                watchInfo)
                                                //comments section
                                                : InvidiousCommentSection(
                                                    videoId: widget.id,
                                                    state: state,
                                                    height: height,
                                                    locals: locals,
                                                  ),
                                      ],
                                    ),
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
            },
          );
        },
      ),
    );
  }
}
