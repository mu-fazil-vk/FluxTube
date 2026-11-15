import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluxtube/core/services/pip_service.dart';
import 'package:fluxtube/core/services/audio_handler_service.dart';
import 'package:fluxtube/core/services/exoplayer_notification_bridge.dart';

/// Global session state for the single shared native ExoPlayer, so playback
/// survives navigation between the watch screen, fullscreen and PiP.
class GlobalPlayerController extends ChangeNotifier {
  static final GlobalPlayerController _instance =
      GlobalPlayerController._internal();
  factory GlobalPlayerController() => _instance;
  GlobalPlayerController._internal() {
    _pipService.addPipModeListener(_onSystemPipModeChanged);
  }

  bool _isPipMode = false;
  bool _isSystemPipMode = false;
  Duration _lastPosition = Duration.zero;
  bool _isNativeExoPlayerActive = false;
  bool _notifyScheduled = false;

  final PipService _pipService = PipService();

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
  bool _resumeNativeAfterPause = false;
  bool _nativeBuffering = false;

  void _onSystemPipModeChanged(bool isInPipMode) {
    _isSystemPipMode = isInPipMode;
    log('[GlobalPlayer] System PiP mode changed: $isInPipMode');
    notifyListeners();
  }

  String? get currentVideoId => _nativeVideoId;
  bool get isPipMode => _isPipMode;
  bool get isSystemPipMode => _isSystemPipMode;
  Duration get lastPosition =>
      _isNativeExoPlayerActive ? _nativePosition : _lastPosition;
  Duration get livePosition => _nativePosition;
  bool get hasActivePlayer => hasNativeExoPlayer;
  bool get hasNativeExoPlayer =>
      _isNativeExoPlayerActive && _nativeVideoId != null;
  PipService get pipService => _pipService;

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
    if (changed) _lastPosition = Duration.zero;
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
  }

  void setCurrentSubtitleCode(String? subtitleCode) {
    _currentSubtitleCode = subtitleCode;
  }

  /// Whether this video is loaded in the native player in a stable state.
  bool isPlayingVideo(String videoId) {
    return isNativeVideoLoaded(videoId) &&
        (_nativeWasPlaying || _nativePosition > Duration.zero);
  }

  /// Less strict than [isPlayingVideo]: any sign the video was loaded.
  bool hasVideoLoaded(String videoId) {
    return isNativeVideoLoaded(videoId) &&
        (_nativeWasPlaying ||
            _nativePosition > Duration.zero ||
            _nativeDuration > Duration.zero ||
            _nativeQuality != null);
  }

  /// Stops whatever is playing if it isn't [expectedVideoId].
  Future<bool> enforceVideoId(String expectedVideoId) async {
    final activeVideoId = currentVideoId;
    if (activeVideoId == null || activeVideoId == expectedVideoId) return true;
    log('[GlobalPlayer] Mismatch: playing $activeVideoId, expected $expectedVideoId');
    await stopAndClear();
    return true;
  }

  /// Ensures no other video is playing before [videoId] starts.
  Future<bool> validateBeforePlay(String videoId) async {
    final activeVideoId = currentVideoId;
    if (activeVideoId != null && activeVideoId != videoId) {
      await stopAndClear();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return true;
  }

  void savePlaybackState() {
    _lastPosition = _nativePosition;
  }

  void enterPipMode() {
    if (_isPipMode) return;
    savePlaybackState();
    _isPipMode = true;
    notifyListeners();
    log('[GlobalPlayer] Entered PiP mode');
  }

  Future<void> exitPipMode() async {
    if (!_isPipMode) return;
    _isPipMode = false;
    notifyListeners();
    log('[GlobalPlayer] Exited PiP mode');
  }

  /// Enter system (Android native) PiP mode.
  Future<bool> enterSystemPipMode(
      {int aspectRatioWidth = 16, int aspectRatioHeight = 9}) async {
    if (currentVideoId == null) return false;
    return _pipService.enterPipMode(
      aspectRatioWidth: aspectRatioWidth,
      aspectRatioHeight: aspectRatioHeight,
    );
  }

  Future<void> enableAutoPip(bool enabled) async {
    await _pipService.enableAutoPip(enabled);
  }

  Future<void> updatePlaybackStateForPip() async {
    await _pipService.setVideoPlaying(_nativeWasPlaying);
  }

  /// For timestamp links in comments and descriptions.
  Future<void> seekTo(Duration position) async {
    if (_isNativeExoPlayerActive) {
      await ExoPlayerNotificationBridge.instance.seek(position);
    }
  }

  /// Pause temporarily (e.g. opening Shorts), remembering whether to resume.
  Future<void> pausePlayback() async {
    if (!_isNativeExoPlayerActive) return;
    _resumeNativeAfterPause = _nativeWasPlaying;
    await ExoPlayerNotificationBridge.instance.pause();
  }

  Future<void> resumePlayback() async {
    if (_isNativeExoPlayerActive && _resumeNativeAfterPause) {
      _resumeNativeAfterPause = false;
      await ExoPlayerNotificationBridge.instance.play();
    }
  }

  /// Stop and clear the session.
  Future<void> stopAndClear() async {
    savePlaybackState();

    // Clear the video ID before any await, so code checking currentVideoId
    // mid-stop never sees the old video as active.
    final stoppingVideoId = currentVideoId;
    _isPipMode = false;
    _lastPosition = Duration.zero;
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

    await _pipService.setVideoPlaying(false);
    await ExoPlayerNotificationBridge.instance.stop();
    await clearMediaNotification();

    log('[GlobalPlayer] Cleared video: $stoppingVideoId');
    notifyListeners();
  }

  void disposePlayer() {
    _isPipMode = false;
    _lastPosition = Duration.zero;
    clearNativeExoPlayerSession();
  }

  Duration get currentPosition => _nativePosition;
  Duration get effectiveCurrentPosition => _nativePosition;
  Duration get totalDuration => _nativeDuration;
  Duration get effectiveTotalDuration => _nativeDuration;
  bool get isPlaying => _nativeWasPlaying;
  bool get isBuffering => _nativeBuffering;

  Future<void> updateMediaNotification({
    required String title,
    required String artist,
    String? thumbnailUrl,
    Duration? duration,
  }) async {
    final audioHandler = await ensureAudioServiceInitialized();
    final videoId = currentVideoId;
    if (audioHandler != null && videoId != null) {
      await audioHandler.setMediaItem(
        id: videoId,
        title: title,
        artist: artist,
        artUri: thumbnailUrl,
        duration: duration,
      );
    }
  }

  Future<void> clearMediaNotification() async {
    final audioHandler = getAudioHandler();
    if (audioHandler != null) {
      await audioHandler.clearMedia();
    }
  }
}
