import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/sponsorblock/models/sponsor_segment.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_stream.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/models/playback_configuration.dart';
import 'package:fluxtube/domain/watch/playback/models/stream_quality_info.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_playback_resolver.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_stream_helper.dart';
import 'package:fluxtube/presentation/watch/widgets/player/player_controls_overlay.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class NewPipeMediaKitPlayer extends StatefulWidget {
  const NewPipeMediaKitPlayer({
    super.key,
    required this.watchInfo,
    required this.videoId,
    required this.playbackPosition,
    this.defaultQuality = "720p",
    this.isSaved = false,
    this.videoFitMode = "contain",
    this.skipInterval = 10,
    this.isAudioFocusEnabled = true,
    this.subtitleSize = 18.0,
    this.sponsorSegments = const [],
    this.isAutoPipEnabled = true,
    this.preferAdaptivePlayback = false,
  });

  final NewPipeWatchResp watchInfo;
  final String videoId;
  final String defaultQuality;
  final int playbackPosition;
  final bool isSaved;
  final String videoFitMode;
  final int skipInterval;
  final bool isAudioFocusEnabled;
  final double subtitleSize;
  final List<SponsorSegment> sponsorSegments;
  final bool isAutoPipEnabled;
  final bool preferAdaptivePlayback;

  @override
  State<NewPipeMediaKitPlayer> createState() => _NewPipeMediaKitPlayerState();
}

class _NewPipeMediaKitPlayerState extends State<NewPipeMediaKitPlayer> {
  // Use global player controller for persistence across navigation
  final GlobalPlayerController _globalPlayer = GlobalPlayerController();

  // Local references for convenience
  Player get _player => _globalPlayer.player;
  VideoController get _videoController => _globalPlayer.videoController;

  PlaybackConfiguration? _currentConfig;
  List<StreamQualityInfo>? _availableQualities;
  String? _currentQualityLabel;
  bool _isInitialized = false;
  bool _isInitializing = false; // Guard against concurrent initializations
  bool _isRestoringFromPip = false;
  bool _isChangingQuality = false;
  late BoxFit _currentFitMode;

  // SponsorBlock
  StreamSubscription<Duration>? _sponsorBlockSubscription;
  final Set<String> _skippedSegments = {};

  // History tracking - throttle updates
  StreamSubscription<Duration>? _historySubscription;
  int _lastSavedPositionSeconds = -1;

  // HLS/DASH adaptive streaming - track video tracks from player
  StreamSubscription<Tracks>? _tracksSubscription;
  List<VideoTrack> _hlsDashVideoTracks = [];
  VideoTrack? _currentVideoTrack;

  // Audio track selection
  List<AudioTrackInfo>? _availableAudioTracks;
  String? _currentAudioTrackId;
  bool _isChangingAudioTrack = false;

  // PiP state tracking - notify Android when playback state changes
  StreamSubscription<bool>? _playingSubscription;

  late final SavedBloc _savedBloc;
  late final WatchBloc _watchBloc;
  late final NewPipePlaybackResolver _resolver;

