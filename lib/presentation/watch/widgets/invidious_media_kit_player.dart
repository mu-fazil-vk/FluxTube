import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/sponsorblock/models/sponsor_segment.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/models/generic_quality_info.dart';
import 'package:fluxtube/domain/watch/playback/models/generic_subtitle.dart';
import 'package:fluxtube/presentation/watch/widgets/player/generic_player_controls_overlay.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// MediaKit-based video player for Invidious service
class InvidiousMediaKitPlayer extends StatefulWidget {
  const InvidiousMediaKitPlayer({
    super.key,
    required this.watchInfo,
    required this.videoId,
    required this.playbackPosition,
    this.defaultQuality = "720p",
    this.isSaved = false,
    this.isHlsPlayer = false,
    required this.subtitles,
    this.videoFitMode = "contain",
    this.skipInterval = 10,
    this.isAudioFocusEnabled = true,
    this.subtitleSize = 18.0,
    this.sponsorSegments = const [],
  });

  final InvidiousWatchResp watchInfo;
  final String videoId;
  final String defaultQuality;
  final int playbackPosition;
  final bool isSaved;
  final bool isHlsPlayer;
  final List<Map<String, String>> subtitles;
  final String videoFitMode;
  final int skipInterval;
  final bool isAudioFocusEnabled;
  final double subtitleSize;
  final List<SponsorSegment> sponsorSegments;

  @override
  State<InvidiousMediaKitPlayer> createState() =>
      _InvidiousMediaKitPlayerState();
}

class _InvidiousMediaKitPlayerState extends State<InvidiousMediaKitPlayer> {
  // Use global player controller for persistence across navigation/PiP
  final GlobalPlayerController _globalPlayer = GlobalPlayerController();

  // Local references for convenience
  Player get _player => _globalPlayer.player;
  VideoController get _videoController => _globalPlayer.videoController;

  List<GenericQualityInfo>? _availableQualities;
  String? _currentQualityLabel;
  bool _isInitialized = false;
  bool _isRestoringFromPip = false;
  bool _isChangingQuality = false;
  bool _isSeekingToPosition = false; // Track initial seek to saved position
  late BoxFit _currentFitMode;

  // SponsorBlock
  StreamSubscription<Duration>? _sponsorBlockSubscription;
  final Set<String> _skippedSegments = {};

  late final SavedBloc _savedBloc;
  late final WatchBloc _watchBloc;

