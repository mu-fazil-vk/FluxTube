import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:fluxtube/core/services/pip_service.dart';
import 'package:fluxtube/core/services/audio_handler_service.dart';
import 'package:fluxtube/core/services/exoplayer_notification_bridge.dart';

/// Global player controller singleton that persists across navigation
/// This prevents the player from being recreated/disposed when navigating
/// between watch screen and PiP mode
class GlobalPlayerController extends ChangeNotifier {
  static final GlobalPlayerController _instance =
      GlobalPlayerController._internal();
  factory GlobalPlayerController() => _instance;
  GlobalPlayerController._internal() {
    // Eagerly initialize player and video controller
    _initializePlayer();
    // Setup PiP service listener
    _setupPipListener();
  }

  Player? _player;
  VideoController? _videoController;
  String? _currentVideoId;
  bool _isPipMode = false;
  bool _isSystemPipMode = false; // Native Android PiP mode
  Duration _lastPosition = Duration.zero;
  bool _wasPlaying = false;
  bool _isInitialized = false;
  bool _isNativeExoPlayerActive = false;
  bool _notifyScheduled = false;

  // PiP service for native Android PiP
  final PipService _pipService = PipService();

  // Stream source info to avoid re-resolving
  String? _currentVideoUrl;

  // Audio track and subtitle selection (persists across widget rebuilds)
  String? _currentAudioTrackId;
  String? _currentSubtitleCode;
  String? _nativeVideoId;
  String? _nativeQuality;
  String? _nativeAudioTrackId;
  String? _nativeSubtitleCode;
  String? _nativeFitMode;
  double _nativeSpeed = 1.0;
  Duration _nativePosition = Duration.zero;
  Duration _nativeDuration = Duration.zero;
  bool _nativeWasPlaying = false;
  bool _nativeBuffering = false;

  /// Setup listener for native PiP mode changes
  void _setupPipListener() {
    _pipService.addPipModeListener(_onSystemPipModeChanged);
  }

  /// Handle system PiP mode changes from Android
  void _onSystemPipModeChanged(bool isInPipMode) {
    _isSystemPipMode = isInPipMode;
    log('[GlobalPlayer] System PiP mode changed: $isInPipMode');
    notifyListeners();
  }

