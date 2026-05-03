import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/sponsorblock/models/sponsor_segment.dart';
import 'package:fluxtube/domain/watch/models/piped/video/video_stream.dart';
import 'package:fluxtube/domain/watch/models/piped/video/watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/models/generic_quality_info.dart';
import 'package:fluxtube/domain/watch/playback/models/generic_subtitle.dart';
import 'package:fluxtube/domain/watch/playback/models/generic_audio_track.dart';
import 'package:fluxtube/domain/watch/playback/piped_stream_helper.dart';
import 'package:fluxtube/presentation/watch/widgets/player/generic_player_controls_overlay.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// MediaKit-based video player for Piped service
class PipedMediaKitPlayer extends StatefulWidget {
  const PipedMediaKitPlayer({
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

  final WatchResp watchInfo;
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
  State<PipedMediaKitPlayer> createState() => _PipedMediaKitPlayerState();
}

class _PipedMediaKitPlayerState extends State<PipedMediaKitPlayer> {
  // Use global player controller for persistence across navigation/PiP
  final GlobalPlayerController _globalPlayer = GlobalPlayerController();

  // Local references for convenience
  Player get _player => _globalPlayer.player;
  VideoController get _videoController => _globalPlayer.videoController;

  List<GenericQualityInfo>? _availableQualities;
  String? _currentQualityLabel;
  bool _isInitialized = false;
  List<VideoStream> _availableVideoTracks = [];
  bool _isRestoringFromPip = false;
  bool _isChangingQuality = false;
  bool _isSeekingToPosition = false; // Track initial seek to saved position
  late BoxFit _currentFitMode;

  // Audio track state
  List<GenericAudioTrackInfo>? _availableAudioTracks;
  String? _currentAudioTrackId;
  bool _isChangingAudioTrack = false;

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
          '[PipedPlayer] CRITICAL: Wrong video $currentPlayingId playing, expected ${widget.videoId}');
      debugPrint(
          '[PipedPlayer] Stopping wrong video and waiting for completion');
      await _globalPlayer.stopAndClear();
      debugPrint('[PipedPlayer] Wrong video stopped successfully');
    }

    if (!mounted) return;

    // Check if we're returning from PiP for the same video
    // This check now happens AFTER the stop has completed
    _isRestoringFromPip = _globalPlayer.isPlayingVideo(widget.videoId);

