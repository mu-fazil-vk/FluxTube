import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/core/player/playback_queue_controller.dart';
import 'package:fluxtube/presentation/routes/app_routes.dart';
import 'package:fluxtube/presentation/watch/widgets/pip_video_widget.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Global key for the PiP widget to maintain its state across route changes
final GlobalKey<State<PipVideoWidget>> _pipWidgetKey =
    GlobalKey<State<PipVideoWidget>>();

/// Global PiP overlay that shows the PiP player above all routes
/// This ensures PiP works regardless of which screen the user navigates to
class GlobalPipOverlay extends StatefulWidget {
  final Widget child;

  const GlobalPipOverlay({
    super.key,
    required this.child,
  });

  @override
  State<GlobalPipOverlay> createState() => _GlobalPipOverlayState();
}

class _GlobalPipOverlayState extends State<GlobalPipOverlay> {
  final GlobalPlayerController _globalPlayer = GlobalPlayerController();
  bool _wasInSystemPip = false;

  @override
  void initState() {
    super.initState();
    _globalPlayer.pipService.addNextActionListener(_playNextFromQueue);
  }

  @override
  void dispose() {
    _globalPlayer.pipService.removeNextActionListener(_playNextFromQueue);
    super.dispose();
  }

  void _playNextFromQueue() {
    final current = context.read<WatchBloc>().state.selectedVideoBasicDetails;
    final next = PlaybackQueueController.instance.nextAfter(current?.id);
    if (next == null) return;

    context
        .read<WatchBloc>()
        .add(WatchEvent.setSelectedVideoBasicDetails(details: next));
    context.read<WatchBloc>().add(WatchEvent.togglePip(value: true));
    router.goNamed('watch', pathParameters: {
      'videoId': next.id,
      'channelId': next.channelId ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.isPipDisabled != current.isPipDisabled,
      builder: (context, settingsState) {
        return BlocBuilder<WatchBloc, WatchState>(
          buildWhen: (previous, current) =>
              previous.isPipEnabled != current.isPipEnabled ||
              previous.selectedVideoBasicDetails !=
                  current.selectedVideoBasicDetails,
          builder: (context, watchState) {
            // Listen to global player controller for state changes
            return ListenableBuilder(
              listenable: _globalPlayer,
              builder: (context, _) {
                // Check if we're in system PiP mode
                // Use the native callback state - this is the reliable source
                final isInSystemPip = _globalPlayer.isSystemPipMode;

                // Also check screen size for the actual PiP window rendering
                // This handles the case where the callback hasn't fired yet
                final screenSize = MediaQuery.of(context).size;
                final isVerySmallScreen =
                    screenSize.width < 400 && screenSize.height < 500;
                final shouldRenderSystemPip = isInSystemPip ||
                    (watchState.isPipEnabled && screenSize.height < 500);

                // Detect when exiting system PiP - navigate to watch screen
                if (_wasInSystemPip && !shouldRenderSystemPip) {
                  _wasInSystemPip = false;
                  // Navigate to watch screen after the build completes
                  final videoDetails = watchState.selectedVideoBasicDetails;
                  if (videoDetails != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Reset orientation to portrait when exiting system PiP
                      // This ensures the app doesn't stay in landscape mode
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                      // Also restore system UI overlays
                      SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.edgeToEdge,
                      );

                      router.goNamed('watch', pathParameters: {
                        'videoId': videoDetails.id,
                        'channelId': videoDetails.channelId ?? '',
                      });
                    });
                  }
                }

                // Track if we're entering system PiP
                if (shouldRenderSystemPip) {
                  _wasInSystemPip = true;
                }

                final shouldShowPip = watchState.isPipEnabled &&
                    !settingsState.isPipDisabled &&
                    watchState.selectedVideoBasicDetails != null &&
                    !isInSystemPip;

                // Keep PiP widget in tree when we have video data to maintain state
                // This prevents widget recreation during navigation which would lose
                // position state and potentially cause visual glitches
                // But don't include it when in system PiP mode to avoid layout issues
                final hasPipData =
                    watchState.selectedVideoBasicDetails != null &&
                        watchState.isPipEnabled &&
                        !settingsState.isPipDisabled &&
                        !isInSystemPip;

                // When in system PiP mode (very small window), show ONLY the video player
                // This ensures the PiP window shows just the video, not the whole app UI
                // Use AND condition - both flags must indicate PiP mode
                if (shouldRenderSystemPip &&
                    Platform.isAndroid &&
                    _globalPlayer.hasNativeExoPlayer) {
                  return const _SystemPipExoPlayerView();
                }

                if (shouldRenderSystemPip &&
                    _globalPlayer.hasActiveMediaKitPlayer) {
                  return Stack(
                    children: [
                      ColoredBox(
                        color: Colors.black,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Video(
                              controller: _globalPlayer.videoController,
                              controls: NoVideoControls,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (shouldRenderSystemPip &&
                    Platform.isAndroid &&
                    watchState.selectedVideoBasicDetails != null) {
                  return const _SystemPipExoPlayerView();
                }

                if (isVerySmallScreen) {
                  return const ColoredBox(color: Colors.black);
                }

                return Stack(
                  children: [
                    // Main app content
                    widget.child,

                    // PiP overlay - always in tree when data is available
                    // Visibility is controlled by isVisible parameter to maintain state
                    if (hasPipData)
                      PipVideoWidget(
                        key: _pipWidgetKey,
                        videoId: watchState.selectedVideoBasicDetails!.id,
                        channelId:
                            watchState.selectedVideoBasicDetails!.channelId ??
                                '',
                        title:
                            watchState.selectedVideoBasicDetails!.title ?? '',
                        thumbnailUrl:
                            watchState.selectedVideoBasicDetails!.thumbnailUrl,
                        isVisible: shouldShowPip,
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SystemPipExoPlayerView extends StatelessWidget {
  const _SystemPipExoPlayerView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: AndroidView(
            viewType: 'fluxtube/newpipe_exoplayer',
            creationParams: {
              'attachOnly': true,
              'fitMode': 'contain',
            },
            creationParamsCodec: StandardMessageCodec(),
          ),
        ),
      ),
    );
  }
}
