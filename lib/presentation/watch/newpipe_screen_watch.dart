import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/presentation/watch/widgets/newpipe/exoplayer_video_player.dart';
import 'package:fluxtube/presentation/watch/widgets/newpipe/media_kit_video_player.dart';
import 'package:fluxtube/widgets/widgets.dart';

import 'widgets/newpipe/comment_widgets.dart';
import 'widgets/newpipe/description_section.dart';
import 'widgets/newpipe/like_section.dart';
import 'widgets/newpipe/related_video_section.dart';
import 'widgets/newpipe/subscribe_section.dart';

class NewPipeScreenWatch extends StatefulWidget {
  const NewPipeScreenWatch({
    super.key,
    required this.id,
    required this.channelId,
  });

  final String id;
  final String channelId;

  @override
  State<NewPipeScreenWatch> createState() => _NewPipeScreenWatchState();
}

class _NewPipeScreenWatchState extends State<NewPipeScreenWatch>
    with WidgetsBindingObserver {
  // Track if player should be shown - once shown, keep it shown until video ID changes
  // This prevents the player from being disposed during BlocBuilder rebuilds
  bool _showPlayer = false;
  // Track the video ID for which the player is shown
  String? _playerVideoId;
  void _enterAppPipAndPop() {
    GlobalPlayerController().enterPipMode();
    BlocProvider.of<WatchBloc>(context).add(WatchEvent.togglePip(value: true));
    Navigator.pop(context);
  }

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
    // Disable PIP when watch screen becomes visible (resumed)
    if (state == AppLifecycleState.resumed) {
      // Check if this route is currently visible
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
  void didUpdateWidget(covariant NewPipeScreenWatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the video ID changed (e.g., user clicked a related video), reinitialize
    if (oldWidget.id != widget.id) {
      debugPrint(
          '[NewPipeScreenWatch] Video ID changed from ${oldWidget.id} to ${widget.id}');
      // Reset player visibility for new video
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
    // Handle when this watch screen becomes visible again
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
                '[NewPipeScreenWatch] Old watch screen detected (this: ${widget.id}, playing: $currentPlayingId). Auto-popping.');
            Navigator.of(context).pop();
            return;
          }

          // Disable PIP when returning to watch screen from another route
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
    final settingsState = settingsBloc.state;
    final currentProfile = settingsState.currentProfile;

    final globalPlayer = GlobalPlayerController();
    final currentPlayingId = globalPlayer.currentVideoId;

    // If a different video is playing, stop it first
    if (currentPlayingId != null && currentPlayingId != widget.id) {
      debugPrint(
          '[NewPipeScreenWatch] Stopping previous video: $currentPlayingId (starting: ${widget.id})');
      await globalPlayer.stopAndClear();
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // Validate before starting any video
    await globalPlayer.validateBeforePlay(widget.id);

    // Check if returning from PiP with same video already loaded
    final isReturningFromPip = globalPlayer.hasVideoLoaded(widget.id) &&
        watchBloc.state.newPipeWatchResp.id == widget.id;

    watchBloc.add(WatchEvent.togglePip(value: false));

    // Only fetch data if not returning from PiP with data already loaded
    if (!isReturningFromPip) {
      // Use fast loading with parallel SponsorBlock fetch
      watchBloc.add(WatchEvent.getNewPipeWatchInfoFast(
        id: widget.id,
        sponsorBlockCategories: settingsState.isSponsorBlockEnabled
            ? settingsState.sponsorBlockCategories
            : [],
      ));
    }

    // Saved state and subscription check can run in parallel
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

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);
    final double height = MediaQuery.of(context).size.height;

    return BlocListener<WatchBloc, WatchState>(
      listenWhen: (previous, current) =>
          previous.fetchNewPipeWatchInfoStatus !=
              current.fetchNewPipeWatchInfoStatus &&
          current.fetchNewPipeWatchInfoStatus == ApiStatus.loaded,
      listener: (context, state) {
        // Set selectedVideoBasicDetails when video info is loaded
        // This ensures PIP works when navigating from external links
        final watchInfo = state.newPipeWatchResp;
        if (watchInfo.id != null && watchInfo.id!.isNotEmpty) {
          BlocProvider.of<WatchBloc>(context).add(
            WatchEvent.setSelectedVideoBasicDetails(
              details: VideoBasicInfo(
                id: watchInfo.id!,
                title: watchInfo.title,
                thumbnailUrl: watchInfo.thumbnailUrl,
                channelName: watchInfo.uploaderName,
                channelId: watchInfo.uploaderUrl?.split('/').last,
                uploaderVerified: watchInfo.uploaderVerified,
              ),
            ),
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
            previous.skipInterval != current.skipInterval ||
            previous.subtitleSize != current.subtitleSize ||
            previous.isAutoPipEnabled != current.isAutoPipEnabled,
        builder: (context, settingsState) {
          return BlocBuilder<WatchBloc, WatchState>(
            buildWhen: (previous, current) =>
                previous.fetchNewPipeWatchInfoStatus !=
                    current.fetchNewPipeWatchInfoStatus ||
                previous.newPipeWatchResp != current.newPipeWatchResp ||
                previous.isDescriptionTapped != current.isDescriptionTapped ||
                previous.isTapComments != current.isTapComments ||
                previous.fetchNewPipeCommentsStatus !=
                    current.fetchNewPipeCommentsStatus ||
                previous.newPipeComments != current.newPipeComments ||
                previous.fetchMoreNewPipeCommentsStatus !=
                    current.fetchMoreNewPipeCommentsStatus ||
                previous.isMoreNewPipeCommentsFetchCompleted !=
                    current.isMoreNewPipeCommentsFetchCompleted ||
                previous.sponsorSegments != current.sponsorSegments,
            builder: (context, state) {
              return BlocBuilder<SavedBloc, SavedState>(
                buildWhen: (previous, current) =>
                    previous.videoInfo?.id != current.videoInfo?.id ||
                    previous.videoInfo?.isSaved != current.videoInfo?.isSaved ||
                    previous.videoInfo?.playbackPosition !=
                        current.videoInfo?.playbackPosition,
                builder: (context, savedState) {
                  final watchInfo = state.newPipeWatchResp;

                  if (state.fetchNewPipeWatchInfoStatus == ApiStatus.error) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(locals.retry),
                      ),
                      body: SafeArea(
                        child: SingleChildScrollView(
                          child: InstanceAutoCheckWidget(
                            videoId: widget.id,
                            lottie: 'assets/cat-404.zip',
                            errorMessage: state.newPipeErrorMessage,
                            onRetry: () => BlocProvider.of<WatchBloc>(context)
                                .add(WatchEvent.getNewPipeWatchInfo(
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
                          _enterAppPipAndPop();
                          return;
                        }
                        Navigator.pop(context);
                      },
                      isFullScreen: true,
                      key: ValueKey(widget.id),
                      child: PopScope(
                        canPop: true,
                        onPopInvokedWithResult: (didPop, _) {
                          if (didPop && !settingsState.isPipDisabled) {
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
                                  // Show player if:
                                  // 1. Watch info is loaded for this video, OR
                                  // 2. Returning from PiP (player has this video with data)
                                  // CRITICAL: Once player is shown, keep it shown to prevent
                                  // disposal during BlocBuilder rebuilds
                                  Builder(
                                    builder: (context) {
                                      final useNativePlayer = !kIsWeb &&
                                          defaultTargetPlatform ==
                                              TargetPlatform.android;

                                      // Check if we should show the player
                                      final shouldShowPlayer = _showPlayer &&
                                          _playerVideoId == widget.id;
                                      final hasLoadedWatchInfo =
                                          state.fetchNewPipeWatchInfoStatus ==
                                                  ApiStatus.loaded &&
                                              state.newPipeWatchResp.id ==
                                                  widget.id;
                                      final canShowPlayer =
                                          hasLoadedWatchInfo ||
                                              (!useNativePlayer &&
                                                  GlobalPlayerController()
                                                      .hasVideoLoaded(
                                                          widget.id));

                                      // Once we can show the player, set _showPlayer to true
                                      // This ensures the player stays in the tree during rebuilds
                                      if (canShowPlayer && !shouldShowPlayer) {
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

                                      // Show player if either condition is true
                                      return (shouldShowPlayer || canShowPlayer)
                                          ? useNativePlayer
                                              ? NewPipeExoPlayer(
                                                  key: ValueKey(
                                                      'exo_player_${widget.id}'),
                                                  videoId: widget.id,
                                                  watchInfo:
                                                      state.newPipeWatchResp,
                                                  playbackPosition: savedState
                                                              .videoInfo?.id ==
                                                          widget.id
                                                      ? (savedState.videoInfo
                                                              ?.playbackPosition ??
                                                          0)
                                                      : 0,
                                                  defaultQuality: settingsState
                                                      .defaultQuality,
                                                  videoFitMode: settingsState
                                                      .videoFitMode,
                                                  skipInterval: settingsState
                                                      .skipInterval,
                                                  sponsorSegments: settingsState
                                                          .isSponsorBlockEnabled
                                                      ? state.sponsorSegments
                                                      : const [],
                                                  preferAdaptivePlayback:
                                                      settingsState.isHlsPlayer,
                                                  isAutoPipEnabled:
                                                      settingsState
                                                          .isAutoPipEnabled,
                                                )
                                              : NewPipeMediaKitPlayer(
                                                  // CRITICAL: Use ValueKey to prevent widget recreation
                                                  // when watchInfo updates. Only recreate on videoId change.
                                                  key: ValueKey(
                                                      'player_${widget.id}'),
                                                  videoId: widget.id,
                                                  watchInfo:
                                                      state.newPipeWatchResp,
                                                  // Only use playback position if it's for the current video
                                                  // This prevents using the previous video's position when switching videos
                                                  playbackPosition: savedState
                                                              .videoInfo?.id ==
                                                          widget.id
                                                      ? (savedState.videoInfo
                                                              ?.playbackPosition ??
                                                          0)
                                                      : 0,
                                                  defaultQuality: settingsState
                                                      .defaultQuality,
                                                  videoFitMode: settingsState
                                                      .videoFitMode,
                                                  skipInterval: settingsState
                                                      .skipInterval,
                                                  subtitleSize: settingsState
                                                      .subtitleSize,
                                                  sponsorSegments: settingsState
                                                          .isSponsorBlockEnabled
                                                      ? state.sponsorSegments
                                                      : const [],
                                                  isAutoPipEnabled:
                                                      settingsState
                                                          .isAutoPipEnabled,
                                                  preferAdaptivePlayback:
                                                      settingsState.isHlsPlayer,
                                                )
                                          : Container(
                                              height: 200,
                                              color: kBlackColor,
                                              child: Center(
                                                child: cIndicator(context),
                                              ),
                                            );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, left: 20, right: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        (state.fetchNewPipeWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchNewPipeWatchInfoStatus ==
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
                                        (state.fetchNewPipeWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchNewPipeWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? const SizedBox()
                                            : ViewRowWidget(
                                                views: watchInfo.viewCount,
                                                uploadedDate: watchInfo
                                                        .textualUploadDate ??
                                                    '',
                                              ),
                                        kHeightBox10,
                                        (state.fetchNewPipeWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchNewPipeWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? const ShimmerLikeWidget()
                                            : NewPipeLikeSection(
                                                id: widget.id,
                                                state: state,
                                                watchInfo: watchInfo,
                                                pipClicked: () {
                                                  _enterAppPipAndPop();
                                                },
                                              ),
                                        kHeightBox10,
                                        const Divider(),
                                        (state.fetchNewPipeWatchInfoStatus ==
                                                    ApiStatus.initial ||
                                                state.fetchNewPipeWatchInfoStatus ==
                                                    ApiStatus.loading)
                                            ? const ShimmerSubscribeWidget()
                                            : NewPipeChannelInfoSection(
                                                state: state,
                                                watchInfo: watchInfo,
                                                locals: locals),
                                        if (!state.isTapComments)
                                          const Divider(),
                                        kHeightBox10,
                                        state.isDescriptionTapped
                                            ? NewPipeDescriptionSection(
                                                height: height,
                                                watchInfo: watchInfo,
                                                locals: locals)
                                            : state.isTapComments == false
                                                ? settingsState.isHideRelated
                                                    ? const SizedBox()
                                                    : (state.fetchNewPipeWatchInfoStatus ==
                                                                ApiStatus
                                                                    .initial ||
                                                            state.fetchNewPipeWatchInfoStatus ==
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
                                                        : NewPipeRelatedVideoSection(
                                                            locals: locals,
                                                            watchInfo:
                                                                watchInfo)
                                                : NewPipeCommentSection(
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