  @override
  void initState() {
    super.initState();

    _savedBloc = BlocProvider.of<SavedBloc>(context);
    _watchBloc = BlocProvider.of<WatchBloc>(context);
    _resolver = NewPipePlaybackResolver();
    _currentFitMode = _getBoxFit(widget.videoFitMode);

    // Defer initialization to next frame to handle async operations properly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeAsync();
      }
    });
  }

  /// Async initialization - matches pattern used by other player widgets
  Future<void> _initializeAsync() async {
    // CRITICAL: Prevent concurrent initializations
    // Multiple BlocBuilder rebuilds can trigger initState multiple times
    if (_isInitializing) {
      debugPrint(
          '[NewPipePlayer] Initialization already in progress, skipping');
      return;
    }
    _isInitializing = true;

    try {
      // Check if we're returning from PiP for the same video
      // Only restore if the player is actually in a stable playing state for this video
      _isRestoringFromPip = _globalPlayer.isPlayingVideo(widget.videoId);

      if (_isRestoringFromPip) {
        // Restore from PiP - set initialized immediately since player is already active
        debugPrint(
            '[NewPipePlayer] Restoring from PiP for video ${widget.videoId}');
        _restoreFromPipSync();
      } else {
        // New video - initialize fresh
        debugPrint(
            '[NewPipePlayer] Starting fresh initialization for video ${widget.videoId}');
        await _initializePlayback();
      }
      _setupHistoryListener();
      _setupSponsorBlockListener();
      _setupTracksListener();
      _setupPlayingStateListener();
    } finally {
      _isInitializing = false;
    }
  }

  @override
  void didUpdateWidget(covariant NewPipeMediaKitPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the video ID changed, reinitialize playback
    if (oldWidget.videoId != widget.videoId) {
      debugPrint(
          '[NewPipePlayer] CRITICAL: Video ID changed from ${oldWidget.videoId} to ${widget.videoId}');
      debugPrint('[NewPipePlayer] IMMEDIATELY stopping old video');

      // Stop both local and global player for the old video. This is awaited
      // inside the async task below so the next open cannot race the previous
      // clear operation.
      unawaited(_globalPlayer.stopAndClear().then((_) {
        if (mounted) {
          _initializeAsync();
        }
      }));

      // Cancel old subscriptions
      _sponsorBlockSubscription?.cancel();
      _historySubscription?.cancel();
      _tracksSubscription?.cancel();
      _playingSubscription?.cancel();
      _skippedSegments.clear();
      _hlsDashVideoTracks = [];
      _currentVideoTrack = null;
      // Reset state - also reset _isInitializing to allow new video init
      setState(() {
        _isInitialized = false;
        _isInitializing = false;
        _isRestoringFromPip = false;
        _lastSavedPositionSeconds = -1;
      });
    }
    // If watchInfo was updated (same videoId but new data), update available qualities
    // This happens when BlocBuilder passes new watchInfo after API response
    else if (oldWidget.watchInfo != widget.watchInfo &&
        widget.watchInfo.videoStreams != null &&
        widget.watchInfo.videoStreams!.isNotEmpty) {
      debugPrint(
          '[NewPipePlayer] watchInfo updated for same video, updating qualities');
      _availableQualities =
          NewPipeStreamHelper.getAvailableQualities(widget.watchInfo);
      _availableAudioTracks = NewPipeStreamHelper.getAvailableAudioTracks(
          widget.watchInfo.audioStreams ?? []);
    }
  }

  /// Synchronous restore from PiP - no loading state needed since player is already playing
  void _restoreFromPipSync() {
    // Get available qualities for UI
    _availableQualities =
        NewPipeStreamHelper.getAvailableQualities(widget.watchInfo);
    _availableAudioTracks = NewPipeStreamHelper.getAvailableAudioTracks(
        widget.watchInfo.audioStreams ?? []);
    _currentQualityLabel = widget.defaultQuality;
    // Restore audio track from global state if available
    if (_availableAudioTracks != null && _availableAudioTracks!.isNotEmpty) {
      final savedTrackId = _globalPlayer.currentAudioTrackId;
      if (savedTrackId != null &&
          _availableAudioTracks!.any((t) => t.trackId == savedTrackId)) {
        _currentAudioTrackId = savedTrackId;
      } else {
        final originalTrack = _availableAudioTracks!.firstWhere(
          (t) => t.isOriginal && !t.isDubbed && !t.isDescriptive,
          orElse: () => _availableAudioTracks!.first,
        );
        _currentAudioTrackId = originalTrack.trackId;
        _globalPlayer.setCurrentAudioTrackId(_currentAudioTrackId);
      }
    }

    // Resolve config for UI controls
    _currentConfig = _resolver.resolve(
      watchResp: widget.watchInfo,
      preferredQuality: widget.defaultQuality,
      preferHighQuality: true,
      preferAdaptive: widget.preferAdaptivePlayback,
    );

    // Mark as initialized immediately - player is already playing
    _isInitialized = true;

    // Exit PiP mode in background (don't await)
    _globalPlayer.exitPipMode();

    debugPrint('[NewPipePlayer] Restored from PiP successfully (sync)');
  }

  Future<void> _initializePlayback() async {
    try {
      // If global player was playing a different video (e.g., in PiP), stop it first
      if (_globalPlayer.hasActivePlayer &&
          _globalPlayer.currentVideoId != widget.videoId) {
        debugPrint(
            '[NewPipePlayer] Stopping previous video ${_globalPlayer.currentVideoId} to play ${widget.videoId}');
        await _globalPlayer.stopAndClear();
      }

      // Check mounted after async operation
      if (!mounted) {
        debugPrint(
            '[NewPipePlayer] Widget disposed during initialization (after stopAndClear)');
        return;
      }

      // Ensure global player is initialized before use
      await _globalPlayer.ensureInitialized();

      // Check mounted after async operation
      if (!mounted) {
        debugPrint(
            '[NewPipePlayer] Widget disposed during initialization (after ensureInitialized)');
        return;
      }

      // STRICT: Enforce that we're about to play the correct video
      // This is a critical safety check to prevent video mismatches
      await _globalPlayer.enforceVideoId(widget.videoId);

      // Check mounted after async operation
      if (!mounted) {
        debugPrint(
            '[NewPipePlayer] Widget disposed during initialization (after enforceVideoId)');
        return;
      }

      // Get available qualities
      _availableQualities =
          NewPipeStreamHelper.getAvailableQualities(widget.watchInfo);

      // Get available audio tracks
      _availableAudioTracks = NewPipeStreamHelper.getAvailableAudioTracks(
          widget.watchInfo.audioStreams ?? []);
      // Restore audio track from global state if available, otherwise set default
      if (_availableAudioTracks != null && _availableAudioTracks!.isNotEmpty) {
        final savedTrackId = _globalPlayer.currentAudioTrackId;
        if (savedTrackId != null &&
            _availableAudioTracks!.any((t) => t.trackId == savedTrackId)) {
          _currentAudioTrackId = savedTrackId;
        } else {
          // First try to find an explicitly original, non-dubbed track
          final originalTrack = _availableAudioTracks!.firstWhere(
            (t) => t.isOriginal && !t.isDubbed && !t.isDescriptive,
            orElse: () => _availableAudioTracks!.first,
          );
          _currentAudioTrackId = originalTrack.trackId;
          _globalPlayer.setCurrentAudioTrackId(_currentAudioTrackId);
        }
      }

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

      // Resolve playback configuration
      _currentConfig = _resolver.resolve(
        watchResp: widget.watchInfo,
        preferredQuality: targetQuality,
        preferHighQuality: true,
        preferAdaptive: widget.preferAdaptivePlayback,
      );

      // For HLS/DASH, set initial quality label to "Auto" since adaptive streaming handles quality
      final isAdaptive = _currentConfig!.sourceType == MediaSourceType.hls ||
          _currentConfig!.sourceType == MediaSourceType.dash;
      if (isAdaptive) {
        _currentQualityLabel = 'Auto';
        // Clear video stream qualities - will be populated by tracks listener
        _availableQualities = null;
      }

      debugPrint('=== MediaKit Playback Debug ===');
      debugPrint('Source type: ${_currentConfig!.sourceType}');
      debugPrint('Quality: ${_currentConfig!.qualityLabel}');
      debugPrint('Video URL: ${_currentConfig!.videoUrl}');
      debugPrint('Audio URL: ${_currentConfig!.audioUrl}');
      debugPrint('Manifest URL: ${_currentConfig!.manifestUrl}');
      debugPrint('Is valid: ${_currentConfig!.isValid}');

      if (!_currentConfig!.isValid) {
        _showError('No valid video stream available');
        return;
      }

      // Update global player controller state for PiP support
      // IMPORTANT: Set video ID BEFORE setupMediaSource so notification can be updated
      _globalPlayer.setCurrentVideoId(widget.videoId);

      // Setup media source
      await _setupMediaSource(
        _currentConfig!,
        startPosition: Duration(seconds: widget.playbackPosition),
      );

      // Check mounted after async operation
      if (!mounted) {
        debugPrint(
            '[NewPipePlayer] Widget disposed during initialization (after setupMediaSource)');
        return;
      }

      // Enable auto-PiP based on settings (only on Android)
      await _globalPlayer.enableAutoPip(widget.isAutoPipEnabled);

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

  Future<void> _setupMediaSource(
    PlaybackConfiguration config, {
    Duration startPosition = Duration.zero,
    bool play = true,
    bool updateNotification = true,
    bool fastSwitch = false,
  }) async {
    try {
      final isAdaptive = config.sourceType == MediaSourceType.hls ||
          config.sourceType == MediaSourceType.dash;

      switch (config.sourceType) {
        case MediaSourceType.progressive:
          // Muxed stream (has audio, ≤360p)
          await _player.open(
            Media(
              config.videoUrl!,
              httpHeaders: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              },
            ),
            play: false,
          );
          debugPrint('Opened progressive stream');
          break;

        case MediaSourceType.merging:
          // Separate video + audio (>360p)
          final audioUrl = config.audioUrl ?? _selectMediumQualityAudio();

          // First open video - don't wait for ready here, just open
          await _player.open(
            Media(
              config.videoUrl!,
              httpHeaders: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              },
            ),
            play: false,
          );
          debugPrint('Opening merging stream');

          // Check mounted after async operation
          if (!mounted) return;

          if (audioUrl != null) {
            // Set audio track
            try {
              await _player.setAudioTrack(
                AudioTrack.uri(audioUrl),
              );
              debugPrint('Opened video + audio (${config.qualityLabel})');
              debugPrint('Video: ${config.videoUrl?.substring(0, 80)}...');
              debugPrint('Audio: ${audioUrl.substring(0, 80)}...');
            } catch (e) {
              debugPrint('Error setting audio track: $e');
            }
          } else {
            debugPrint('Warning: No audio URL available');
          }

          // Check mounted after async operation
          if (!mounted) return;
          break;

        case MediaSourceType.hls:
          // HLS stream - fast initialization, no separate wait needed
          await _player.open(Media(config.manifestUrl!), play: false);
          debugPrint('Opened HLS stream');
          break;

        case MediaSourceType.dash:
          // DASH manifest - fast initialization, no separate wait needed
          await _player.open(Media(config.manifestUrl!), play: false);
          debugPrint('Opened DASH stream');
          break;
      }

      // Check mounted after switch block
      if (!mounted) return;

      // Setup subtitles asynchronously - don't block playback
      if (config.subtitles.isNotEmpty) {
        _setupSubtitlesAsync(config.subtitles);
      }

      // For HLS/DASH, start playback immediately - they handle buffering internally
      // For progressive/merging, wait for duration to be available
      if (!isAdaptive) {
        await _waitForPlayerReady(
          timeout: fastSwitch
              ? const Duration(milliseconds: 800)
              : const Duration(seconds: 2),
        );
        if (!mounted) return;
      }

      if (play) {
        await _player.play();
      }

      if (startPosition > Duration.zero && !config.isLive) {
        unawaited(_player.seek(startPosition));
        debugPrint('Queued seek to position: ${startPosition.inSeconds}s');
      }

      // Notify native side that video is playing (for auto-PiP)
      await _globalPlayer.updatePlaybackStateForPip();

      if (updateNotification) {
        // Update media notification for background playback controls.
        await _globalPlayer.updateMediaNotification(
          title: widget.watchInfo.title ?? 'Video',
          artist: widget.watchInfo.uploaderName ?? 'Unknown',
          thumbnailUrl: widget.watchInfo.thumbnailUrl,
          duration: widget.watchInfo.duration != null
              ? Duration(seconds: widget.watchInfo.duration!)
              : null,
        );
      }

      // Check mounted after play
      if (!mounted) return;

      debugPrint('Started playback');
    } catch (e) {
      debugPrint('Error setting up media source: $e');
      if (mounted) {
        _showError('Failed to load video');
      }
    }
  }

  /// Setup subtitles asynchronously to not block playback
  void _setupSubtitlesAsync(List subtitles) {
    Future.microtask(() {
      for (var subtitle in subtitles) {
        if (subtitle.url != null && subtitle.url!.isNotEmpty) {
          try {
            _player.setSubtitleTrack(
              SubtitleTrack.uri(subtitle.url!,
                  title: subtitle.languageCode ?? 'Unknown'),
            );
            debugPrint('Added subtitle: ${subtitle.languageCode}');
          } catch (e) {
            debugPrint('Failed to add subtitle: $e');
          }
        }
      }
    });
  }

  /// Select a medium-quality ORIGINAL audio stream (around 128kbps)
  /// Prioritizes original audio over dubbed/translated versions
  /// Returns fresh URL each time - needed because YouTube URLs expire
  String? _selectMediumQualityAudio() {
    final audioStreams = widget.watchInfo.audioStreams ?? [];
    if (audioStreams.isEmpty) return null;

    // Debug: Log all audio streams with URL-based detection
    debugPrint('=== Audio Stream Detection ===');
    for (var audio in audioStreams) {
      debugPrint(
          '  - ${audio.quality} | ${audio.format} | type: ${audio.audioTrackType ?? "null"} | isOriginal: ${audio.isOriginal} | isDubbed: ${audio.isDubbed}');
    }
    debugPrint('==============================');

    // Filter to only original audio streams (not dubbed or descriptive)
    // Now also checks URL xtags for dubbed indicators when audioTrackType is null
    final originalStreams = audioStreams.where((audio) {
      if (audio.url == null || audio.url!.isEmpty) return false;
      return audio.isOriginal;
    }).toList();

    debugPrint(
        'Audio filtering: ${originalStreams.length} original streams found out of ${audioStreams.length} total');

    // If no original streams found, fall back to all streams (excluding descriptive)
    final candidateStreams = originalStreams.isNotEmpty
        ? originalStreams
        : audioStreams.where((audio) {
            if (audio.url == null || audio.url!.isEmpty) return false;
            return !audio.isDescriptive;
          }).toList();

    if (candidateStreams.isEmpty) {
      // Last resort: use any available stream
      final anyValid = audioStreams.firstWhere(
        (audio) => audio.url != null && audio.url!.isNotEmpty,
        orElse: () => audioStreams.first,
      );
      debugPrint(
          'No suitable audio found, using fallback: ${anyValid.quality ?? "Unknown"}');
      return anyValid.url;
    }

    // Sort by quality
    final sorted = NewPipeStreamHelper.sortAudioStreams(candidateStreams);

    // Target medium quality (around 128kbps)
    // Find audio stream closest to 128kbps bitrate
    const targetBitrate = 128;
    NewPipeAudioStream? selectedAudio = sorted.first;
    int smallestDiff = double.maxFinite.toInt();

    for (var audio in sorted) {
      final bitrate = audio.averageBitrate ?? 0;
      final diff = (bitrate - targetBitrate).abs();

      if (diff < smallestDiff) {
        smallestDiff = diff;
        selectedAudio = audio;
      }
    }

    debugPrint(
        'Selected audio: ${selectedAudio?.quality ?? "Unknown"} | Bitrate: ${selectedAudio?.averageBitrate ?? 0}kbps | Format: ${selectedAudio?.format ?? "Unknown"} | TrackType: ${selectedAudio?.audioTrackType ?? "null"} | isOriginal: ${selectedAudio?.isOriginal} | isDubbed: ${selectedAudio?.isDubbed} | Locale: ${selectedAudio?.audioLocale ?? "N/A"}');
    return selectedAudio?.url;
  }

  /// Wait for the player to be ready (duration > 0) with timeout
  /// Uses stream-based waiting for efficiency instead of polling
  Future<void> _waitForPlayerReady(
      {Duration timeout = const Duration(seconds: 3)}) async {
    // If already ready, return immediately
    if (_player.state.duration > Duration.zero) {
      debugPrint(
          '[Player] Player already ready, duration: ${_player.state.duration}');
      return;
    }

    // Use Completer with stream listening for efficient waiting
    final completer = Completer<void>();
    StreamSubscription<Duration>? subscription;

    // Set up timeout
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        debugPrint(
            '[Player] Timeout waiting for player ready, proceeding anyway');
        subscription?.cancel();
        completer.complete();
      }
    });

    // Listen for duration changes
    subscription = _player.stream.duration.listen((duration) {
      if (duration > Duration.zero && !completer.isCompleted) {
        debugPrint('[Player] Player ready, duration: $duration');
        timer.cancel();
        subscription?.cancel();
        completer.complete();
      }
    });

    await completer.future;
  }

  String _findClosestQuality(String targetQuality) {
    if (_availableQualities == null || _availableQualities!.isEmpty) {
      return targetQuality;
    }

    return NewPipeStreamHelper.findBestMatchingQuality(
          _availableQualities!,
          targetQuality,
        )?.label ??
        targetQuality;
  }

  void _setupHistoryListener() {
    // Cancel any existing subscription
    _historySubscription?.cancel();

    // Update history every 15 seconds. This keeps resume position fresh without
    // doing database work too often while the decoder is already busy.
    _historySubscription = _player.stream.position.listen((position) {
      final currentSeconds = position.inSeconds;
      // Only update when we cross the boundary AND haven't already saved this position.
      if (currentSeconds > 0 &&
          currentSeconds % 15 == 0 &&
          currentSeconds != _lastSavedPositionSeconds) {
        _lastSavedPositionSeconds = currentSeconds;
        _updateVideoHistory();
      }
    });
  }

  /// Setup listener for HLS/DASH video tracks
  /// This allows quality selection for adaptive streaming
  void _setupTracksListener() {
    _tracksSubscription?.cancel();
    _tracksSubscription = _player.stream.tracks.listen((tracks) {
      if (!mounted) return;

      // Only process if using HLS/DASH
      final isAdaptive = _currentConfig?.sourceType == MediaSourceType.hls ||
          _currentConfig?.sourceType == MediaSourceType.dash;

      if (isAdaptive && tracks.video.isNotEmpty) {
        debugPrint(
            '[NewPipePlayer] HLS/DASH tracks available: ${tracks.video.length} video tracks');

        // Filter valid video tracks (non-empty id and resolution info)
        final validTracks = tracks.video.where((track) {
          // VideoTrack.auto() has empty id, keep it
          // Other tracks should have resolution info
          return track.id.isEmpty || (track.w != null && track.h != null);
        }).toList();

        // Sort by resolution (highest first), keeping auto at the beginning
        validTracks.sort((a, b) {
          if (a.id.isEmpty) return -1; // auto goes first
          if (b.id.isEmpty) return 1;
          final aRes = (a.h ?? 0);
          final bRes = (b.h ?? 0);
          return bRes.compareTo(aRes); // Higher resolution first
        });

        setState(() {
          _hlsDashVideoTracks = validTracks;
          // Get current track
          _currentVideoTrack = _player.state.track.video;

          // Update quality label based on current track
          if (_currentVideoTrack != null) {
            _currentQualityLabel = _getTrackQualityLabel(_currentVideoTrack!);
          }

          // Build quality list for UI from adaptive tracks
          _availableQualities = _buildQualitiesFromTracks(validTracks);
        });

        debugPrint(
            '[NewPipePlayer] Available HLS/DASH qualities: ${_availableQualities?.map((q) => q.label).join(", ")}');
      }
    });
  }

  /// Setup listener to track playing state changes for PiP
  void _setupPlayingStateListener() {
    _playingSubscription?.cancel();
    _playingSubscription = _player.stream.playing.listen((isPlaying) {
      // Notify Android about playback state changes for auto-PiP
      _globalPlayer.updatePlaybackStateForPip();
    });
  }

  /// Build StreamQualityInfo list from VideoTrack list (for HLS/DASH)
  List<StreamQualityInfo> _buildQualitiesFromTracks(List<VideoTrack> tracks) {
    return tracks.map((track) {
      final label = _getTrackQualityLabel(track);
      final resolution = track.h ?? 0;

      return StreamQualityInfo(
        label: label,
        resolution: resolution,
        fps: track.fps?.toInt(),
        format: null,
        requiresMerging: false, // HLS/DASH handles this internally
        isVideoOnly: false, // HLS/DASH includes audio
        videoStream: null, // Not applicable for adaptive
        audioStream: null,
      );
    }).toList();
  }

  /// Get quality label from VideoTrack
  String _getTrackQualityLabel(VideoTrack track) {
    if (track.id.isEmpty) {
      return 'Auto';
    }

    final height = track.h ?? 0;
    final fps = track.fps?.toInt();

    if (height == 0) {
      return track.title ?? track.id;
    }

    // Format as "1080p" or "1080p60" for high frame rate
    if (fps != null && fps > 30) {
      return '${height}p$fps';
    }
    return '${height}p';
  }

  /// Find VideoTrack by quality label
  VideoTrack? _findTrackByQualityLabel(String qualityLabel) {
    if (qualityLabel == 'Auto') {
      return VideoTrack.auto();
    }

    for (final track in _hlsDashVideoTracks) {
      if (_getTrackQualityLabel(track) == qualityLabel) {
        return track;
      }
    }
    return null;
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
      // Check if we're using HLS/DASH - use track selection instead of reopening stream
      final isAdaptive = _currentConfig?.sourceType == MediaSourceType.hls ||
          _currentConfig?.sourceType == MediaSourceType.dash;

      if (isAdaptive && _hlsDashVideoTracks.isNotEmpty) {
        // HLS/DASH quality change - use setVideoTrack
        await _changeQualityAdaptive(newQualityLabel);
      } else {
        // Progressive/Merging quality change - reopen stream
        await _changeQualityProgressive(newQualityLabel);
      }
    } catch (e) {
      debugPrint('Error changing quality: $e');
      _showError('Failed to change quality');
      setState(() {
        _isChangingQuality = false;
      });
    }
  }

  /// Change quality for HLS/DASH streams using setVideoTrack
  Future<void> _changeQualityAdaptive(String newQualityLabel) async {
    final targetTrack = _findTrackByQualityLabel(newQualityLabel);

    if (targetTrack == null) {
      debugPrint(
          '[NewPipePlayer] Could not find track for quality: $newQualityLabel');
      _showError('Quality not available');
      setState(() {
        _isChangingQuality = false;
      });
      return;
    }

    debugPrint(
        '[NewPipePlayer] Changing HLS/DASH quality to: $newQualityLabel (track: ${targetTrack.id})');

    // Set the video track
    await _player.setVideoTrack(targetTrack);

    if (!mounted) return;

    setState(() {
      _currentVideoTrack = targetTrack;
      _currentQualityLabel = newQualityLabel;
      _isChangingQuality = false;
    });

    debugPrint('[NewPipePlayer] HLS/DASH quality changed to: $newQualityLabel');
  }

  /// Change quality for progressive/merging streams (requires reopening stream)
  Future<void> _changeQualityProgressive(String newQualityLabel) async {
    final currentPosition = _player.state.position;
    final wasPlaying = _player.state.playing;

    // Resolve new configuration (only video URL will be used, audio stays the same)
    final newConfig = _resolver.resolve(
      watchResp: widget.watchInfo,
      preferredQuality: newQualityLabel,
      preferHighQuality: true,
      preferAdaptive: false,
    );

    if (!newConfig.isValid) {
      _showError('Quality not available');
      setState(() {
        _isChangingQuality = false;
      });
      return;
    }

    debugPrint('Changing quality to: $newQualityLabel (keeping fixed audio)');

    await _setupMediaSource(
      newConfig,
      startPosition: currentPosition,
      play: wasPlaying,
      updateNotification: false,
      fastSwitch: true,
    );

    setState(() {
      _currentConfig = newConfig;
      _currentQualityLabel = newQualityLabel;
      _isChangingQuality = false;
    });

    debugPrint('Quality changed to: $newQualityLabel');
  }

  /// Change audio track (for multi-track videos like dubbed content)
  Future<void> changeAudioTrack(String newTrackId) async {
    if (_currentAudioTrackId == newTrackId) return;
    if (_availableAudioTracks == null || _availableAudioTracks!.isEmpty) return;

    // Find the target track
    final targetTrack = _availableAudioTracks!.firstWhere(
      (t) => t.trackId == newTrackId,
      orElse: () => _availableAudioTracks!.first,
    );

    // Get the best stream for this track
    final audioStream = targetTrack.bestStream;
    if (audioStream?.url == null) {
      debugPrint(
          '[NewPipePlayer] No valid audio stream for track: $newTrackId');
      _showError('Audio track not available');
      return;
    }

    setState(() {
      _isChangingAudioTrack = true;
    });

    try {
      debugPrint(
          '[NewPipePlayer] Changing audio track to: ${targetTrack.displayName} ($newTrackId)');

      // Set the new audio track
      await _player.setAudioTrack(AudioTrack.uri(audioStream!.url!));

      // Wait for audio to stabilize
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      setState(() {
        _currentAudioTrackId = newTrackId;
        _isChangingAudioTrack = false;
      });

      // Save to global state for persistence across widget rebuilds
      _globalPlayer.setCurrentAudioTrackId(newTrackId);

      _showToast('Audio: ${targetTrack.displayName}');
      debugPrint(
          '[NewPipePlayer] Audio track changed to: ${targetTrack.displayName}');
    } catch (e) {
      debugPrint('[NewPipePlayer] Error changing audio track: $e');
      if (mounted) {
        setState(() {
          _isChangingAudioTrack = false;
        });
        _showError('Failed to change audio track');
      }
    }
  }

  @override
  void dispose() {
    _sponsorBlockSubscription?.cancel();
    _historySubscription?.cancel();
    _tracksSubscription?.cancel();
    _playingSubscription?.cancel();
    _updateVideoHistory();
    // Don't dispose the global player - save state for PiP transition
    // The player will persist and can be restored when returning from PiP
    _globalPlayer.savePlaybackState();
    debugPrint(
        '[NewPipePlayer] Dispose called - saving state for potential PiP');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder to react to player duration changes
    // This ensures we show loading until video is actually ready
    return StreamBuilder<Duration>(
      stream: _player.stream.duration,
      initialData: _player.state.duration,
      builder: (context, durationSnapshot) {
        // Show loading only for fresh initialization, not when restoring from PiP
        // Check if player is already active with loaded media to skip loading state
        // A video is "ready" when:
        // 1. ID matches AND
        // 2. Either duration > 0 (metadata loaded) OR position > 0 (has played)
        final duration = durationSnapshot.data ?? Duration.zero;
        final bool playerIsReady = _globalPlayer.currentVideoId ==
                widget.videoId &&
            (duration.inSeconds > 0 || _player.state.position.inSeconds > 0);

        if (!_isInitialized && !playerIsReady) {
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

        // For controls, we need config - but we can still show video without it
        if (_currentConfig == null && !playerIsReady) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                ),
              ),
              // Buffering indicator overlay
              StreamBuilder<bool>(
                stream: _player.stream.buffering,
                initialData: false,
                builder: (context, snapshot) {
                  final isBuffering = snapshot.data ?? false;
                  // Show loading for buffering, quality change, or audio track change
                  if (!isBuffering &&
                      !_isChangingQuality &&
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
      },
    );
  }

  Widget _buildCustomControls(VideoState state) {
    return PlayerControlsOverlay(
      player: _player,
      videoState: state,
      availableQualities: _availableQualities,
      currentQuality: _currentQualityLabel,
      onQualityChanged: changeQuality,
      subtitles: _currentConfig?.subtitles ?? [],
      skipInterval: widget.skipInterval,
      isLive: widget.watchInfo.isLive == true,
      currentFitMode: _currentFitMode,
      onFitModeChanged: _onFitModeChanged,
      availableAudioTracks: _availableAudioTracks,
      currentAudioTrackId: _currentAudioTrackId,
      onAudioTrackChanged: changeAudioTrack,
      isInitializing: !_isInitialized,
    );
  }

  void _onFitModeChanged(BoxFit newFitMode) {
    setState(() {
      _currentFitMode = newFitMode;
    });
  }

  double _getAspectRatio() {
    final firstStream = widget.watchInfo.videoStreams?.firstOrNull;
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
        views: widget.watchInfo.viewCount,
        thumbnail: widget.watchInfo.thumbnailUrl,
        uploadedDate: widget.watchInfo.textualUploadDate ?? '',
        uploaderAvatar: widget.watchInfo.uploaderAvatarUrl,
        uploaderName: widget.watchInfo.uploaderName,
        uploaderId: _extractChannelId(widget.watchInfo.uploaderUrl),
        uploaderSubscriberCount:
            widget.watchInfo.uploaderSubscriberCount?.toString() ?? '0',
        duration: widget.watchInfo.duration,
        uploaderVerified: widget.watchInfo.uploaderVerified,
        isHistory: true,
        isLive: widget.watchInfo.isLive,
        // isSaved will be preserved by updatePlaybackPosition event
        isSaved: false,
        playbackPosition: currentPosition.inSeconds,
      );

      // Use updatePlaybackPosition instead of addVideoInfo to preserve isSaved state
      _savedBloc.add(SavedEvent.updatePlaybackPosition(videoInfo: videoInfo));
    }
  }

  String? _extractChannelId(String? uploaderUrl) {
    if (uploaderUrl == null) return null;
    final uri = Uri.tryParse(uploaderUrl);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final channelIndex = uri.pathSegments.indexOf('channel');
      if (channelIndex != -1 && channelIndex + 1 < uri.pathSegments.length) {
        return uri.pathSegments[channelIndex + 1];
      }
    }
    return null;
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
