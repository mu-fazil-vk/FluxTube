import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/core/services/exoplayer_notification_bridge.dart';

/// Audio handler for background playback notification controls
/// Provides media session controls (play/pause/seek) in notification and lock screen
class FluxTubeAudioHandler extends BaseAudioHandler with SeekHandler {
  // Use the singleton instance
  GlobalPlayerController get _globalPlayer => GlobalPlayerController();

  // Stream subscriptions for player state
  StreamSubscription? _playingSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _bufferingSubscription;

  // Current media item info
  MediaItem? _currentMediaItem;
  bool _useExternalPlayer = false;
  bool _externalPlaying = false;
  bool _externalBuffering = false;
  Duration _externalPosition = Duration.zero;
  Duration _externalDuration = Duration.zero;
  double _externalSpeed = 1.0;

  Future<void> Function()? _externalPlay;
  Future<void> Function()? _externalPause;
  Future<void> Function()? _externalStop;
  Future<void> Function(Duration position)? _externalSeek;

  FluxTubeAudioHandler() {
    // Delay listener setup to ensure player is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      _setupPlayerListeners();
    });
  }

  /// Setup listeners to sync player state with audio service
  void _setupPlayerListeners() {
    // Cancel any existing subscriptions first
    _playingSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferingSubscription?.cancel();

    final player = _globalPlayer.player;

    // Listen to playing state changes
    _playingSubscription = player.stream.playing.listen((playing) {
      log('[AudioHandler] Playing state changed: $playing');
      _updatePlaybackState();
    });

    // Listen to position changes (throttled)
    _positionSubscription = player.stream.position.listen((position) {
      _updatePlaybackState();
    });

    // Listen to duration changes
    _durationSubscription = player.stream.duration.listen((duration) {
      log('[AudioHandler] Duration changed: ${duration.inSeconds}s');
      if (_currentMediaItem != null && duration.inMilliseconds > 0) {
        // Update media item with duration
        _currentMediaItem = _currentMediaItem!.copyWith(duration: duration);
        mediaItem.add(_currentMediaItem);
        _updatePlaybackState();
      }
    });

    // Listen to buffering state
    _bufferingSubscription = player.stream.buffering.listen((buffering) {
      _updatePlaybackState();
    });

    log('[AudioHandler] Player listeners set up');
  }

  /// Update playback state for notification
  void _updatePlaybackState() {
    if (_currentMediaItem == null) {
      // Don't update if no media is set
      return;
    }

    try {
      if (_useExternalPlayer) {
        _updateExternalPlaybackStateStream();
        return;
      }

      final player = _globalPlayer.player;
      final isPlaying = player.state.playing;
      final position = player.state.position;
      final duration = player.state.duration;
      final buffering = player.state.buffering;

      // Update duration in media item if it changed
      final currentDuration = _currentMediaItem?.duration;
      if (duration.inSeconds > 0 &&
          (currentDuration == null || currentDuration.inSeconds == 0)) {
        _currentMediaItem = _currentMediaItem!.copyWith(duration: duration);
        mediaItem.add(_currentMediaItem);
      }

      playbackState.add(PlaybackState(
        controls: [
          MediaControl.rewind,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.fastForward,
          MediaAction.rewind,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: buffering
            ? AudioProcessingState.buffering
            : AudioProcessingState.ready,
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: player.state.buffer,
        speed: player.state.rate,
      ));
    } catch (e) {
      log('[AudioHandler] Error updating playback state: $e');
    }
  }

  void _updateExternalPlaybackStateStream() {
    if (_currentMediaItem == null) return;

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_externalPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.fastForward,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.fastForward,
        MediaAction.rewind,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _externalBuffering
          ? AudioProcessingState.buffering
          : AudioProcessingState.ready,
      playing: _externalPlaying,
      updatePosition: _externalPosition,
      bufferedPosition: _externalPosition,
      speed: _externalSpeed,
    ));
  }

  void configureExternalControls({
    Future<void> Function()? play,
    Future<void> Function()? pause,
    Future<void> Function()? stop,
    Future<void> Function(Duration position)? seek,
  }) {
    _externalPlay = play;
    _externalPause = pause;
    _externalStop = stop;
    _externalSeek = seek;
  }

  Future<void> setExternalMediaItem({
    required String id,
    required String title,
    required String artist,
    String? artUri,
    Duration? duration,
  }) async {
    _useExternalPlayer = true;
    _currentMediaItem = MediaItem(
      id: id,
      title: title,
      artist: artist,
      artUri: artUri != null && artUri.isNotEmpty ? Uri.tryParse(artUri) : null,
      duration: duration ?? _externalDuration,
      playable: true,
    );
    mediaItem.add(_currentMediaItem);
    _updateExternalPlaybackStateStream();
    log('[AudioHandler] External media item set: $title by $artist');
  }

  Future<void> updateExternalPlaybackState({
    required bool playing,
    required Duration position,
    required Duration duration,
    required bool buffering,
    double speed = 1.0,
  }) async {
    _useExternalPlayer = true;
    _externalPlaying = playing;
    _externalPosition = position;
    _externalDuration = duration;
    _externalBuffering = buffering;
    _externalSpeed = speed;

    if (_currentMediaItem != null &&
        duration.inMilliseconds > 0 &&
        _currentMediaItem!.duration != duration) {
      _currentMediaItem = _currentMediaItem!.copyWith(duration: duration);
      mediaItem.add(_currentMediaItem);
    }

    _updateExternalPlaybackStateStream();
  }

  /// Set the current media item (video/audio info) for notification
  Future<void> setMediaItem({
    required String id,
    required String title,
    required String artist,
    String? artUri,
    Duration? duration,
  }) async {
    log('[AudioHandler] setMediaItem called: $title by $artist, artUri: $artUri, duration: $duration');

    // Get actual duration from player if not provided
    final actualDuration = duration ??
        (_globalPlayer.player.state.duration.inSeconds > 0
            ? _globalPlayer.player.state.duration
            : Duration.zero);

    _useExternalPlayer = false;
    _externalPlay = null;
    _externalPause = null;
    _externalStop = null;
    _externalSeek = null;

    _currentMediaItem = MediaItem(
      id: id,
      title: title,
      artist: artist,
      artUri: artUri != null && artUri.isNotEmpty ? Uri.tryParse(artUri) : null,
      duration: actualDuration,
      playable: true,
    );

    // Add media item to stream
    mediaItem.add(_currentMediaItem);
    log('[AudioHandler] Media item added to stream: ${_currentMediaItem?.title}');

    // Update playback state to show notification
    _updatePlaybackState();
  }

  /// Clear the current media (when video stops)
  Future<void> clearMedia() async {
    _currentMediaItem = null;
    _useExternalPlayer = false;
    _externalPlay = null;
    _externalPause = null;
    _externalStop = null;
    _externalSeek = null;
    mediaItem.add(null);
    playbackState.add(PlaybackState(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    log('[AudioHandler] Media cleared');
  }

  // --- Audio Service Controls ---

  @override
  Future<void> play() async {
    if (_useExternalPlayer) {
      await ExoPlayerNotificationBridge.instance.play();
      await _externalPlay?.call();
      _externalPlaying = true;
      _updateExternalPlaybackStateStream();
      return;
    }

    log('[AudioHandler] Play command received - hasActivePlayer: ${_globalPlayer.hasActivePlayer}');
    try {
      await _globalPlayer.player.play();
      log('[AudioHandler] Play executed successfully');
    } catch (e) {
      log('[AudioHandler] Play error: $e');
    }
  }

  @override
  Future<void> pause() async {
    if (_useExternalPlayer) {
      await ExoPlayerNotificationBridge.instance.pause();
      await _externalPause?.call();
      _externalPlaying = false;
      _updateExternalPlaybackStateStream();
      return;
    }

    log('[AudioHandler] Pause command received - hasActivePlayer: ${_globalPlayer.hasActivePlayer}');
    try {
      await _globalPlayer.player.pause();
      log('[AudioHandler] Pause executed successfully');
    } catch (e) {
      log('[AudioHandler] Pause error: $e');
    }
  }

  @override
  Future<void> stop() async {
    if (_useExternalPlayer) {
      await ExoPlayerNotificationBridge.instance.stop();
      await _externalStop?.call();
      await clearMedia();
      return;
    }

    log('[AudioHandler] Stop command received');
    try {
      await _globalPlayer.stopAndClear();
      await clearMedia();
      log('[AudioHandler] Stop executed successfully');
    } catch (e) {
      log('[AudioHandler] Stop error: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (_useExternalPlayer) {
      await ExoPlayerNotificationBridge.instance.seek(position);
      await _externalSeek?.call(position);
      _externalPosition = position;
      _updateExternalPlaybackStateStream();
      return;
    }

    log('[AudioHandler] Seek command to ${position.inSeconds}s');
    try {
      await _globalPlayer.player.seek(position);
      log('[AudioHandler] Seek executed successfully');
    } catch (e) {
      log('[AudioHandler] Seek error: $e');
    }
  }

  @override
  Future<void> fastForward() async {
    if (_useExternalPlayer) {
      final position = await ExoPlayerNotificationBridge.instance
          .seekBy(const Duration(seconds: 10));
      _externalPosition = position;
      _updateExternalPlaybackStateStream();
      return;
    }

    log('[AudioHandler] FastForward command received');
    try {
      final current = _globalPlayer.player.state.position;
      final duration = _globalPlayer.player.state.duration;
      final newPosition = current + const Duration(seconds: 10);
      if (newPosition < duration) {
        await seek(newPosition);
      } else {
        await seek(duration);
      }
      log('[AudioHandler] FastForward executed successfully');
    } catch (e) {
      log('[AudioHandler] FastForward error: $e');
    }
  }

  @override
  Future<void> rewind() async {
    if (_useExternalPlayer) {
      final position = await ExoPlayerNotificationBridge.instance
          .seekBy(const Duration(seconds: -10));
      _externalPosition = position;
      _updateExternalPlaybackStateStream();
      return;
    }

    log('[AudioHandler] Rewind command received');
    try {
      final current = _globalPlayer.player.state.position;
      final newPosition = current - const Duration(seconds: 10);
      if (newPosition > Duration.zero) {
        await seek(newPosition);
      } else {
        await seek(Duration.zero);
      }
      log('[AudioHandler] Rewind executed successfully');
    } catch (e) {
      log('[AudioHandler] Rewind error: $e');
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    if (_useExternalPlayer) {
      _externalSpeed = speed;
      _updateExternalPlaybackStateStream();
      return;
    }

    await _globalPlayer.player.setRate(speed);
    _updatePlaybackState();
    log('[AudioHandler] Speed set to $speed');
  }

  /// Dispose subscriptions
  void dispose() {
    _playingSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferingSubscription?.cancel();
  }
}

/// Global audio handler instance
FluxTubeAudioHandler? _audioHandler;
bool _initializationAttempted = false;
bool _isInitializing = false;

/// Initialize the audio service with our handler
/// Returns null if initialization fails (non-fatal - app continues without notification controls)
Future<FluxTubeAudioHandler?> initAudioService() async {
  if (_audioHandler != null) {
    return _audioHandler;
  }

  if (_initializationAttempted) {
    // Already tried and failed, don't retry
    return null;
  }

  if (_isInitializing) {
    // Wait for ongoing initialization
    while (_isInitializing) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    return _audioHandler;
  }

  _isInitializing = true;
  _initializationAttempted = true;

  try {
    log('[AudioHandler] Initializing audio service...');
    _audioHandler = await AudioService.init(
      builder: () => FluxTubeAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.fazilvk.fluxtube.audio',
        androidNotificationChannelName: 'FluxTube Playback',
        androidNotificationChannelDescription: 'Media playback controls',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause:
            true, // Keep notification when paused but allow dismissal
        androidNotificationIcon: 'drawable/ic_notification',
        fastForwardInterval: const Duration(seconds: 10),
        rewindInterval: const Duration(seconds: 10),
      ),
    );

    log('[AudioHandler] Audio service initialized successfully');
    return _audioHandler;
  } catch (e) {
    // Non-fatal error - app continues without notification controls
    log('[AudioHandler] Audio service initialization failed (non-fatal): $e');
    log('[AudioHandler] Background playback notification controls will be unavailable');
    return null;
  } finally {
    _isInitializing = false;
  }
}

/// Ensure audio service is initialized before use
/// Call this before updating media notification
Future<FluxTubeAudioHandler?> ensureAudioServiceInitialized() async {
  if (_audioHandler != null) {
    return _audioHandler;
  }
  return initAudioService();
}

/// Get the audio handler instance (may be null if initialization failed)
FluxTubeAudioHandler? getAudioHandler() => _audioHandler;
