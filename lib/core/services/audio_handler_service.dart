import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:fluxtube/core/services/exoplayer_notification_bridge.dart';

/// Media session (notification / lock screen controls) for the native
/// ExoPlayer. The player pushes its state in via [updateExternalPlaybackState];
/// session commands are forwarded to it through [ExoPlayerNotificationBridge].
class FluxTubeAudioHandler extends BaseAudioHandler with SeekHandler {
  MediaItem? _currentMediaItem;
  bool _playing = false;
  bool _buffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _speed = 1.0;

  Future<void> Function()? _onPlay;
  Future<void> Function()? _onPause;
  Future<void> Function()? _onStop;
  Future<void> Function(Duration position)? _onSeek;

  void _publishState() {
    if (_currentMediaItem == null) return;

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_playing) MediaControl.pause else MediaControl.play,
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
      processingState:
          _buffering ? AudioProcessingState.buffering : AudioProcessingState.ready,
      playing: _playing,
      updatePosition: _position,
      bufferedPosition: _position,
      speed: _speed,
    ));
  }

  /// Callbacks so the visible player widget can mirror session commands.
  void configureExternalControls({
    Future<void> Function()? play,
    Future<void> Function()? pause,
    Future<void> Function()? stop,
    Future<void> Function(Duration position)? seek,
  }) {
    _onPlay = play;
    _onPause = pause;
    _onStop = stop;
    _onSeek = seek;
  }

  Future<void> setExternalMediaItem({
    required String id,
    required String title,
    required String artist,
    String? artUri,
    Duration? duration,
  }) async {
    _currentMediaItem = MediaItem(
      id: id,
      title: title,
      artist: artist,
      artUri: artUri != null && artUri.isNotEmpty ? Uri.tryParse(artUri) : null,
      duration: duration ?? _duration,
      playable: true,
    );
    mediaItem.add(_currentMediaItem);
    _publishState();
  }

  /// Kept for callers that predate the native-only player; same as
  /// [setExternalMediaItem].
  Future<void> setMediaItem({
    required String id,
    required String title,
    required String artist,
    String? artUri,
    Duration? duration,
  }) =>
      setExternalMediaItem(
        id: id,
        title: title,
        artist: artist,
        artUri: artUri,
        duration: duration,
      );

  Future<void> updateExternalPlaybackState({
    required bool playing,
    required Duration position,
    required Duration duration,
    required bool buffering,
    double speed = 1.0,
  }) async {
    _playing = playing;
    _position = position;
    _duration = duration;
    _buffering = buffering;
    _speed = speed;

    if (_currentMediaItem != null &&
        duration.inMilliseconds > 0 &&
        _currentMediaItem!.duration != duration) {
      _currentMediaItem = _currentMediaItem!.copyWith(duration: duration);
      mediaItem.add(_currentMediaItem);
    }

    _publishState();
  }

  Future<void> clearMedia() async {
    _currentMediaItem = null;
    _onPlay = null;
    _onPause = null;
    _onStop = null;
    _onSeek = null;
    mediaItem.add(null);
    playbackState.add(PlaybackState(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  @override
  Future<void> play() async {
    await ExoPlayerNotificationBridge.instance.play();
    await _onPlay?.call();
    _playing = true;
    _publishState();
  }

  @override
  Future<void> pause() async {
    await ExoPlayerNotificationBridge.instance.pause();
    await _onPause?.call();
    _playing = false;
    _publishState();
  }

  @override
  Future<void> stop() async {
    await ExoPlayerNotificationBridge.instance.stop();
    await _onStop?.call();
    await clearMedia();
  }

  @override
  Future<void> seek(Duration position) async {
    await ExoPlayerNotificationBridge.instance.seek(position);
    await _onSeek?.call(position);
    _position = position;
    _publishState();
  }

  @override
  Future<void> fastForward() async {
    _position = await ExoPlayerNotificationBridge.instance
        .seekBy(const Duration(seconds: 10));
    _publishState();
  }

  @override
  Future<void> rewind() async {
    _position = await ExoPlayerNotificationBridge.instance
        .seekBy(const Duration(seconds: -10));
    _publishState();
  }

  @override
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    _publishState();
  }
}

FluxTubeAudioHandler? _audioHandler;
bool _initializationAttempted = false;
bool _isInitializing = false;

/// Initialize the audio service. Returns null on failure (non-fatal: the app
/// just runs without notification controls).
Future<FluxTubeAudioHandler?> initAudioService() async {
  if (_audioHandler != null) return _audioHandler;
  if (_initializationAttempted) return null;

  if (_isInitializing) {
    while (_isInitializing) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    return _audioHandler;
  }

  _isInitializing = true;
  _initializationAttempted = true;

  try {
    _audioHandler = await AudioService.init(
      builder: () => FluxTubeAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.fazilvk.fluxtube.audio',
        androidNotificationChannelName: 'FluxTube Playback',
        androidNotificationChannelDescription: 'Media playback controls',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'drawable/ic_notification',
        fastForwardInterval: const Duration(seconds: 10),
        rewindInterval: const Duration(seconds: 10),
      ),
    );
    return _audioHandler;
  } catch (e) {
    log('[AudioHandler] Audio service initialization failed (non-fatal): $e');
    return null;
  } finally {
    _isInitializing = false;
  }
}

Future<FluxTubeAudioHandler?> ensureAudioServiceInitialized() async {
  if (_audioHandler != null) return _audioHandler;
  return initAudioService();
}

FluxTubeAudioHandler? getAudioHandler() => _audioHandler;
