import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/core/services/audio_handler_service.dart';
import 'package:fluxtube/core/services/exoplayer_notification_bridge.dart';
import 'package:fluxtube/core/services/pip_service.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/sponsorblock/models/sponsor_segment.dart';
import 'package:fluxtube/presentation/watch/widgets/player/sponsor_segment_markers.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_subtitle.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/models/playback_configuration.dart';
import 'package:fluxtube/domain/watch/playback/models/stream_quality_info.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_playback_resolver.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_stream_helper.dart';
import 'package:fluxtube/core/player/playback_queue.dart';
import 'package:fluxtube/infrastructure/newpipe/newpipe_channel.dart';
import 'package:fluxtube/presentation/watch/widgets/player/player_settings_sheet.dart';
import 'package:fluxtube/presentation/watch/widgets/player/chapter_bar.dart';
import 'package:fluxtube/presentation/watch/widgets/queue_sheet.dart';
import 'package:fluxtube/domain/watch/models/video_chapter.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class NewPipeExoPlayer extends StatefulWidget {
  const NewPipeExoPlayer({
    super.key,
    required this.watchInfo,
    required this.videoId,
    required this.playbackPosition,
    this.defaultQuality = '720p',
    this.videoFitMode = 'contain',
    this.skipInterval = 10,
    this.preferAdaptivePlayback = true,
    this.sponsorSegments = const [],
    this.isFullscreen = false,
    this.isAutoPipEnabled = true,
    this.initialQuality,
    this.initialAudioTrackId,
    this.initialSubtitleCode,
    this.initialSpeed = 1.0,
  });

  final NewPipeWatchResp watchInfo;
  final String videoId;
  final int playbackPosition;
  final String defaultQuality;
  final String videoFitMode;
  final int skipInterval;
  final bool preferAdaptivePlayback;
  final List<SponsorSegment> sponsorSegments;
  final bool isFullscreen;
  final bool isAutoPipEnabled;
  final String? initialQuality;
  final String? initialAudioTrackId;
  final String? initialSubtitleCode;
  final double initialSpeed;

  @override
  State<NewPipeExoPlayer> createState() => _NewPipeExoPlayerState();
}