  @override
  void initState() {
    super.initState();

    _savedBloc = BlocProvider.of<SavedBloc>(context);
    _watchBloc = BlocProvider.of<WatchBloc>(context);
    _currentFitMode = _getBoxFit(widget.videoFitMode);

    // Defer initialization to next frame to handle async operations properly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeAsync();
      }
    });
  }

  /// Async initialization - handles stopping wrong videos before PiP check
  Future<void> _initializeAsync() async {
    // CRITICAL: First thing - check if wrong video is playing and stop it
    final currentPlayingId = _globalPlayer.currentVideoId;
    if (currentPlayingId != null && currentPlayingId != widget.videoId) {
      debugPrint(
          '[InvidiousPlayer] CRITICAL: Wrong video $currentPlayingId playing, expected ${widget.videoId}');
      debugPrint(
          '[InvidiousPlayer] Stopping wrong video and waiting for completion');
      await _globalPlayer.stopAndClear();
      debugPrint('[InvidiousPlayer] Wrong video stopped successfully');
    }

    if (!mounted) return;

    // Check if we're returning from PiP for the same video
    // This check now happens AFTER the stop has completed
    _isRestoringFromPip = _globalPlayer.isPlayingVideo(widget.videoId);

    if (_isRestoringFromPip) {
      // Restore from PiP - set initialized immediately since player is already active
      debugPrint(
          '[InvidiousPlayer] Restoring from PiP for video ${widget.videoId}');
      _restoreFromPipSync();
    } else {
      // New video - initialize fresh
      debugPrint(
          '[InvidiousPlayer] Starting fresh initialization for video ${widget.videoId}');
      _initializePlayback();
    }
    _setupHistoryListener();
    _setupSponsorBlockListener();
  }

  @override
  void didUpdateWidget(covariant InvidiousMediaKitPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the video ID changed, reinitialize playback
    if (oldWidget.videoId != widget.videoId) {
      debugPrint(
          '[InvidiousPlayer] Video ID changed from ${oldWidget.videoId} to ${widget.videoId}');
      // IMMEDIATELY stop the player to prevent old audio from playing
      _player.stop();
      // Cancel old sponsor block subscription
      _sponsorBlockSubscription?.cancel();
      _skippedSegments.clear();
      // Reset state
      setState(() {
        _isInitialized = false;
        _isRestoringFromPip = false;
        _isSeekingToPosition = false;
      });
      // Initialize new video
      _initializePlayback();
      _setupSponsorBlockListener();
    }
  }

  /// Synchronous restore from PiP - no loading state needed since player is already playing
  void _restoreFromPipSync() {
    // Build quality list for UI
    final formatStreams = widget.watchInfo.formatStreams ?? [];
    _availableQualities = formatStreams
        .where((v) => v.qualityLabel != null && v.url != null)
        .map((v) => GenericQualityInfo(
              label: v.qualityLabel!,
              displayLabel: v.qualityLabel!,
              resolution: GenericQualityInfo.parseResolution(v.qualityLabel!),
              fps: v.fps,
              format: v.container,
              url: v.url,
            ))
        .toList();

    _availableQualities?.sort((a, b) => b.resolution.compareTo(a.resolution));
    _currentQualityLabel = widget.defaultQuality;

    // Mark as initialized immediately - player is already playing
    _isInitialized = true;

    // Exit PiP mode in background (don't await)
    _globalPlayer.exitPipMode();

    debugPrint('[InvidiousPlayer] Restored from PiP successfully (sync)');
  }

  Future<void> _initializePlayback() async {
    try {
      // If global player was playing a different video (e.g., in PiP), stop it first
      if (_globalPlayer.hasActivePlayer &&
          _globalPlayer.currentVideoId != widget.videoId) {
        debugPrint(
            '[InvidiousPlayer] Stopping previous video ${_globalPlayer.currentVideoId} to play ${widget.videoId}');
        await _globalPlayer.stopAndClear();
      }

      // Ensure global player is initialized before use
      await _globalPlayer.ensureInitialized();

      // STRICT: Enforce that we're about to play the correct video
      // This is a critical safety check to prevent video mismatches
      await _globalPlayer.enforceVideoId(widget.videoId);

      // Build available qualities list from format streams
      final formatStreams = widget.watchInfo.formatStreams ?? [];
      _availableQualities = formatStreams
          .where((v) => v.qualityLabel != null && v.url != null)
          .map((v) => GenericQualityInfo(
                label: v.qualityLabel!,
                displayLabel: v.qualityLabel!,
                resolution: GenericQualityInfo.parseResolution(v.qualityLabel!),
                fps: v.fps,
                format: v.container,
                url: v.url,
              ))
          .toList();

      // Sort by resolution (highest first)
      _availableQualities?.sort((a, b) => b.resolution.compareTo(a.resolution));

      // Determine initial quality
      String targetQuality = widget.defaultQuality;

      // Check if preferred quality is available
      final hasPreferredQuality =
          _availableQualities?.any((q) => q.label == targetQuality) ?? false;
      if (!hasPreferredQuality && (_availableQualities?.isNotEmpty ?? false)) {
        // Use closest available quality
        targetQuality = _findClosestQuality(targetQuality);
      }

      _currentQualityLabel = targetQuality;

      // Update global player controller state for PiP support
      // IMPORTANT: Set video ID BEFORE setupMediaSource so notification can be updated
      _globalPlayer.setCurrentVideoId(widget.videoId);

      // Setup media source
      await _setupMediaSource(targetQuality);

      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing playback: $e');
      if (mounted) {
        _showError('Failed to initialize video playback');
      }
    }
  }

  Future<void> _setupMediaSource(String quality) async {
    try {
      String? videoUrl;
      bool isDash = false;
      final bool isLive = widget.watchInfo.liveNow == true;
      final formatStreams = widget.watchInfo.formatStreams ?? [];

      // For live streams, always use DASH
      if (isLive && widget.watchInfo.dashUrl != null) {
        videoUrl = widget.watchInfo.dashUrl;
        isDash = true;
      } else if (widget.isHlsPlayer && widget.watchInfo.dashUrl != null) {
        // Use DASH stream if enabled and available
        videoUrl = widget.watchInfo.dashUrl;
        isDash = true;
      } else {
        // Find the selected quality stream
        final selectedStream = formatStreams.firstWhere(
          (v) => v.qualityLabel == quality,
          orElse: () => formatStreams.isNotEmpty
              ? formatStreams.first
              : formatStreams.first,
        );
        videoUrl = selectedStream.url;

        // Fallback to DASH if no direct stream available
        if (videoUrl == null && widget.watchInfo.dashUrl != null) {
          videoUrl = widget.watchInfo.dashUrl;
          isDash = true;
        }
      }

      if (videoUrl == null) {
        _showError('No video stream available');
        return;
      }

      debugPrint('=== Invidious MediaKit Playback Debug ===');
      debugPrint('Quality: $quality');
      debugPrint('Is DASH: $isDash');
      debugPrint('Is Live: $isLive');
      debugPrint(
          'Video URL: ${videoUrl.substring(0, videoUrl.length > 80 ? 80 : videoUrl.length)}...');

      // Open the media
      await _player.open(
        Media(
          videoUrl,
          httpHeaders: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );

      // Start playback first
      await _player.play();

      // Update media notification for background playback controls
      await _globalPlayer.updateMediaNotification(
        title: widget.watchInfo.title ?? 'Video',
        artist: widget.watchInfo.author ?? 'Unknown',
        thumbnailUrl: widget.watchInfo.videoThumbnails?.isNotEmpty == true
            ? widget.watchInfo.videoThumbnails!.first.url
            : null,
        duration: widget.watchInfo.lengthSeconds != null
            ? Duration(seconds: widget.watchInfo.lengthSeconds!)
            : null,
      );

      // Seek AFTER playback has started to avoid codec issues
      if (widget.playbackPosition > 0 && !isLive) {
        // Show seeking indicator
        if (mounted) {
          setState(() {
            _isSeekingToPosition = true;
          });
        }

        // Small delay to let playback stabilize before seeking
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;

        await _player.seek(Duration(seconds: widget.playbackPosition));
        debugPrint(
            'Seeked to position: ${widget.playbackPosition}s (after play)');

        // Wait for buffering to complete after seek
        await _waitForBufferingComplete();

        // Hide seeking indicator after buffering is done
        if (mounted) {
          setState(() {
            _isSeekingToPosition = false;
          });
        }
      }

      debugPrint('Started playback');
    } catch (e) {
      debugPrint('Error setting up media source: $e');
      _showError('Failed to load video');
    }
  }

  /// Wait for buffering to complete after seek
  Future<void> _waitForBufferingComplete(
      {Duration timeout = const Duration(seconds: 5)}) async {
    final startTime = DateTime.now();

    // Wait until player is not buffering
    while (_player.state.buffering) {
      if (DateTime.now().difference(startTime) > timeout) {
        debugPrint(
            '[Player] Timeout waiting for buffering complete, proceeding anyway');
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    debugPrint('[Player] Buffering complete');
  }

  String _findClosestQuality(String targetQuality) {
    if (_availableQualities == null || _availableQualities!.isEmpty) {
      return targetQuality;
    }

    return GenericQualityInfo.findBestMatchingQuality(
          _availableQualities!,
          targetQuality,
        )?.label ??
        targetQuality;
  }

  void _setupHistoryListener() {
    // Update history every 5 seconds
    _player.stream.position.listen((position) {
      if (position.inSeconds % 5 == 0) {
        _updateVideoHistory();
      }
    });
  }

  void _setupSponsorBlockListener() {
    if (widget.sponsorSegments.isEmpty) return;

    _sponsorBlockSubscription = _player.stream.position.listen((position) {
      final currentSeconds = position.inSeconds.toDouble() +
          (position.inMilliseconds % 1000) / 1000.0;

      for (final segment in widget.sponsorSegments) {
        // Check if we're within this segment and haven't skipped it yet
        if (segment.containsPosition(currentSeconds) &&
            !_skippedSegments.contains(segment.uuid)) {
          _skippedSegments.add(segment.uuid);

          // Seek to end of segment
          final seekPosition = Duration(
            milliseconds: (segment.endTime * 1000).round(),
          );
          _player.seek(seekPosition);

          // Show toast notification
          _showToast('Skipped ${segment.categoryDisplayName}');
          debugPrint(
              '[SponsorBlock] Skipped ${segment.category} segment: ${segment.startTime}s - ${segment.endTime}s');
          break;
        }
      }
    });
  }

  Future<void> changeQuality(String newQualityLabel) async {
    if (_currentQualityLabel == newQualityLabel) return;

    setState(() {
      _isChangingQuality = true;
    });

    try {
      final currentPosition = _player.state.position;
      final wasPlaying = _player.state.playing;

      debugPrint('Changing quality to: $newQualityLabel');

      // Setup new source
      await _setupMediaSource(newQualityLabel);

      // Restore position (for non-live streams)
      if (currentPosition.inSeconds > 0 && widget.watchInfo.liveNow != true) {
        await _player.seek(currentPosition);
      }

      // Restore playback state
      if (wasPlaying) {
        await _player.play();
      }

      setState(() {
        _currentQualityLabel = newQualityLabel;
        _isChangingQuality = false;
      });

      _showToast('Quality changed to $newQualityLabel');
      debugPrint('Quality changed to: $newQualityLabel');
    } catch (e) {
      debugPrint('Error changing quality: $e');
      _showError('Failed to change quality');
      setState(() {
        _isChangingQuality = false;
      });
    }
  }

  @override
  void dispose() {
    _sponsorBlockSubscription?.cancel();
    _updateVideoHistory();
    // Don't dispose the global player - save state for PiP transition
    _globalPlayer.savePlaybackState();
    debugPrint(
        '[InvidiousPlayer] Dispose called - saving state for potential PiP');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading only for fresh initialization, not when restoring from PiP
    final bool playerHasVideo = _globalPlayer.hasActivePlayer &&
        _globalPlayer.currentVideoId == widget.videoId;

    if (!_isInitialized && !playerHasVideo) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _getAspectRatio(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Video(
            controller: _videoController,
            controls: (state) {
              return _buildCustomControls(state);
            },
            fit: _currentFitMode,
            subtitleViewConfiguration: SubtitleViewConfiguration(
              style: TextStyle(
                fontSize: widget.subtitleSize,
                color: Colors.white,
                backgroundColor: const Color(0x99000000),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            ),
          ),
          // Buffering indicator overlay
          StreamBuilder<bool>(
            stream: _player.stream.buffering,
            initialData: false,
            builder: (context, snapshot) {
              final isBuffering = snapshot.data ?? false;
              // Show loading for buffering, quality change, or seeking to position
              if (!isBuffering &&
                  !_isChangingQuality &&
                  !_isSeekingToPosition) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      if (_isChangingQuality) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Changing quality...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ] else if (_isSeekingToPosition) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Resuming playback...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomControls(VideoState state) {
    // Convert subtitles to generic format
    final genericSubtitles =
        widget.subtitles.map((s) => GenericSubtitle.fromMap(s)).toList();

    return GenericPlayerControlsOverlay(
      player: _player,
      videoState: state,
      availableQualities: _availableQualities,
      currentQuality: _currentQualityLabel,
      onQualityChanged: changeQuality,
      subtitles: genericSubtitles,
      skipInterval: widget.skipInterval,
      isLive: widget.watchInfo.liveNow == true,
      currentFitMode: _currentFitMode,
      onFitModeChanged: _onFitModeChanged,
      isInitializing: !_isInitialized,
    );
  }

  void _onFitModeChanged(BoxFit newFitMode) {
    setState(() {
      _currentFitMode = newFitMode;
    });
  }

  double _getAspectRatio() {
    // Try to get aspect ratio from format streams
    final formatStreams = widget.watchInfo.formatStreams ?? [];
    if (formatStreams.isNotEmpty) {
      final firstStream = formatStreams.first;
      // Resolution format is "widthxheight" or just the size string
      final resolution = firstStream.resolution;
      if (resolution != null) {
        final parts = resolution.split('x');
        if (parts.length == 2) {
          final width = double.tryParse(parts[0]);
          final height = double.tryParse(parts[1]);
          if (width != null && height != null && height > 0) {
            return width / height;
          }
        }
      }
    }
    return 16 / 9;
  }

  BoxFit _getBoxFit(String fitMode) {
    switch (fitMode) {
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'contain':
      default:
        return BoxFit.contain;
    }
  }

  void _updateVideoHistory() {
    final currentPosition = _player.state.position;

    _watchBloc
        .add(WatchEvent.updatePlayBack(playBack: currentPosition.inSeconds));

    if (currentPosition.inSeconds > 0 && widget.videoId.isNotEmpty) {
      // Get author thumbnail URL
      String? authorAvatar;
      if (widget.watchInfo.authorThumbnails != null &&
          widget.watchInfo.authorThumbnails!.isNotEmpty) {
        authorAvatar = widget.watchInfo.authorThumbnails!.first.url;
      }

      // Get video thumbnail URL
      String? thumbnailUrl;
      if (widget.watchInfo.videoThumbnails != null &&
          widget.watchInfo.videoThumbnails!.isNotEmpty) {
        thumbnailUrl = widget.watchInfo.videoThumbnails!.first.url;
      }

      final videoInfo = LocalStoreVideoInfo(
        id: widget.videoId,
        title: widget.watchInfo.title,
        views: widget.watchInfo.viewCount,
        thumbnail: thumbnailUrl,
        uploadedDate: widget.watchInfo.publishedText,
        uploaderAvatar: authorAvatar,
        uploaderName: widget.watchInfo.author,
        uploaderId: widget.watchInfo.authorId,
        uploaderSubscriberCount: widget.watchInfo.subCountText ?? '0',
        duration: widget.watchInfo.lengthSeconds,
        uploaderVerified: widget.watchInfo.authorVerified,
        isHistory: true,
        isLive: widget.watchInfo.liveNow,
        // isSaved will be preserved by updatePlaybackPosition event
        isSaved: false,
        playbackPosition: currentPosition.inSeconds,
      );

      // Use updatePlaybackPosition instead of addVideoInfo to preserve isSaved state
      _savedBloc.add(SavedEvent.updatePlaybackPosition(videoInfo: videoInfo));
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showError(String message) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showToast(message);
      });
    }
  }
}