    if (_isRestoringFromPip) {
      // Restore from PiP - set initialized immediately since player is already active
      debugPrint(
          '[PipedPlayer] Restoring from PiP for video ${widget.videoId}');
      _restoreFromPipSync();
    } else {
      // New video - initialize fresh
      debugPrint(
          '[PipedPlayer] Starting fresh initialization for video ${widget.videoId}');
      _initializePlayback();
    }
    _setupHistoryListener();
    _setupSponsorBlockListener();
  }

  @override
  void didUpdateWidget(covariant PipedMediaKitPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the video ID changed, reinitialize playback
    if (oldWidget.videoId != widget.videoId) {
      debugPrint(
          '[PipedPlayer] Video ID changed from ${oldWidget.videoId} to ${widget.videoId}');
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
    _availableVideoTracks = widget.watchInfo.videoStreams
        .where((video) => video.videoOnly == false)
        .toList();

    _availableQualities = _availableVideoTracks
        .where((v) => v.quality != null && v.url != null)
        .map((v) => GenericQualityInfo(
              label: v.quality!,
              displayLabel: v.quality!,
              resolution: GenericQualityInfo.parseResolution(v.quality!),
              fps: v.fps,
              format: v.format,
              url: v.url,
            ))
        .toList();

    _availableQualities?.sort((a, b) => b.resolution.compareTo(a.resolution));
    _currentQualityLabel = widget.defaultQuality;

    // Build audio tracks list
    _availableAudioTracks = PipedStreamHelper.getAvailableAudioTracks(
        widget.watchInfo.audioStreams);

    // Restore audio track from global state
    final savedAudioTrack = _globalPlayer.currentAudioTrackId;
    if (savedAudioTrack != null &&
        _availableAudioTracks!.any((t) => t.trackId == savedAudioTrack)) {
      _currentAudioTrackId = savedAudioTrack;
    } else if (_availableAudioTracks!.isNotEmpty) {
      _currentAudioTrackId = _availableAudioTracks!.first.trackId;
    }

    // Mark as initialized immediately - player is already playing
    _isInitialized = true;

    // Exit PiP mode in background (don't await)
    _globalPlayer.exitPipMode();

    debugPrint('[PipedPlayer] Restored from PiP successfully (sync)');
  }

  Future<void> _initializePlayback() async {
    try {
      // If global player was playing a different video (e.g., in PiP), stop it first
      if (_globalPlayer.hasActivePlayer &&
          _globalPlayer.currentVideoId != widget.videoId) {
        debugPrint(
            '[PipedPlayer] Stopping previous video ${_globalPlayer.currentVideoId} to play ${widget.videoId}');
        await _globalPlayer.stopAndClear();
      }

      // Ensure global player is initialized before use
      await _globalPlayer.ensureInitialized();

      // STRICT: Enforce that we're about to play the correct video
      // This is a critical safety check to prevent video mismatches
      await _globalPlayer.enforceVideoId(widget.videoId);

      // Get available video tracks (non-video-only streams)
      _availableVideoTracks = widget.watchInfo.videoStreams
          .where((video) => video.videoOnly == false)
          .toList();

      // Build available qualities list
      _availableQualities = _availableVideoTracks
          .where((v) => v.quality != null && v.url != null)
          .map((v) => GenericQualityInfo(
                label: v.quality!,
                displayLabel: v.quality!,
                resolution: GenericQualityInfo.parseResolution(v.quality!),
                fps: v.fps,
                format: v.format,
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

      // Build audio tracks list
      _availableAudioTracks = PipedStreamHelper.getAvailableAudioTracks(
          widget.watchInfo.audioStreams);
      if (_availableAudioTracks!.isNotEmpty) {
        _currentAudioTrackId = _availableAudioTracks!.first.trackId;
        _globalPlayer.setCurrentAudioTrackId(_currentAudioTrackId);
      }

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
      bool isHls = false;
      final bool isLive = widget.watchInfo.livestream == true;

      // For live streams, always use HLS
      if (isLive && widget.watchInfo.hls != null) {
        videoUrl = widget.watchInfo.hls;
        isHls = true;
      } else if (widget.isHlsPlayer && widget.watchInfo.hls != null) {
        // Use HLS stream if enabled and available
        videoUrl = widget.watchInfo.hls;
        isHls = true;
      } else {
        // Find the selected quality stream
        final selectedStream = _availableVideoTracks.firstWhere(
          (v) => v.quality == quality,
          orElse: () => _availableVideoTracks.isNotEmpty
              ? _availableVideoTracks.first
              : VideoStream(),
        );
        videoUrl = selectedStream.url;

        // Fallback to HLS if no direct stream available
        if (videoUrl == null && widget.watchInfo.hls != null) {
          videoUrl = widget.watchInfo.hls;
          isHls = true;
        }
      }

      if (videoUrl == null) {
        _showError('No video stream available');
        return;
      }

      debugPrint('=== Piped MediaKit Playback Debug ===');
      debugPrint('Quality: $quality');
      debugPrint('Is HLS: $isHls');
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
        artist: widget.watchInfo.uploader ?? 'Unknown',
        thumbnailUrl: widget.watchInfo.thumbnailUrl,
        duration: widget.watchInfo.duration != null
            ? Duration(seconds: widget.watchInfo.duration!)
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
      if (currentPosition.inSeconds > 0 &&
          widget.watchInfo.livestream != true) {
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
    debugPrint('[PipedPlayer] Dispose called - saving state for potential PiP');
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
              // Show loading for buffering, quality change, audio track change, or seeking to position
              if (!isBuffering &&
                  !_isChangingQuality &&
                  !_isSeekingToPosition &&
                  !_isChangingAudioTrack) {
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
                      ] else if (_isChangingAudioTrack) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Changing audio track...',
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
      isLive: widget.watchInfo.livestream == true,
      currentFitMode: _currentFitMode,
      onFitModeChanged: _onFitModeChanged,
      audioTracks: _availableAudioTracks,
      currentAudioTrack: _currentAudioTrackId,
      onAudioTrackChanged: _changeAudioTrack,
      isInitializing: !_isInitialized,
    );
  }

  /// Change audio track (for multi-language support)
  Future<void> _changeAudioTrack(String newTrackId) async {
    if (_currentAudioTrackId == newTrackId) return;
    if (_availableAudioTracks == null || _availableAudioTracks!.isEmpty) return;

    // Find the track
    final track = _availableAudioTracks!.firstWhere(
      (t) => t.trackId == newTrackId,
      orElse: () => _availableAudioTracks!.first,
    );

    if (track.url == null || track.url!.isEmpty) {
      debugPrint('[PipedPlayer] No audio URL for track: $newTrackId');
      return;
    }

    setState(() {
      _isChangingAudioTrack = true;
    });

    try {
      debugPrint('[PipedPlayer] Changing audio track to: ${track.displayName}');

      // Set the audio track
      await _player.setAudioTrack(AudioTrack.uri(track.url!));

      // Update state
      _currentAudioTrackId = newTrackId;
      _globalPlayer.setCurrentAudioTrackId(newTrackId);

      _showToast('Audio: ${track.displayName}');
      debugPrint('[PipedPlayer] Audio track changed to: ${track.displayName}');
    } catch (e) {
      debugPrint('[PipedPlayer] Error changing audio track: $e');
      _showError('Failed to change audio track');
    } finally {
      if (mounted) {
        setState(() {
          _isChangingAudioTrack = false;
        });
      }
    }
  }

  void _onFitModeChanged(BoxFit newFitMode) {
    setState(() {
      _currentFitMode = newFitMode;
    });
  }

  double _getAspectRatio() {
    final firstStream = widget.watchInfo.videoStreams.firstOrNull;
    if (firstStream != null &&
        firstStream.width != null &&
        firstStream.height != null) {
      return firstStream.width! / firstStream.height!;
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
      final videoInfo = LocalStoreVideoInfo(
        id: widget.videoId,
        title: widget.watchInfo.title,
        views: widget.watchInfo.views,
        thumbnail: widget.watchInfo.thumbnailUrl,
        uploadedDate: widget.watchInfo.uploadDate,
        uploaderAvatar: widget.watchInfo.uploaderAvatar,
        uploaderName: widget.watchInfo.uploader,
        uploaderId: widget.watchInfo.uploaderUrl?.split("/").last ?? '',
        uploaderSubscriberCount:
            widget.watchInfo.uploaderSubscriberCount.toString(),
        duration: widget.watchInfo.duration,
        uploaderVerified: widget.watchInfo.uploaderVerified,
        isHistory: true,
        isLive: widget.watchInfo.livestream,
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