class _NewPipeExoPlayerState extends State<NewPipeExoPlayer> {
  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];

  // The native ExoPlayer is shared across the inline and fullscreen views, so
  // these live at session scope rather than per widget instance.
  static String? _loopVideoId;
  static bool _skipSilence = false;
  static bool _volumeBoost = false;
  static const _volumeBoostGainMb = 800;

  final _resolver = NewPipePlaybackResolver();
  final _pipService = PipService();
  final _globalPlayer = GlobalPlayerController();
  MethodChannel? _channel;
  Timer? _historyTimer;
  Timer? _hideTimer;
  int _lastSavedPositionSeconds = -1;
  int _positionMs = 0;
  int _durationMs = 0;
  bool _isPlaying = true;
  // ExoPlayer's isPlaying is false while rebuffering even though playback will
  // resume by itself; play/pause must follow the intent (playWhenReady) or a
  // tap during buffering sends "play" to a player that is already playing.
  bool _playIntent = true;
  bool _isBuffering = true;
  bool _showControls = true;
  bool _isScrubbing = false;
  double? _scrubMs;
  double _speed = 1.0;
  late String _fitMode;
  double _brightness = 0.5;
  double _volume = 0.5;
  double _verticalDragStartY = 0;
  double _verticalDragStartValue = 0;
  double _gestureLayerHeight = 0;
  bool _draggingBrightness = false;
  bool _draggingVolume = false;
  int? _skipFlashSeconds;
  Timer? _skipFlashTimer;
  final Set<String> _skippedSegments = {};
  bool _volumeBoostApplied = false;
  bool _isHoldSpeeding = false;
  SponsorSegment? _lastSkippedSegment;
  Timer? _sponsorChipTimer;
  String? _errorMessage;
  String? _currentSubtitle;
  String? _currentCaptionText;
  String? _currentAudioTrackId;
  List<_CaptionCue> _captionCues = [];
  bool _isReloadingLiveUrl = false;
  int? _sleepTimerMinutes;
  Timer? _sleepTimer;
  late List<VideoChapter> _chapters;
  bool _autoAdvanced = false;
  late PlaybackConfiguration _config;
  late List<StreamQualityInfo> _qualities;
  late List<AudioTrackInfo> _audioTracks;
  late String _currentQuality;
  bool _notificationReady = false;
  DateTime _lastNotificationStateUpdate =
      DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _qualities = NewPipeStreamHelper.getAvailableQualities(widget.watchInfo);
    _audioTracks = NewPipeStreamHelper.getAvailableAudioTracks(
      widget.watchInfo.audioStreams ?? [],
    );
    final hasPersistedSession =
        _globalPlayer.isNativeVideoLoaded(widget.videoId);
    _currentAudioTrackId = widget.initialAudioTrackId ??
        (hasPersistedSession ? _globalPlayer.nativeAudioTrackId : null) ??
        (_audioTracks.isEmpty ? null : _audioTracks.first.trackId);
    _currentSubtitle = widget.initialSubtitleCode ??
        (hasPersistedSession ? _globalPlayer.nativeSubtitleCode : null);
    _speed = widget.initialSpeed != 1.0
        ? widget.initialSpeed
        : (hasPersistedSession ? _globalPlayer.nativeSpeed : 1.0);
    _chapters = _resolveChapters();
    _currentQuality = widget.initialQuality ??
        (hasPersistedSession ? _globalPlayer.nativeQuality : null) ??
        (widget.preferAdaptivePlayback ? 'Auto' : _initialQuality());
    _fitMode = hasPersistedSession
        ? (_globalPlayer.nativeFitMode ?? widget.videoFitMode)
        : widget.videoFitMode;
    _config = _resolveConfig(_currentQuality);
    _positionMs = hasPersistedSession
        ? _globalPlayer.nativePosition.inMilliseconds
        : widget.playbackPosition * 1000;
    _registerNativeSession();
    _initDeviceControls();
    _initPip();
    if (_currentSubtitle != null) {
      unawaited(_loadSubtitle(_currentSubtitle));
    }
    _startHistoryTimer();
    _startHideTimer();
  }

  @override
  void didUpdateWidget(covariant NewPipeExoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Some backends deliver streams after the metadata the player was built
    // from (Explode fetches muxed streams separately), so retry resolving
    // until a playable config exists; the AndroidView mounts once it does.
    if (!_config.isValid && !identical(oldWidget.watchInfo, widget.watchInfo)) {
      _qualities = NewPipeStreamHelper.getAvailableQualities(widget.watchInfo);
      _audioTracks = NewPipeStreamHelper.getAvailableAudioTracks(
        widget.watchInfo.audioStreams ?? [],
      );
      _currentAudioTrackId ??=
          _audioTracks.isEmpty ? null : _audioTracks.first.trackId;
      _chapters = _resolveChapters();
      if (widget.initialQuality == null && !widget.preferAdaptivePlayback) {
        _currentQuality = _initialQuality();
      }
      final config = _resolveConfig(_currentQuality);
      if (config.isValid) setState(() => _config = config);
    }
    if (oldWidget.videoFitMode != widget.videoFitMode) {
      _fitMode = widget.videoFitMode;
      unawaited(_channel?.invokeMethod('setResizeMode', {
        'fitMode': _fitMode,
      }));
    }
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    _hideTimer?.cancel();
    _sleepTimer?.cancel();
    _skipFlashTimer?.cancel();
    _sponsorChipTimer?.cancel();
    _saveHistoryPosition();
    _channel?.setMethodCallHandler(null);
    if (!widget.isFullscreen) {
      unawaited(_pipService.setVideoPlaying(false));
    }
    if (widget.isFullscreen) {
      unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
      unawaited(
          SystemChrome.setPreferredOrientations(DeviceOrientation.values));
    }
    super.dispose();
  }

  void _registerNativeSession() {
    _globalPlayer.registerNativeExoPlayerSession(
      videoId: widget.videoId,
      quality: _currentQuality,
      fitMode: _fitMode,
      audioTrackId: _currentAudioTrackId,
      subtitleCode: _currentSubtitle,
      speed: _speed,
    );
  }

  Future<void> _initPip() async {
    if (!Platform.isAndroid || widget.isFullscreen) return;
    await _pipService.setAspectRatio(16, 9);
    await _pipService.enableAutoPip(widget.isAutoPipEnabled);
    await _pipService.setVideoPlaying(_isPlaying);
    await _updatePipSourceRect();
  }

  Future<void> _updatePipSourceRect() async {
    if (!mounted || !Platform.isAndroid || widget.isFullscreen) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final topLeft = renderObject.localToGlobal(Offset.zero);
    await _pipService.setSourceRect(topLeft & renderObject.size);
  }

  Future<void> _initDeviceControls() async {
    try {
      _brightness = await ScreenBrightness().application;
      VolumeController.instance.showSystemUI = false;
      _volume = await VolumeController.instance.getVolume();
    } catch (error) {
      debugPrint('[NewPipeExoPlayer] Device controls unavailable: $error');
    }
  }

  String _initialQuality() {
    return NewPipeStreamHelper.findBestMatchingQuality(
          _qualities,
          widget.defaultQuality,
        )?.label ??
        'Auto';
  }

  PlaybackConfiguration _resolveConfig(String quality) {
    final preferAdaptive = quality == 'Auto';
    final resolved = _resolver.resolve(
      watchResp: widget.watchInfo,
      preferredQuality: preferAdaptive ? _initialQuality() : quality,
      preferHighQuality: true,
      preferAdaptive: preferAdaptive,
    );

    if (resolved.sourceType == MediaSourceType.merging &&
        _currentAudioTrackId != null) {
      final track = _audioTracks
          .where((track) => track.trackId == _currentAudioTrackId)
          .firstOrNull;
      final audioUrl = track?.bestStream?.url;
      if (audioUrl != null && audioUrl.isNotEmpty) {
        return resolved.copyWith(audioUrl: audioUrl);
      }
    }
    return resolved;
  }

  Future<void> _handleLiveUrlExpired() async {
    if (_isReloadingLiveUrl) return;
    _isReloadingLiveUrl = true;
    try {
      final freshInfo = await NewPipeChannel.getStreamInfo(widget.videoId);
      final freshHlsUrl = freshInfo.hlsUrl;
      if (freshHlsUrl != null && freshHlsUrl.isNotEmpty) {
        _config = _config.copyWith(manifestUrl: freshHlsUrl);
        if (mounted) {
          setState(() {
            _errorMessage = null;
            _isBuffering = true;
          });
          await _channel?.invokeMethod(
              'load', _sourceParams(keepPosition: false));
        }
      }
    } catch (_) {
    } finally {
      _isReloadingLiveUrl = false;
    }
  }

  /// [minutes] is a duration, `null`/`0` for off, or `-1` for "end of video".
  ///
  /// "End of video" needs no timer — it is a flag that stops autoplay from
  /// advancing when the current video finishes (see [_handlePlaybackEnded]).
  void _setSleepTimer(int? minutes) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    setState(() => _sleepTimerMinutes = minutes);
    if (minutes == null || minutes == 0 || minutes == -1) return;

    _sleepTimer = Timer(Duration(minutes: minutes), () {
      if (!mounted) return;
      if (_playIntent) _togglePlay();
      if (!mounted) return;
      setState(() => _sleepTimerMinutes = null);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(S.of(context).sleepTimerEnded),
          duration: Duration(seconds: 2),
        ));
    });
  }

  Map<String, Object?> _sourceParams({
    bool keepPosition = false,
    int? startPositionMs,
  }) {
    final subtitle = _selectedSubtitle;
    return {
      'sourceType': _sourceTypeName(_config.sourceType),
      'sourceKey': _sourceKey,
      'videoUrl': _config.videoUrl,
      'audioUrl': _config.audioUrl,
      'manifestUrl': _config.manifestUrl,
      'isLive': _config.isLive,
      'startPositionMs': startPositionMs ?? _positionMs,
      'playWhenReady': true,
      'fitMode': _fitMode,
      'title': widget.watchInfo.title,
      'keepPosition': keepPosition,
      'selectedSubtitleUrl': null,
      'selectedSubtitleLanguage': subtitle?.languageCode,
    };
  }

  String get _sourceKey {
    return [
      widget.videoId,
      _sourceTypeName(_config.sourceType),
      _config.videoUrl ?? '',
      _config.audioUrl ?? '',
      _config.manifestUrl ?? '',
    ].join('|');
  }

  NewPipeSubtitle? get _selectedSubtitle {
    final code = _currentSubtitle;
    if (code == null) return null;
    return (widget.watchInfo.subtitles ?? [])
        .where((subtitle) => subtitle.languageCode == code)
        .firstOrNull;
  }

  String _sourceTypeName(MediaSourceType sourceType) {
    switch (sourceType) {
      case MediaSourceType.dash:
        return 'dash';
      case MediaSourceType.hls:
        return 'hls';
      case MediaSourceType.merging:
        return 'merging';
      case MediaSourceType.progressive:
        return 'progressive';
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('com.fazilvk.fluxtube/newpipe_exoplayer_$id');
    ExoPlayerNotificationBridge.instance.attach(_channel!);
    _channel!.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onState':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          if (!mounted) return;
          final wasPlaying = _isPlaying;
          final wasBuffering = _isBuffering;
          final oldDuration = _durationMs;
          final oldCaption = _currentCaptionText;
          final hadError = _errorMessage != null;
          if (!_isScrubbing) {
            _positionMs = (args['positionMs'] as num? ?? _positionMs).toInt();
          }
          _durationMs = (args['durationMs'] as num? ?? _durationMs).toInt();
          _isPlaying = args['isPlaying'] as bool? ?? _isPlaying;
          final oldIntent = _playIntent;
          _playIntent = args['playWhenReady'] as bool? ?? _isPlaying;
          _isBuffering = args['isBuffering'] as bool? ?? false;
          _currentCaptionText = _captionForPosition(_positionMs);
          _errorMessage = null;
          final stateChanged = wasPlaying != _isPlaying ||
              oldIntent != _playIntent ||
              wasBuffering != _isBuffering ||
              oldDuration != _durationMs;
          // While controls are hidden a plain position tick changes nothing
          // on screen, so skip rebuilding the whole player stack for it.
          if (_showControls ||
              stateChanged ||
              hadError ||
              oldCaption != _currentCaptionText) {
            setState(() {});
          }
          if (_isPlaying && !_isScrubbing) _maybeSkipSponsorSegment();
          if (_volumeBoost && !_volumeBoostApplied && _isPlaying) {
            unawaited(_applyVolumeBoost());
          }
          _globalPlayer.updateNativeExoPlayerState(
            playing: _isPlaying,
            buffering: _isBuffering,
            position: Duration(milliseconds: _positionMs),
            duration: Duration(milliseconds: _durationMs),
          );
          // The media session extrapolates position from speed on its own;
          // only real state changes need an immediate push.
          if (stateChanged) {
            unawaited(_syncNotificationState(force: true));
            if (!widget.isFullscreen) {
              unawaited(_pipService.setVideoPlaying(_isPlaying));
            }
          }
          if (!_isPlaying) {
            _hideTimer?.cancel();
            if (wasPlaying && !_config.isLive && _durationMs > 1000) {
              final nearEnd = (_positionMs + 1500) >= _durationMs;
              if (nearEnd) {
                _handlePlaybackEnded();
              }
            }
          } else if (!wasPlaying && _showControls) {
            _startHideTimer();
          }
          break;
        case 'onError':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          if (mounted) {
            final isPlaylistStuck = args['isPlaylistStuck'] as bool? ?? false;
            setState(() {
              _errorMessage = args['message'] as String? ?? 'Playback failed';
              _isBuffering = false;
            });
            if (isPlaylistStuck && _config.isLive) {
              _handleLiveUrlExpired();
            }
          }
          break;
        case 'onLiveUrlExpired':
          if (mounted && _config.isLive) {
            _handleLiveUrlExpired();
          }
          break;
      }
    });
    if (_speed != 1.0) {
      unawaited(_channel!.invokeMethod('setSpeed', {'speed': _speed}));
    }
    unawaited(_channel!.invokeMethod('setLooping', {'looping': _isLooping}));
    unawaited(
        _channel!.invokeMethod('setSkipSilence', {'enabled': _skipSilence}));
    _registerNativeSession();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePipSourceRect());
    unawaited(_initNotification());
  }

  void _startHistoryTimer() {
    _historyTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _saveHistoryPosition();
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (!_isPlaying || !_showControls) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  Future<void> _togglePlay() async {
    final channel = _channel;
    if (channel == null) return;
    final nextPlaying = !_playIntent;
    setState(() {
      _playIntent = nextPlaying;
      _isPlaying = nextPlaying;
    });
    _globalPlayer.updateNativeExoPlayerState(
      playing: nextPlaying,
      buffering: _isBuffering,
      position: Duration(milliseconds: _positionMs),
      duration: Duration(milliseconds: _durationMs),
    );
    unawaited(_pipService.setVideoPlaying(nextPlaying));
    unawaited(_syncNotificationState(force: true));
    if (nextPlaying) {
      await channel.invokeMethod('play');
    } else {
      await channel.invokeMethod('pause');
    }
    _startHideTimer();
  }

  void _maybeSkipSponsorSegment() {
    if (_config.isLive || widget.sponsorSegments.isEmpty) return;
    final positionSec = _positionMs / 1000;
    for (final segment in widget.sponsorSegments) {
      // Re-arm a segment once playback is back before it, so seeking
      // backwards past a sponsor skips it again like the web extension does.
      if (positionSec < segment.startTime - 1) {
        _skippedSegments.remove(segment.uuid);
        continue;
      }
      if (!segment.containsPosition(positionSec) ||
          _skippedSegments.contains(segment.uuid) ||
          segment.endTime - positionSec < 0.5) {
        continue;
      }
      _skippedSegments.add(segment.uuid);
      unawaited(_seekTo((segment.endTime * 1000).round()));
      HapticFeedback.lightImpact();
      _sponsorChipTimer?.cancel();
      setState(() => _lastSkippedSegment = segment);
      _sponsorChipTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _lastSkippedSegment = null);
      });
      return;
    }
  }

  bool get _isLooping => _loopVideoId == widget.videoId;

  Future<void> _setLooping(bool looping) async {
    _loopVideoId = looping ? widget.videoId : null;
    await _channel?.invokeMethod('setLooping', {'looping': looping});
  }

  Future<void> _setSkipSilence(bool enabled) async {
    _skipSilence = enabled;
    await _channel?.invokeMethod('setSkipSilence', {'enabled': enabled});
  }

  Future<void> _setVolumeBoost(bool enabled) async {
    _volumeBoost = enabled;
    _volumeBoostApplied = false;
    await _applyVolumeBoost();
  }

  Future<void> _applyVolumeBoost() async {
    final applied = await _channel?.invokeMethod<bool>('setVolumeBoost', {
      'gainMb': _volumeBoost ? _volumeBoostGainMb : 0,
    });
    _volumeBoostApplied = applied ?? false;
  }

  void _onHoldSpeedStart() {
    if (_config.isLive || !_isPlaying || _isHoldSpeeding) return;
    HapticFeedback.selectionClick();
    setState(() => _isHoldSpeeding = true);
    unawaited(_channel?.invokeMethod('setSpeed', {'speed': 2.0}));
  }

  void _onHoldSpeedEnd() {
    if (!_isHoldSpeeding) return;
    setState(() => _isHoldSpeeding = false);
    unawaited(_channel?.invokeMethod('setSpeed', {'speed': _speed}));
  }

  Widget _buildHoldSpeedPill() {
    return Positioned(
      top: 14,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('2x',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(CupertinoIcons.forward_fill,
                      color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _undoSponsorSkip() {
    final segment = _lastSkippedSegment;
    if (segment == null) return;
    _sponsorChipTimer?.cancel();
    setState(() => _lastSkippedSegment = null);
    unawaited(_seekTo((segment.startTime * 1000).round()));
  }

  Widget _buildSponsorSkipChip(SponsorSegment segment) {
    return Positioned(
      right: 12,
      bottom: _showControls ? 96 : 16,
      child: Material(
        color: Colors.black.withValues(alpha: 0.78),
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _undoSponsorSkip,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: sponsorCategoryColor(segment.category),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Skipped ${segment.categoryDisplayName}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
                const Text(
                  'UNDO',
                  style: TextStyle(
                      color: Color(0xFF00E3FD),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _seekTo(int positionMs) async {
    if (_config.isLive) return;
    final bounded = positionMs.clamp(0, _durationMs);
    setState(() => _positionMs = bounded);
    await _channel?.invokeMethod('seekTo', {'positionMs': bounded});
    unawaited(_syncNotificationState(force: true));
  }

  /// Real YouTube chapter metadata (`StreamInfo.getStreamSegments()`, via
  /// the native `chapters` field) when the video actually has any — this is
  /// the reliable source. The regex-over-description heuristic is a
  /// fallback only, since it requires an exact, strict format (>=3 entries,
  /// starts at 0:00, strictly increasing) that many real chapter lists
  /// (bulleted, bracketed, not starting at 0:00, etc.) don't satisfy even
  /// when the video genuinely has chapters.
  List<VideoChapter> _resolveChapters() {
    final native = widget.watchInfo.chapters;
    if (native != null && native.isNotEmpty) {
      final parsed = native
          .where((c) =>
              c.title != null &&
              c.title!.isNotEmpty &&
              c.startTimeSeconds != null)
          .map((c) => VideoChapter(
                startSeconds: c.startTimeSeconds!,
                title: c.title!,
              ))
          .toList();
      if (parsed.isNotEmpty) return parsed;
    }
    return VideoChapter.parseFromDescription(
      widget.watchInfo.description,
      durationSeconds: widget.watchInfo.duration,
    );
  }

  Future<void> _skipBy(int seconds) async {
    _flashSkip(seconds);
    await _seekTo(_positionMs + seconds * 1000);
  }

  /// Brief "+10s"/"-10s" flash so a double-tap skip is actually visible
  /// instead of a silent instant jump. Restarts on every skip rather than
  /// stacking, matching how a rapid string of skip taps should read as one
  /// continuously-updating indicator, not overlapping flashes.
  void _flashSkip(int seconds) {
    _skipFlashTimer?.cancel();
    HapticFeedback.selectionClick();
    final previous = _skipFlashSeconds;
    final accumulate = previous != null && previous.sign == seconds.sign;
    setState(
        () => _skipFlashSeconds = accumulate ? previous + seconds : seconds);
    _skipFlashTimer = Timer(const Duration(milliseconds: 750), () {
      if (mounted) setState(() => _skipFlashSeconds = null);
    });
  }

  Future<void> _changeQuality(String quality) async {
    final channel = _channel;
    if (channel == null) return;
    setState(() {
      _isBuffering = true;
      _currentQuality = quality;
      _config = _resolveConfig(quality);
    });
    _globalPlayer.updateNativeExoPlayerSelections(quality: quality);
    await channel.invokeMethod('load', _sourceParams(keepPosition: true));
  }

  Future<void> _changeAudioTrack(String trackId) async {
    final channel = _channel;
    if (channel == null) return;
    final quality =
        _currentQuality == 'Auto' ? _initialQuality() : _currentQuality;
    setState(() {
      _isBuffering = true;
      _currentAudioTrackId = trackId;
      _currentQuality = quality;
      _config = _resolveConfig(quality);
    });
    _globalPlayer.updateNativeExoPlayerSelections(
      quality: quality,
      audioTrackId: trackId,
    );
    await channel.invokeMethod('load', _sourceParams(keepPosition: true));
  }

  Future<void> _changeSubtitle(String? languageCode) async {
    setState(() {
      _currentSubtitle = languageCode;
      _currentCaptionText = null;
      _captionCues = [];
    });
    _globalPlayer.setNativeSubtitleCode(languageCode);
    if (languageCode != null) {
      await _loadSubtitle(languageCode);
    }
  }

  Future<void> _loadSubtitle(String? languageCode) async {
    final subtitle = (widget.watchInfo.subtitles ?? [])
        .where((subtitle) => subtitle.languageCode == languageCode)
        .firstOrNull;
    final url = subtitle?.url;
    if (url == null || url.isEmpty) return;

    try {
      final request = await HttpClient().getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader,
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0 Mobile Safari/537.36');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final cues = _parseCaptionCues(body);
      if (!mounted || _currentSubtitle != languageCode) return;
      setState(() {
        _captionCues = cues;
        _currentCaptionText = _captionForPosition(_positionMs);
      });
    } catch (error) {
      debugPrint('[NewPipeExoPlayer] Failed to load subtitle: $error');
    }
  }

  Future<void> _changeSpeed(double speed) async {
    setState(() => _speed = speed);
    _globalPlayer.updateNativeExoPlayerSelections(speed: speed);
    await _channel?.invokeMethod('setSpeed', {'speed': speed});
    unawaited(_syncNotificationState(force: true));
  }

  Future<void> _initNotification() async {
    final handler = await ensureAudioServiceInitialized();
    if (handler == null || !mounted) return;

    handler.configureExternalControls(
      play: () async {
        if (!mounted) return;
        setState(() => _isPlaying = _playIntent = true);
        unawaited(_syncNotificationState(force: true));
      },
      pause: () async {
        if (!mounted) return;
        setState(() => _isPlaying = _playIntent = false);
        unawaited(_syncNotificationState(force: true));
      },
      stop: () async {
        if (!mounted) return;
        final watchBloc = BlocProvider.of<WatchBloc>(context);
        setState(() => _isPlaying = false);
        await ExoPlayerNotificationBridge.instance.stop();
        _globalPlayer.clearNativeExoPlayerSession();
        await _globalPlayer.pipService.setVideoPlaying(false);
        await _globalPlayer.clearMediaNotification();
        watchBloc.add(WatchEvent.togglePip(value: false));
      },
      seek: (position) async {
        if (!mounted) return;
        setState(() => _positionMs = position.inMilliseconds);
        unawaited(_syncNotificationState(force: true));
      },
    );

    await handler.setExternalMediaItem(
      id: widget.videoId,
      title: widget.watchInfo.title ?? 'Video',
      artist: widget.watchInfo.uploaderName ?? 'Unknown',
      artUri: widget.watchInfo.thumbnailUrl,
      duration: widget.watchInfo.duration != null
          ? Duration(seconds: widget.watchInfo.duration!)
          : (_durationMs > 0 ? Duration(milliseconds: _durationMs) : null),
    );
    _notificationReady = true;
    await _syncNotificationState(force: true);
  }

  Future<void> _syncNotificationState({bool force = false}) async {
    if (!_notificationReady) return;
    final now = DateTime.now();
    if (!force &&
        now.difference(_lastNotificationStateUpdate) <
            const Duration(seconds: 1)) {
      return;
    }
    _lastNotificationStateUpdate = now;

    final handler = await ensureAudioServiceInitialized();
    await handler?.updateExternalPlaybackState(
      playing: _isPlaying,
      position: Duration(milliseconds: _positionMs),
      duration: Duration(milliseconds: _durationMs),
      buffering: _isBuffering,
      speed: _speed,
    );
  }

  void _openSettings({SettingsPage initialPage = SettingsPage.main}) {
    setState(() => _showControls = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        minWidth: MediaQuery.sizeOf(context).width,
        maxWidth: MediaQuery.sizeOf(context).width,
      ),
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        widthFactor: 1,
        child: PlayerSettingsSheet(
          currentSpeed: _speed,
          speeds: _speeds,
          onSpeedChanged: _changeSpeed,
          currentQuality: _currentQuality,
          qualities: _qualityOptions,
          onQualityChanged: _changeQuality,
          subtitles: widget.watchInfo.subtitles ?? [],
          currentSubtitle: _currentSubtitle,
          onSubtitleChanged: _changeSubtitle,
          isLive: _config.isLive,
          initialPage: initialPage,
          audioTracks: _audioTracks,
          currentAudioTrackId: _currentAudioTrackId,
          onAudioTrackChanged: _changeAudioTrack,
          currentFitMode: _fitMode,
          onFitModeChanged: _changeFitMode,
          sleepTimerMinutes: _sleepTimerMinutes,
          onSleepTimerChanged: _setSleepTimer,
          isLooping: _isLooping,
          onLoopingChanged: _setLooping,
          isSkipSilence: _skipSilence,
          onSkipSilenceChanged: _setSkipSilence,
          isVolumeBoost: _volumeBoost,
          onVolumeBoostChanged: _setVolumeBoost,
        ),
      ),
    );
  }

  Future<void> _changeFitMode(String fitMode) async {
    setState(() => _fitMode = fitMode);
    _globalPlayer.updateNativeExoPlayerSelections(fitMode: fitMode);
    await _channel?.invokeMethod('setResizeMode', {
      'fitMode': fitMode,
    });
  }

  Future<void> _cycleFitMode() async {
    final nextMode = switch (_fitMode) {
      'contain' => 'cover',
      'cover' => 'fill',
      _ => 'contain',
    };
    await _changeFitMode(nextMode);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Resize: ${_fitModeLabel(nextMode)}'),
          duration: const Duration(milliseconds: 850),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _fitModeLabel(String mode) {
    return switch (mode) {
      'cover' => 'Zoom',
      'fill' => 'Fill',
      _ => 'Fit',
    };
  }

  List<StreamQualityInfo> get _qualityOptions {
    return [
      const StreamQualityInfo(
        label: 'Auto',
        resolution: 0,
        requiresMerging: false,
        isVideoOnly: false,
      ),
      ..._qualities,
    ];
  }

  Future<void> _enterFullscreen() async {
    if (widget.isFullscreen) {
      await _exitFullscreen();
      return;
    }

    final position =
        await _channel?.invokeMethod<int>('getPosition') ?? _positionMs;
    if (!mounted) return;
    final fullscreenKey = GlobalKey<_NewPipeExoPlayerState>();
    final returnedState =
        await Navigator.of(context).push<_FullscreenPlaybackState>(
      MaterialPageRoute(
        builder: (_) => _NewPipeExoFullscreenRoute(
          playerKey: fullscreenKey,
          player: NewPipeExoPlayer(
            key: fullscreenKey,
            watchInfo: widget.watchInfo,
            videoId: widget.videoId,
            playbackPosition: position ~/ 1000,
            defaultQuality: _currentQuality == 'Auto'
                ? widget.defaultQuality
                : _currentQuality,
            videoFitMode: _fitMode,
            skipInterval: widget.skipInterval,
            preferAdaptivePlayback: _currentQuality == 'Auto',
            sponsorSegments: widget.sponsorSegments,
            isFullscreen: true,
            isAutoPipEnabled: widget.isAutoPipEnabled,
            initialQuality: _currentQuality,
            initialAudioTrackId: _currentAudioTrackId,
            initialSubtitleCode: _currentSubtitle,
            initialSpeed: _speed,
          ),
        ),
      ),
    );
    if (returnedState != null) {
      setState(() {
        _isBuffering = false;
        _currentQuality = returnedState.quality;
        _currentAudioTrackId = returnedState.audioTrackId;
        _currentSubtitle = returnedState.subtitleCode;
        _speed = returnedState.speed;
        _fitMode = returnedState.fitMode;
      });
      await _channel?.invokeMethod('reattach');
      await _changeFitMode(returnedState.fitMode);
      await _seekTo(returnedState.positionSeconds * 1000);
      await _changeSpeed(returnedState.speed);
      if (returnedState.subtitleCode != null) {
        await _loadSubtitle(returnedState.subtitleCode);
      }
    }
  }

  Future<void> _exitFullscreen() async {
    final position =
        await _channel?.invokeMethod<int>('getPosition') ?? _positionMs;
    if (!mounted) return;
    Navigator.of(context).pop(_FullscreenPlaybackState(
      positionSeconds: position ~/ 1000,
      quality: _currentQuality,
      audioTrackId: _currentAudioTrackId,
      subtitleCode: _currentSubtitle,
      speed: _speed,
      fitMode: _fitMode,
    ));
  }

  void _showQueueSheet() {
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const QueueSheet(),
    ).then((_) => _startHideTimer());
  }

  void _handlePlaybackEnded() {
    if (!mounted || _autoAdvanced) return;
    // "End of video" sleep timer: stop here instead of advancing.
    if (_sleepTimerMinutes == -1) {
      setState(() => _sleepTimerMinutes = null);
      return;
    }
    final currentId = widget.watchInfo.id;
    final next = PlaybackQueue().nextAfter(currentId);
    if (next == null || next.id.isEmpty || next.id == currentId) return;

    _autoAdvanced = true;
    PlaybackQueue().syncCurrent(next.id);
    BlocProvider.of<WatchBloc>(context)
        .add(WatchEvent.setSelectedVideoBasicDetails(details: next));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // goNamed, not pushNamed: autoplay replaces the current watch screen so a
      // long autoplay chain does not pile up back-stack entries.
      context.goNamed('watch', pathParameters: {
        'videoId': next.id,
        'channelId': next.channelId ?? '',
      });
    });
  }

  Future<void> _saveHistoryPosition() async {
    final channel = _channel;
    if (channel == null) return;

    try {
      final positionMs =
          await channel.invokeMethod<int>('getPosition') ?? _positionMs;
      final positionSeconds = positionMs ~/ 1000;
      if (positionSeconds <= 0 ||
          positionSeconds - _lastSavedPositionSeconds < 15) {
        return;
      }
      _lastSavedPositionSeconds = positionSeconds;

      if (!mounted) return;
      final savedBloc = BlocProvider.of<SavedBloc>(context);
      final settingsBloc = BlocProvider.of<SettingsBloc>(context);
      final watchBloc = BlocProvider.of<WatchBloc>(context);
      final profileName = settingsBloc.state.currentProfile;
      final info = widget.watchInfo;

      watchBloc.add(WatchEvent.updatePlayBack(playBack: positionSeconds));
      savedBloc.add(SavedEvent.updatePlaybackPosition(
        profileName: profileName,
        videoInfo: LocalStoreVideoInfo(
          id: widget.videoId,
          title: info.title,
          views: info.viewCount,
          thumbnail: info.thumbnailUrl,
          uploadedDate: info.textualUploadDate,
          uploaderName: info.uploaderName,
          uploaderId: _extractChannelId(info.uploaderUrl),
          uploaderAvatar: info.uploaderAvatarUrl,
          uploaderVerified: info.uploaderVerified,
          duration: info.duration ?? (_durationMs ~/ 1000),
          isHistory: true,
          isLive: info.isLive,
          playbackPosition: positionSeconds,
          time: DateTime.now(),
          profileName: profileName,
        ),
      ));
    } catch (error) {
      debugPrint('[NewPipeExoPlayer] Failed to save history: $error');
    }
  }

  String? _extractChannelId(String? uploaderUrl) {
    if (uploaderUrl == null || uploaderUrl.isEmpty) return null;
    final channelMatch = RegExp(r'/channel/([^/?]+)').firstMatch(uploaderUrl);
    if (channelMatch != null) return channelMatch.group(1);
    final atHandleMatch = RegExp(r'/@([^/?]+)').firstMatch(uploaderUrl);
    if (atHandleMatch != null) return '@${atHandleMatch.group(1)}';
    final parts = uploaderUrl.split('/').where((part) => part.isNotEmpty);
    return parts.isEmpty ? null : parts.last;
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    if (!_config.isValid) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: _errorBox('No playable stream was found'),
      );
    }

    final player = Stack(
      fit: StackFit.expand,
      children: [
        // All touch handling is in Flutter; keep the native view out of the
        // gesture arena so it can never claim a tap meant for the controls.
        IgnorePointer(
          child: AndroidView(
            viewType: 'fluxtube/newpipe_exoplayer',
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParams: _sourceParams(startPositionMs: _positionMs),
            creationParamsCodec: const StandardMessageCodec(),
          ),
        ),
        // Only mounted while controls are hidden — _buildControls() below
        // already renders its own identical tap/double-tap/drag zones via
        // _buildTapZones() when controls are shown. Having *both* active
        // at once (as it briefly was) meant a single tap on the center
        // zone fired `_toggleControls()` from each translucent layer in
        // the same gesture arena — toggling it off then immediately back
        // on, so nothing visibly happened. Kept mounted through an active
        // brightness/volume drag even after that drag's onVerticalDragStart
        // flips _showControls to true — removing this widget mid-gesture
        // would tear down the very GestureDetector tracking that drag.
        if (!_showControls || _draggingBrightness || _draggingVolume)
          _buildGestureLayer(),
        if (_currentCaptionText != null && _currentCaptionText!.isNotEmpty)
          _buildCaption(_currentCaptionText!),
        // A stable key per branch means AnimatedSwitcher only actually
        // crossfades when _showControls itself flips, not on every rebuild
        // (e.g. every position tick while controls stay visible) — and it
        // replaces what used to be an instant show/hide snap with a 200ms
        // fade, matching the media_kit player's already-smoother feel.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          // AnimatedSwitcher's default layoutBuilder centers children in a
          // loosely-constrained Stack, not one with StackFit.expand — so
          // without this override, _buildControls()'s own
          // Stack(fit: StackFit.expand) no longer actually fills the
          // player, throwing off every button's real position (the
          // concrete cause of the play/pause button seeming unresponsive).
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          child: _showControls
              ? KeyedSubtree(
                  key: const ValueKey('controls-shown'),
                  child: _buildControls(),
                )
              : const SizedBox.shrink(key: ValueKey('controls-hidden')),
        ),
        // Purely visual layers stacked above the controls must never take
        // part in hit-testing: an opacity-0 DecoratedBox still hits on its
        // whole rect, and these are centered right over the play button.
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _draggingBrightness ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: _buildVerticalIndicator(CupertinoIcons.sun_max, _brightness),
          ),
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _draggingVolume ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: _buildVerticalIndicator(CupertinoIcons.volume_up, _volume),
          ),
        ),
        if (_skipFlashSeconds != null)
          IgnorePointer(child: _buildSkipFlash(_skipFlashSeconds!)),
        // A pause while rebuffering must read as paused, and with controls up
        // the transport button already shows the state.
        if (_isBuffering && _playIntent && !_showControls)
          const IgnorePointer(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        if (_lastSkippedSegment != null)
          _buildSponsorSkipChip(_lastSkippedSegment!),
        if (_isHoldSpeeding) _buildHoldSpeedPill(),
        if (_errorMessage != null) _errorBox(_errorMessage!),
      ],
    );

    if (widget.isFullscreen) {
      return ColoredBox(color: Colors.black, child: Center(child: player));
    }

    return AspectRatio(aspectRatio: 16 / 9, child: player);
  }

  /// The tap/double-tap/vertical-drag zones — shared by the bare video
  /// surface (via [_buildGestureLayer]) and by the controls overlay's own
  /// backdrop (via [_buildControls]). These used to be two separate
  /// implementations: the gesture layer had full tap/double-tap/drag
  /// support, but the controls backdrop was a single full-screen
  /// `GestureDetector` with only `onTap`. Since that backdrop sits *on top*
  /// of the gesture layer whenever controls are visible, it swallowed every
  /// tap — the first tap of an attempted double-tap-to-skip hid the
  /// controls instead of composing into a skip, because a plain `onTap`
  /// (no competing `onDoubleTap` on the same detector) resolves instantly
  /// rather than waiting to see if a second tap follows. Using the exact
  /// same zones in both places means double-tap-to-skip (and the
  /// brightness/volume drag) work identically whether controls are shown
  /// or hidden.
  Widget _buildTapZones({Widget? background}) {
    // Brightness/volume swipe is fullscreen-only (matching the media_kit
    // player's overlay) — inline, the whole gesture layer is only ~45% of
    // screen height at most, so without this gate a tiny, ordinary vertical
    // finger movement swings brightness/volume across nearly its full
    // range, which is the concrete "too sensitive" feeling.
    final enableVerticalGestures = widget.isFullscreen;

    return LayoutBuilder(
      builder: (context, constraints) {
        _gestureLayerHeight = constraints.maxHeight;
        final zones = Row(
          children: [
            // Left third: double-tap to skip back. A dedicated dead zone
            // (the center third below) means an off-center tap meant as a
            // plain controls toggle no longer gets mistaken for a skip.
            Expanded(
              flex: 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleControls,
                onDoubleTap: () => _skipBy(-widget.skipInterval),
                onLongPressStart: (_) => _onHoldSpeedStart(),
                onLongPressEnd: (_) => _onHoldSpeedEnd(),
                onLongPressCancel: _onHoldSpeedEnd,
                onVerticalDragStart: !enableVerticalGestures
                    ? null
                    : (details) {
                        _verticalDragStartY = details.localPosition.dy;
                        _verticalDragStartValue = _brightness;
                        setState(() {
                          _draggingBrightness = true;
                          _showControls = true;
                        });
                      },
                onVerticalDragUpdate:
                    !enableVerticalGestures ? null : _updateBrightness,
                onVerticalDragEnd: !enableVerticalGestures
                    ? null
                    : (_) {
                        setState(() => _draggingBrightness = false);
                        _startHideTimer();
                      },
              ),
            ),
            // Center third: toggle controls only — no double-tap recognizer
            // registered here at all, so a single tap in this zone responds
            // immediately instead of waiting out the double-tap timeout.
            Expanded(
              flex: 1,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleControls,
                onLongPressStart: (_) => _onHoldSpeedStart(),
                onLongPressEnd: (_) => _onHoldSpeedEnd(),
                onLongPressCancel: _onHoldSpeedEnd,
              ),
            ),
            // Right third: double-tap to skip forward.
            Expanded(
              flex: 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleControls,
                onDoubleTap: () => _skipBy(widget.skipInterval),
                onLongPressStart: (_) => _onHoldSpeedStart(),
                onLongPressEnd: (_) => _onHoldSpeedEnd(),
                onLongPressCancel: _onHoldSpeedEnd,
                onVerticalDragStart: !enableVerticalGestures
                    ? null
                    : (details) {
                        _verticalDragStartY = details.localPosition.dy;
                        _verticalDragStartValue = _volume;
                        setState(() {
                          _draggingVolume = true;
                          _showControls = true;
                        });
                      },
                onVerticalDragUpdate:
                    !enableVerticalGestures ? null : _updateVolume,
                onVerticalDragEnd: !enableVerticalGestures
                    ? null
                    : (_) {
                        setState(() => _draggingVolume = false);
                        _startHideTimer();
                      },
              ),
            ),
          ],
        );
        if (background == null) return zones;
        return Stack(fit: StackFit.expand, children: [background, zones]);
      },
    );
  }

  /// The invisible tap/double-tap/drag zones over the bare video surface
  /// (no controls visible).
  Widget _buildGestureLayer() => _buildTapZones();

  Future<void> _updateBrightness(DragUpdateDetails details) async {
    final value =
        (_verticalDragStartValue + _dragDelta(details)).clamp(0.0, 1.0);
    setState(() => _brightness = value);
    try {
      await ScreenBrightness().setApplicationScreenBrightness(value);
    } catch (_) {}
  }

  Future<void> _updateVolume(DragUpdateDetails details) async {
    final value =
        (_verticalDragStartValue + _dragDelta(details)).clamp(0.0, 1.0);
    setState(() => _volume = value);
    try {
      await VolumeController.instance.setVolume(value);
    } catch (_) {}
  }

  /// Fraction of a full 0.0-1.0 swing this drag represents, scaled to the
  /// gesture layer's actual on-screen height rather than a flat pixel
  /// count — a fixed divisor (previously 300px, measured in *global*
  /// coordinates no less) meant a drag spanning the whole small inline
  /// player already swung brightness/volume across nearly its full range.
  /// A full-height drag now takes ~70% of the layer's height, matching the
  /// already-reasonable feel of the media_kit player's equivalent gesture.
  double _dragDelta(DragUpdateDetails details) {
    final travel = _gestureLayerHeight * 0.7;
    if (travel <= 0) return 0;
    return (_verticalDragStartY - details.localPosition.dy) / travel;
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  static const _accent = Color(0xFFFF525E);

  Widget _buildControls() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildTapZones(
          background: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.3, 0.6, 1],
                colors: [
                  Color(0x99000000),
                  Color(0x40000000),
                  Color(0x40000000),
                  Color(0xB3000000),
                ],
              ),
            ),
          ),
        ),
        // Regions are pinned independently so the bottom cluster can grow
        // (chapters) without competing with the top bar for height.
        Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
        Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomCluster()),
        // Last child so it wins hit-testing over the slider's touch box.
        Center(child: _buildTransportControls()),
      ],
    );
  }

  Widget _buildTransportControls() {
    final big = widget.isFullscreen ? 72.0 : 60.0;
    final small = widget.isFullscreen ? 52.0 : 44.0;
    final gap = widget.isFullscreen ? 56.0 : 32.0;
    final canSeek = !_config.isLive;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canSeek)
          _CircleControl(
            size: small,
            tooltip: 'Rewind',
            onTap: () => _skipBy(-widget.skipInterval),
            child: Icon(CupertinoIcons.gobackward,
                color: Colors.white, size: small * 0.5),
          ),
        if (canSeek) SizedBox(width: gap),
        _CircleControl(
          size: big,
          tooltip: _playIntent ? 'Pause' : 'Play',
          onTap: _togglePlay,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              _playIntent
                  ? CupertinoIcons.pause_fill
                  : CupertinoIcons.play_fill,
              key: ValueKey(_playIntent),
              color: Colors.white,
              size: big * 0.46,
            ),
          ),
        ),
        if (canSeek) SizedBox(width: gap),
        if (canSeek)
          _CircleControl(
            size: small,
            tooltip: 'Forward',
            onTap: () => _skipBy(widget.skipInterval),
            child: Icon(CupertinoIcons.goforward,
                color: Colors.white, size: small * 0.5),
          ),
      ],
    );
  }

  Widget _buildBottomCluster() {
    final position = Duration(milliseconds: (_scrubMs ?? _positionMs).round());
    final duration = Duration(milliseconds: _durationMs);
    final horizontal = widget.isFullscreen ? 20.0 : 4.0;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            horizontal, 0, horizontal, widget.isFullscreen ? 12 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                if (_config.isLive)
                  _buildLiveBadge()
                else
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: _formatDuration(position)),
                      TextSpan(
                        text: ' / ${_formatDuration(duration)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ]),
                    style: _timeStyle,
                  ),
                const SizedBox(width: 10),
                _PillButton(
                  // "720p60 60fps" → "720p60"; the full label is in the sheet.
                  label: _currentQuality.split(' ').first,
                  onTap: () => _openSettings(initialPage: SettingsPage.quality),
                ),
                const Spacer(),
                _BarIcon(
                  tooltip: 'Resize',
                  onTap: _cycleFitMode,
                  icon: switch (_fitMode) {
                    'cover' => CupertinoIcons.rectangle_expand_vertical,
                    'fill' => CupertinoIcons.rectangle_fill,
                    _ => CupertinoIcons.rectangle,
                  },
                ),
                _BarIcon(
                  tooltip:
                      widget.isFullscreen ? 'Exit fullscreen' : 'Fullscreen',
                  onTap: _enterFullscreen,
                  icon: widget.isFullscreen
                      ? CupertinoIcons.fullscreen_exit
                      : CupertinoIcons.fullscreen,
                ),
              ],
            ),
            SizedBox(height: 28, child: _buildSeekBar()),
            if (_chapters.isNotEmpty && widget.isFullscreen)
              ChapterBar(
                chapters: _chapters,
                positionSeconds: (_scrubMs ?? _positionMs) ~/ 1000,
                durationSeconds: _durationMs ~/ 1000,
                onChapterTap: (seconds) => _seekTo(seconds * 1000),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeekBar() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: _isScrubbing ? 5 : 3,
        thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: _isScrubbing ? 8 : 6, elevation: 0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        activeTrackColor: _accent,
        inactiveTrackColor: Colors.white24,
        thumbColor: _accent,
        overlayColor: _accent.withValues(alpha: 0.2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Slider(
            min: 0,
            max: _durationMs <= 0 ? 1 : _durationMs.toDouble(),
            // Until the duration is known the max is a placeholder 1, so any
            // position would read as full.
            value: _durationMs <= 0
                ? 0
                : (_scrubMs ?? _positionMs).clamp(0, _durationMs).toDouble(),
            onChangeStart: (_) {
              setState(() => _isScrubbing = true);
              _hideTimer?.cancel();
            },
            onChanged: _config.isLive
                ? null
                : (value) => setState(() => _scrubMs = value),
            onChangeEnd: _config.isLive
                ? null
                : (value) async {
                    setState(() {
                      _isScrubbing = false;
                      _scrubMs = null;
                    });
                    await _seekTo(value.round());
                    _startHideTimer();
                  },
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: SponsorSegmentMarkers(
                segments: widget.sponsorSegments,
                durationMs: _durationMs,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildCaption(String text) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: _showControls ? 92 : 28,
      child: IgnorePointer(
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalIndicator(IconData icon, double value) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 10),
              SizedBox(
                width: 110,
                child: LinearProgressIndicator(
                  value: value,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Brief "+10s"/"-10s" flash on the tapped side, mirroring
  /// [_buildVerticalIndicator]'s look — visual confirmation for a
  /// double-tap skip, which previously had none at all on this player.
  Widget _buildSkipFlash(int seconds) {
    final isForward = seconds > 0;
    return Align(
      alignment: isForward ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 150),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isForward
                        ? CupertinoIcons.goforward
                        : CupertinoIcons.gobackward,
                    color: Colors.white,
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${isForward ? '+' : ''}$seconds s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTopBar() {
    final hasCaptions = (widget.watchInfo.subtitles ?? []).isNotEmpty;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: widget.isFullscreen ? 16 : 4, vertical: 4),
        child: Row(
          children: [
            if (widget.isFullscreen) ...[
              _BarIcon(
                tooltip: 'Exit fullscreen',
                onTap: _enterFullscreen,
                icon: CupertinoIcons.chevron_down,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.watchInfo.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ] else
              const Spacer(),
            if (hasCaptions)
              _BarIcon(
                tooltip: 'Captions',
                onTap: () => _openSettings(initialPage: SettingsPage.captions),
                icon: _currentSubtitle == null
                    ? CupertinoIcons.captions_bubble
                    : CupertinoIcons.captions_bubble_fill,
              ),
            _BarIcon(
              tooltip: S.of(context).queue,
              onTap: _showQueueSheet,
              icon: CupertinoIcons.list_bullet,
            ),
            _BarIcon(
              tooltip: S.of(context).settings,
              onTap: _openSettings,
              icon: CupertinoIcons.gear_alt,
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _timeStyle => const TextStyle(
        color: Colors.white,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '${duration.inMinutes}:$seconds';
  }

  String? _captionForPosition(int positionMs) {
    for (final cue in _captionCues) {
      if (positionMs >= cue.startMs && positionMs <= cue.endMs) {
        return cue.text;
      }
    }
    return null;
  }

  List<_CaptionCue> _parseCaptionCues(String body) {
    if (body.contains('-->')) {
      return _parseWebVtt(body);
    }
    final timedText = _parseTimedText(body);
    if (timedText.isNotEmpty) return timedText;
    return _parseTtml(body);
  }

  List<_CaptionCue> _parseWebVtt(String body) {
    final cues = <_CaptionCue>[];
    final blocks = body.replaceAll('\r\n', '\n').split('\n\n');
    for (final block in blocks) {
      final lines = block
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      final timeIndex = lines.indexWhere((line) => line.contains('-->'));
      if (timeIndex == -1 || timeIndex == lines.length - 1) continue;
      final parts = lines[timeIndex].split('-->');
      final start = _parseCueTime(parts.first.trim());
      final end = _parseCueTime(parts.last.split(' ').first.trim());
      final text = lines.skip(timeIndex + 1).join('\n');
      if (start != null && end != null && text.isNotEmpty) {
        cues.add(_CaptionCue(start, end, _cleanCaptionText(text)));
      }
    }
    return cues;
  }

  List<_CaptionCue> _parseTimedText(String body) {
    final cues = <_CaptionCue>[];
    final regex = RegExp(
      r'<text[^>]*start="([^"]+)"[^>]*(?:dur="([^"]+)")?[^>]*>(.*?)<\/text>',
      dotAll: true,
    );
    for (final match in regex.allMatches(body)) {
      final startSeconds = double.tryParse(match.group(1) ?? '');
      final durationSeconds = double.tryParse(match.group(2) ?? '4') ?? 4;
      final text = _cleanCaptionText(match.group(3) ?? '');
      if (startSeconds == null || text.isEmpty) continue;
      final startMs = (startSeconds * 1000).round();
      cues.add(_CaptionCue(
        startMs,
        startMs + (durationSeconds * 1000).round(),
        text,
      ));
    }
    return cues;
  }

  List<_CaptionCue> _parseTtml(String body) {
    final cues = <_CaptionCue>[];
    final regex = RegExp(
      r"""<p[^>]*begin=["']([^"']+)["'][^>]*end=["']([^"']+)["'][^>]*>(.*?)<\/p>""",
      dotAll: true,
    );
    for (final match in regex.allMatches(body)) {
      final start = _parseCueTime(match.group(1) ?? '');
      final end = _parseCueTime(match.group(2) ?? '');
      final text = _cleanCaptionText(match.group(3) ?? '');
      if (start != null && end != null && text.isNotEmpty) {
        cues.add(_CaptionCue(start, end, text));
      }
    }
    return cues;
  }

  int? _parseCueTime(String value) {
    final normalized = value.replaceAll(',', '.');
    final parts = normalized.split(':');
    if (parts.length < 2) return null;
    final seconds = double.tryParse(parts.last);
    final minutes = int.tryParse(parts[parts.length - 2]);
    final hours = parts.length > 2 ? int.tryParse(parts[parts.length - 3]) : 0;
    if (seconds == null || minutes == null || hours == null) return null;
    return (((hours * 3600) + (minutes * 60) + seconds) * 1000).round();
  }

  String _cleanCaptionText(String text) {
    final withoutTags = text
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('\n', ' ');

    return withoutTags.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final codePoint = int.tryParse(match.group(1) ?? '');
      return codePoint == null
          ? match.group(0)!
          : String.fromCharCode(codePoint);
    }).replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final codePoint = int.tryParse(match.group(1) ?? '', radix: 16);
      return codePoint == null
          ? match.group(0)!
          : String.fromCharCode(codePoint);
    }).trim();
  }

  Widget _errorBox(String message) {
    return ColoredBox(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _NewPipeExoFullscreenRoute extends StatefulWidget {
  const _NewPipeExoFullscreenRoute({
    required this.playerKey,
    required this.player,
  });

  final GlobalKey<_NewPipeExoPlayerState> playerKey;
  final Widget player;

  @override
  State<_NewPipeExoFullscreenRoute> createState() =>
      _NewPipeExoFullscreenRouteState();
}

class _NewPipeExoFullscreenRouteState
    extends State<_NewPipeExoFullscreenRoute> {
  @override
  void initState() {
    super.initState();
    unawaited(
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky));
    unawaited(SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          unawaited(widget.playerKey.currentState?._exitFullscreen());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: widget.player,
      ),
    );
  }
}

class _CaptionCue {
  const _CaptionCue(this.startMs, this.endMs, this.text);

  final int startMs;
  final int endMs;
  final String text;
}

class _FullscreenPlaybackState {
  const _FullscreenPlaybackState({
    required this.positionSeconds,
    required this.quality,
    required this.speed,
    required this.fitMode,
    this.audioTrackId,
    this.subtitleCode,
  });

  final int positionSeconds;
  final String quality;
  final String fitMode;
  final String? audioTrackId;
  final String? subtitleCode;
  final double speed;
}

class _CircleControl extends StatelessWidget {
  const _CircleControl({
    required this.size,
    required this.onTap,
    required this.child,
    required this.tooltip,
  });

  final double size;
  final VoidCallback onTap;
  final Widget child;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: CircleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(dimension: size, child: Center(child: child)),
        ),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  const _BarIcon({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      iconSize: 22,
      icon: Icon(icon, color: Colors.white),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