  /// Initialize player eagerly to avoid first-play issues
  void _initializePlayer() {
    if (_isInitialized) return;
    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 8 * 1024 * 1024,
      ),
    );
    _videoController = VideoController(_player!);
    _isInitialized = true;
    _tuneNetworkPlayback();
    log('[GlobalPlayer] Player and VideoController initialized eagerly');
  }

  Future<void> _tuneNetworkPlayback() async {
    try {
      await (_player!.platform as dynamic).setProperty('hr-seek', 'no');
    } catch (e) {
      log('[GlobalPlayer] Could not tune native seek mode: $e');
    }
  }

  /// Ensure player is initialized - call this before using player
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      _initializePlayer();
      // Give video controller time to attach
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Player get player {
    if (_player == null) {
      _initializePlayer();
    }
    return _player!;
  }

  VideoController get videoController {
    if (_videoController == null) {
      _initializePlayer();
    }
    return _videoController!;
  }

  String? get currentVideoId => _nativeVideoId ?? _currentVideoId;
  bool get isPipMode => _isPipMode;
  bool get isSystemPipMode => _isSystemPipMode;
  Duration get lastPosition =>
      _isNativeExoPlayerActive ? _nativePosition : _lastPosition;
  bool get hasActivePlayer => hasActiveMediaKitPlayer || hasNativeExoPlayer;
  bool get hasActiveMediaKitPlayer =>
      _player != null && _currentVideoId != null && _currentVideoUrl != null;
  bool get hasNativeExoPlayer =>
      _isNativeExoPlayerActive && _nativeVideoId != null;
  PipService get pipService => _pipService;

  // Audio track and subtitle getters/setters
  String? get currentAudioTrackId => _currentAudioTrackId;
  String? get currentSubtitleCode => _currentSubtitleCode;
  String? get nativeQuality => _nativeQuality;
  String? get nativeAudioTrackId => _nativeAudioTrackId;
  String? get nativeSubtitleCode => _nativeSubtitleCode;
  String? get nativeFitMode => _nativeFitMode;
  double get nativeSpeed => _nativeSpeed;
  Duration get nativePosition => _nativePosition;
  bool get nativeWasPlaying => _nativeWasPlaying;

  bool isNativeVideoLoaded(String videoId) {
    return _isNativeExoPlayerActive && _nativeVideoId == videoId;
  }

  void registerNativeExoPlayerSession({
    required String videoId,
    required String quality,
    required String fitMode,
    String? audioTrackId,
    String? subtitleCode,
    double speed = 1.0,
  }) {
    final changed = _nativeVideoId != videoId || !_isNativeExoPlayerActive;
    _isNativeExoPlayerActive = true;
    _nativeVideoId = videoId;
    _nativeQuality = quality;
    _nativeAudioTrackId = audioTrackId;
    _nativeSubtitleCode = subtitleCode;
    _nativeFitMode = fitMode;
    _nativeSpeed = speed;
    if (changed) {
      _currentVideoId = null;
      _currentVideoUrl = null;
      _lastPosition = Duration.zero;
    }
    _safeNotifyListeners();
    log('[GlobalPlayer] Native ExoPlayer session: $videoId / $quality');
  }

  void updateNativeExoPlayerSelections({
    String? quality,
    String? audioTrackId,
    String? subtitleCode,
    String? fitMode,
    double? speed,
  }) {
    _nativeQuality = quality ?? _nativeQuality;
    _nativeAudioTrackId = audioTrackId ?? _nativeAudioTrackId;
    _nativeSubtitleCode = subtitleCode ?? _nativeSubtitleCode;
    _nativeFitMode = fitMode ?? _nativeFitMode;
    _nativeSpeed = speed ?? _nativeSpeed;
  }

  void setNativeSubtitleCode(String? subtitleCode) {
    _nativeSubtitleCode = subtitleCode;
  }

  void updateNativeExoPlayerState({
    required bool playing,
    required bool buffering,
    required Duration position,
    required Duration duration,
  }) {
    _isNativeExoPlayerActive = _nativeVideoId != null;
    _nativeWasPlaying = playing;
    _nativeBuffering = buffering;
    _nativePosition = position;
    _nativeDuration = duration;
    _wasPlaying = playing;
  }

  void clearNativeExoPlayerSession() {
    _isNativeExoPlayerActive = false;
    _nativeVideoId = null;
    _nativeQuality = null;
    _nativeAudioTrackId = null;
    _nativeSubtitleCode = null;
    _nativeFitMode = null;
    _nativeSpeed = 1.0;
    _nativePosition = Duration.zero;
    _nativeDuration = Duration.zero;
    _nativeWasPlaying = false;
    _nativeBuffering = false;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    final phase = WidgetsBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
      return;
    }

    if (_notifyScheduled) return;
    _notifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      notifyListeners();
    });
  }

  void setCurrentAudioTrackId(String? trackId) {
    _currentAudioTrackId = trackId;
    log('[GlobalPlayer] Set audio track ID: $trackId');
  }

  void setCurrentSubtitleCode(String? subtitleCode) {
    _currentSubtitleCode = subtitleCode;
    log('[GlobalPlayer] Set subtitle code: $subtitleCode');
  }

  /// Set the current video ID - called by media player when playback starts
  void setCurrentVideoId(String videoId) {
    _currentVideoId = videoId;
    notifyListeners();
    log('[GlobalPlayer] Set current video ID: $videoId');
  }

  /// Check if we're already playing (or have paused) the requested video
  /// Returns true if the player has this video loaded in a stable state
  /// Returns false if player is still initializing or in an unstable state
  bool isPlayingVideo(String videoId) {
    if (_isNativeExoPlayerActive && _nativeVideoId == videoId) {
      return _nativeWasPlaying || _nativePosition > Duration.zero;
    }

    if (_currentVideoId != videoId || _player == null) {
      return false;
    }

    // Check if player is in a stable state (not buffering/starting)
    // Return true if we're playing, paused with progress, or have a video URL loaded
    final isStable = _player!.state.playing ||
        (_player!.state.position.inSeconds > 0) ||
        (_player!.state.duration.inSeconds > 0) ||
        (_currentVideoUrl != null && _currentVideoUrl!.isNotEmpty);

    return isStable;
  }

  /// Check if we have a video loaded (playing or paused) with the given ID
  /// This is less strict than isPlayingVideo - just checks if video is loaded
  /// Checks video ID match and either URL is set OR player has active media (duration > 0)
  bool hasVideoLoaded(String videoId) {
    if (_isNativeExoPlayerActive && _nativeVideoId == videoId) {
      final result = _nativeWasPlaying ||
          _nativePosition > Duration.zero ||
          _nativeDuration > Duration.zero ||
          _nativeQuality != null;
      log('[GlobalPlayer] hasVideoLoaded($videoId): native=$result (pos=${_nativePosition.inSeconds}s, dur=${_nativeDuration.inSeconds}s, quality=$_nativeQuality)');
      return result;
    }

    if (_currentVideoId != videoId || _player == null) {
      log('[GlobalPlayer] hasVideoLoaded($videoId): false - ID mismatch or no player. _currentVideoId=$_currentVideoId');
      return false;
    }

    // Check if video URL is set (for GlobalPlayer-managed playback)
    final hasUrl = _currentVideoUrl != null && _currentVideoUrl!.isNotEmpty;

    // OR check if player has ACTUALLY loaded media (for externally-managed playback like NewPipe)
    // Media is loaded when:
    // - duration > 0 (video metadata received), OR
    // - position > 0 (has played some), OR
    // - _lastPosition > 0 (saved state from PiP/navigation - video was playing before)
    // Note: We do NOT check playing=true alone, as that can be true before media loads
    final hasLoadedMedia = _player!.state.duration.inSeconds > 0 ||
        _player!.state.position.inSeconds > 0 ||
        _lastPosition.inSeconds > 0;

    final result = hasUrl || hasLoadedMedia;
    log('[GlobalPlayer] hasVideoLoaded($videoId): result=$result, hasUrl=$hasUrl, hasLoadedMedia=$hasLoadedMedia (dur=${_player!.state.duration.inSeconds}s, pos=${_player!.state.position.inSeconds}s, lastPos=${_lastPosition.inSeconds}s)');
    return result;
  }

  /// STRICT: Enforce that the current video matches the expected video ID
  /// If there's a mismatch, immediately stop the wrong video
  /// Returns true if video matches or was successfully stopped
  Future<bool> enforceVideoId(String expectedVideoId) async {
    final activeVideoId = currentVideoId;
    if (activeVideoId == null) {
      // No video playing, OK
      return true;
    }

    if (activeVideoId == expectedVideoId) {
      // Correct video is playing, OK
      log('[GlobalPlayer] ✓ Video ID matches: $expectedVideoId');
      return true;
    }

    // CRITICAL: Wrong video is playing!
    log('[GlobalPlayer] ✗ MISMATCH DETECTED! Playing: $_currentVideoId, Expected: $expectedVideoId');
    log('[GlobalPlayer] ⚠️ STOPPING wrong video immediately');

    // Immediately stop the wrong video
    await stopAndClear();

    return true;
  }

  /// STRICT: Validate before starting playback
  /// Ensures no other video is playing before starting
  Future<bool> validateBeforePlay(String videoId) async {
    final activeVideoId = currentVideoId;
    if (activeVideoId != null && activeVideoId != videoId) {
      log('[GlobalPlayer] ⚠️ Preventing play: another video ($_currentVideoId) is still active');
      log('[GlobalPlayer] 🛑 Stopping old video before starting new one');
      await stopAndClear();
      // Small delay to ensure cleanup
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return true;
  }

  /// Save current playback state before navigation
  void savePlaybackState() {
    if (_isNativeExoPlayerActive) {
      _lastPosition = _nativePosition;
      _wasPlaying = _nativeWasPlaying;
      log('[GlobalPlayer] Saved native state: position=${_lastPosition.inSeconds}s, wasPlaying=$_wasPlaying');
      return;
    }

    if (_player != null) {
      _lastPosition = _player!.state.position;
      _wasPlaying = _player!.state.playing;
      log('[GlobalPlayer] Saved state: position=${_lastPosition.inSeconds}s, wasPlaying=$_wasPlaying');
    }
  }

  /// Restore playback state after navigation
  Future<void> restorePlaybackState() async {
    if (_player != null) {
      if (_lastPosition.inSeconds > 0) {
        await _player!.seek(_lastPosition);
        log('[GlobalPlayer] Restored position: ${_lastPosition.inSeconds}s');
      }
      if (_wasPlaying) {
        await _player!.play();
        log('[GlobalPlayer] Restored playback');
      }
    }
  }

  /// Enter PiP mode - saves state and marks as PiP
  void enterPipMode() {
    if (_isPipMode) return;
    savePlaybackState();
    _isPipMode = true;
    notifyListeners();
    log('[GlobalPlayer] Entered PiP mode');
  }

  /// Exit PiP mode - restores state
  Future<void> exitPipMode() async {
    if (!_isPipMode) return;
    _isPipMode = false;
    notifyListeners();
    log('[GlobalPlayer] Exited PiP mode');
  }

  /// Enter system (Android native) PiP mode
  /// This creates a floating window that persists when app is minimized
  Future<bool> enterSystemPipMode(
      {int aspectRatioWidth = 16, int aspectRatioHeight = 9}) async {
    if (currentVideoId == null) {
      log('[GlobalPlayer] Cannot enter system PiP - no video playing');
      return false;
    }

    final success = await _pipService.enterPipMode(
      aspectRatioWidth: aspectRatioWidth,
      aspectRatioHeight: aspectRatioHeight,
    );

    if (success) {
      log('[GlobalPlayer] Entered system PiP mode');
    }
    return success;
  }

  /// Enable auto-PiP (enters PiP when user presses home button while video is playing)
  Future<void> enableAutoPip(bool enabled) async {
    await _pipService.enableAutoPip(enabled);
    log('[GlobalPlayer] Auto-PiP enabled: $enabled');
  }

  /// Update native side about playback state (for auto-PiP)
  Future<void> updatePlaybackStateForPip() async {
    final isPlaying = _isNativeExoPlayerActive
        ? _nativeWasPlaying
        : (_player?.state.playing ?? false);
    await _pipService.setVideoPlaying(isPlaying);
  }

  /// Initialize player for a new video
  /// If already playing this video, just restore state
  Future<bool> initializeForVideo({
    required String videoId,
    required String videoUrl,
    String? audioUrl,
    int seekToSeconds = 0,
    Map<String, String>? httpHeaders,
  }) async {
    // STRICT: Validate before initializing
    await validateBeforePlay(videoId);
    clearNativeExoPlayerSession();

    // If already playing this video, don't reinitialize
    if (_currentVideoId == videoId &&
        _player != null &&
        _currentVideoUrl == videoUrl) {
      log('[GlobalPlayer] Already playing video $videoId, restoring state');
      await restorePlaybackState();
      return true;
    }

    // STRICT: Final enforcement check before starting playback
    await enforceVideoId(videoId);

    try {
      // Create player if needed
      _player ??= Player();
      _videoController ??= VideoController(player);

      final headers = httpHeaders ??
          {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          };

      // Open the video
      await _player!.open(
        Media(videoUrl, httpHeaders: headers),
        play: false,
      );

      // Set audio track if provided
      if (audioUrl != null && audioUrl.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 100));
        try {
          await _player!.setAudioTrack(AudioTrack.uri(audioUrl));
          log('[GlobalPlayer] Set audio track');
        } catch (e) {
          log('[GlobalPlayer] Error setting audio: $e');
        }
      }

      // Seek to position if needed
      if (seekToSeconds > 0) {
        await _player!.seek(Duration(seconds: seekToSeconds));
        log('[GlobalPlayer] Seeked to $seekToSeconds s');
      }

      // Start playback
      await _player!.play();

      // Update state
      _currentVideoId = videoId;
      _currentVideoUrl = videoUrl;
      _isPipMode = false;
      _lastPosition = Duration.zero;
      _wasPlaying = true;

      // Notify native side that video is playing (for auto-PiP)
      await _pipService.setVideoPlaying(true);

      notifyListeners();
      log('[GlobalPlayer] Initialized video $videoId');
      return true;
    } catch (e) {
      log('[GlobalPlayer] Error initializing: $e');
      return false;
    }
  }

  /// Change video quality without full reinitialization
  Future<void> changeQuality({
    required String videoUrl,
    String? audioUrl,
  }) async {
    if (_player == null) return;

    try {
      final currentPosition = _player!.state.position;
      final wasPlaying = _player!.state.playing;

      await _player!.open(
        Media(
          videoUrl,
          httpHeaders: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
        play: false,
      );

      if (audioUrl != null && audioUrl.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 100));
        await _player!.setAudioTrack(AudioTrack.uri(audioUrl));
      }

      if (currentPosition.inSeconds > 0) {
        await _player!.seek(currentPosition);
      }

      if (wasPlaying) {
        await _player!.play();
      }

      _currentVideoUrl = videoUrl;
      log('[GlobalPlayer] Quality changed');
    } catch (e) {
      log('[GlobalPlayer] Error changing quality: $e');
    }
  }

  /// Pause player temporarily (e.g., when opening shorts)
  /// Unlike stopAndClear, this preserves the video state so it can be resumed
  Future<void> pausePlayback() async {
    if (_player != null && _player!.state.playing) {
      savePlaybackState();
      await _player!.pause();
      log('[GlobalPlayer] Paused playback (state preserved)');
    }
  }

  /// Resume playback if it was paused
  Future<void> resumePlayback() async {
    if (_player != null && _currentVideoId != null && _wasPlaying) {
      await _player!.play();
      log('[GlobalPlayer] Resumed playback');
    }
  }

  /// Stop and clear player (e.g., when app goes to background for extended time)
  Future<void> stopAndClear() async {
    savePlaybackState();

    // CRITICAL: Clear video ID FIRST, before any async operations
    // This prevents race conditions where other code checks currentVideoId
    // while we're still stopping the player
    final stoppingVideoId = currentVideoId;
    _currentVideoId = null;
    _currentVideoUrl = null;
    _isPipMode = false;
    _lastPosition = Duration.zero;
    _wasPlaying = false;
    _currentAudioTrackId = null;
    _currentSubtitleCode = null;
    _isNativeExoPlayerActive = false;
    _nativeVideoId = null;
    _nativeQuality = null;
    _nativeAudioTrackId = null;
    _nativeSubtitleCode = null;
    _nativeFitMode = null;
    _nativeSpeed = 1.0;
    _nativePosition = Duration.zero;
    _nativeDuration = Duration.zero;
    _nativeWasPlaying = false;
    _nativeBuffering = false;

    // Notify native side that video stopped (for auto-PiP)
    await _pipService.setVideoPlaying(false);
    await ExoPlayerNotificationBridge.instance.stop();

    // Clear media notification
    await clearMediaNotification();

    log('[GlobalPlayer] IMMEDIATELY cleared video ID: $stoppingVideoId');
    notifyListeners();

    // Now stop the player
    if (_player != null) {
      try {
        await _player!.pause();
        await _player!.stop();
        // Open an empty media to fully reset the player
        await _player!.open(Media(''));
        log('[GlobalPlayer] Player stopped and reset');
      } catch (e) {
        log('[GlobalPlayer] Error during stop: $e');
      }
    }

    log('[GlobalPlayer] Stop and clear complete');
  }

  /// Full dispose - only call when completely done with player
  void disposePlayer() {
    _player?.dispose();
    _player = null;
    _videoController = null;
    _currentVideoId = null;
    _currentVideoUrl = null;
    _isPipMode = false;
    _lastPosition = Duration.zero;
    _wasPlaying = false;
    clearNativeExoPlayerSession();
    _isInitialized = false;
    log('[GlobalPlayer] Disposed');
  }

  /// Get current playback position
  Duration get currentPosition => _player?.state.position ?? Duration.zero;
  Duration get effectiveCurrentPosition =>
      _isNativeExoPlayerActive ? _nativePosition : currentPosition;

  /// Get total duration
  Duration get totalDuration => _player?.state.duration ?? Duration.zero;
  Duration get effectiveTotalDuration =>
      _isNativeExoPlayerActive ? _nativeDuration : totalDuration;

  /// Is currently playing
  bool get isPlaying => _isNativeExoPlayerActive
      ? _nativeWasPlaying
      : (_player?.state.playing ?? false);

  /// Is buffering
  bool get isBuffering => _isNativeExoPlayerActive
      ? _nativeBuffering
      : (_player?.state.buffering ?? false);

  /// Update media notification with current video info
  /// Call this when starting a new video to show notification controls
  Future<void> updateMediaNotification({
    required String title,
    required String artist,
    String? thumbnailUrl,
    Duration? duration,
  }) async {
    // Ensure audio service is initialized before updating notification
    final audioHandler = await ensureAudioServiceInitialized();
    log('[GlobalPlayer] updateMediaNotification called - audioHandler: ${audioHandler != null}, videoId: $_currentVideoId');
    if (audioHandler != null && _currentVideoId != null) {
      await audioHandler.setMediaItem(
        id: _currentVideoId!,
        title: title,
        artist: artist,
        artUri: thumbnailUrl,
        duration: duration,
      );
      log('[GlobalPlayer] Updated media notification: $title by $artist');
    } else {
      log('[GlobalPlayer] Cannot update notification - audioHandler: ${audioHandler != null}, videoId: $_currentVideoId');
    }
  }

  /// Clear media notification
  Future<void> clearMediaNotification() async {
    final audioHandler = getAudioHandler();
    if (audioHandler != null) {
      await audioHandler.clearMedia();
      log('[GlobalPlayer] Cleared media notification');
    }
  }
}
