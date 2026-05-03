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
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_subtitle.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/models/playback_configuration.dart';
import 'package:fluxtube/domain/watch/playback/models/stream_quality_info.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_playback_resolver.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_stream_helper.dart';
import 'package:fluxtube/presentation/watch/widgets/player/player_settings_sheet.dart';
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
  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

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
  bool _draggingBrightness = false;
  bool _draggingVolume = false;
  String? _errorMessage;
  String? _currentSubtitle;
  String? _currentCaptionText;
  String? _currentAudioTrackId;
  List<_CaptionCue> _captionCues = [];
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
          setState(() {
            if (!_isScrubbing) {
              _positionMs = (args['positionMs'] as num? ?? _positionMs).toInt();
            }
            _durationMs = (args['durationMs'] as num? ?? _durationMs).toInt();
            _isPlaying = args['isPlaying'] as bool? ?? _isPlaying;
            _isBuffering = args['isBuffering'] as bool? ?? false;
            _currentCaptionText = _captionForPosition(_positionMs);
            _errorMessage = null;
          });
          _globalPlayer.updateNativeExoPlayerState(
            playing: _isPlaying,
            buffering: _isBuffering,
            position: Duration(milliseconds: _positionMs),
            duration: Duration(milliseconds: _durationMs),
          );
          unawaited(_syncNotificationState(force: true));
          if (!widget.isFullscreen) {
            unawaited(_pipService.setVideoPlaying(_isPlaying));
          }
          if (!_isPlaying) {
            _hideTimer?.cancel();
          } else if (!wasPlaying && _showControls) {
            _startHideTimer();
          }
          break;
        case 'onError':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          if (mounted) {
            setState(() {
              _errorMessage = args['message'] as String? ?? 'Playback failed';
              _isBuffering = false;
            });
          }
          break;
      }
    });
    if (_speed != 1.0) {
      unawaited(_channel!.invokeMethod('setSpeed', {'speed': _speed}));
    }
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
    final nextPlaying = !_isPlaying;
    setState(() => _isPlaying = nextPlaying);
    _globalPlayer.updateNativeExoPlayerState(
      playing: nextPlaying,
      buffering: _isBuffering,
      position: Duration(milliseconds: _positionMs),
      duration: Duration(milliseconds: _durationMs),
    );
    unawaited(_pipService.setVideoPlaying(nextPlaying));
    unawaited(_syncNotificationState(force: true));
    if (_isPlaying) {
      await channel.invokeMethod('play');
    } else {
      await channel.invokeMethod('pause');
    }
    _startHideTimer();
  }

  Future<void> _seekTo(int positionMs) async {
    if (_config.isLive) return;
    final bounded = positionMs.clamp(0, _durationMs);
    setState(() => _positionMs = bounded);
    await _channel?.invokeMethod('seekTo', {'positionMs': bounded});
    unawaited(_syncNotificationState(force: true));
  }

  Future<void> _skipBy(int seconds) async {
    await _seekTo(_positionMs + seconds * 1000);
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
        setState(() => _isPlaying = true);
        unawaited(_syncNotificationState(force: true));
      },
      pause: () async {
        if (!mounted) return;
        setState(() => _isPlaying = false);
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
      return _errorBox('No playable stream was found');
    }

    final player = Stack(
      fit: StackFit.expand,
      children: [
        AndroidView(
          viewType: 'fluxtube/newpipe_exoplayer',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: _sourceParams(startPositionMs: _positionMs),
          creationParamsCodec: const StandardMessageCodec(),
        ),
        _buildGestureLayer(),
        if (_currentCaptionText != null && _currentCaptionText!.isNotEmpty)
          _buildCaption(_currentCaptionText!),
        if (_showControls) _buildControls(),
        if (_draggingBrightness)
          _buildVerticalIndicator(CupertinoIcons.sun_max, _brightness),
        if (_draggingVolume)
          _buildVerticalIndicator(CupertinoIcons.volume_up, _volume),
        if (_isBuffering) const Center(child: CircularProgressIndicator()),
        if (_errorMessage != null) _errorBox(_errorMessage!),
      ],
    );

    if (widget.isFullscreen) {
      return ColoredBox(color: Colors.black, child: Center(child: player));
    }

    return AspectRatio(aspectRatio: 16 / 9, child: player);
  }

  Widget _buildGestureLayer() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleControls,
            onDoubleTap: () => _skipBy(-widget.skipInterval),
            onVerticalDragStart: (details) {
              _verticalDragStartY = details.globalPosition.dy;
              _verticalDragStartValue = _brightness;
              setState(() {
                _draggingBrightness = true;
                _showControls = true;
              });
            },
            onVerticalDragUpdate: _updateBrightness,
            onVerticalDragEnd: (_) {
              setState(() => _draggingBrightness = false);
              _startHideTimer();
            },
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleControls,
            onDoubleTap: () => _skipBy(widget.skipInterval),
            onVerticalDragStart: (details) {
              _verticalDragStartY = details.globalPosition.dy;
              _verticalDragStartValue = _volume;
              setState(() {
                _draggingVolume = true;
                _showControls = true;
              });
            },
            onVerticalDragUpdate: _updateVolume,
            onVerticalDragEnd: (_) {
              setState(() => _draggingVolume = false);
              _startHideTimer();
            },
          ),
        ),
      ],
    );
  }

  Future<void> _updateBrightness(DragUpdateDetails details) async {
    final delta = (_verticalDragStartY - details.globalPosition.dy) / 300;
    final value = (_verticalDragStartValue + delta).clamp(0.0, 1.0);
    setState(() => _brightness = value);
    try {
      await ScreenBrightness().setApplicationScreenBrightness(value);
    } catch (_) {}
  }

  Future<void> _updateVolume(DragUpdateDetails details) async {
    final delta = (_verticalDragStartY - details.globalPosition.dy) / 300;
    final value = (_verticalDragStartValue + delta).clamp(0.0, 1.0);
    setState(() => _volume = value);
    try {
      await VolumeController.instance.setVolume(value);
    } catch (_) {}
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  Widget _buildControls() {
    final position = Duration(milliseconds: (_scrubMs ?? _positionMs).round());
    final duration = Duration(milliseconds: _durationMs);
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent, Colors.black87],
              ),
            ),
          ),
        ),
        Column(
          children: [
            _buildTopBar(),
            const Spacer(),
            IconButton(
              iconSize: 56,
              color: Colors.white,
              onPressed: _togglePlay,
              icon: Icon(_isPlaying
                  ? CupertinoIcons.pause_fill
                  : CupertinoIcons.play_fill),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Text(_formatDuration(position), style: _timeStyle),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: Colors.red,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: Colors.red,
                      ),
                      child: Slider(
                        min: 0,
                        max: _durationMs <= 0 ? 1 : _durationMs.toDouble(),
                        value: (_scrubMs ?? _positionMs)
                            .clamp(0, _durationMs <= 0 ? 1 : _durationMs)
                            .toDouble(),
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
                    ),
                  ),
                  Text(_config.isLive ? 'LIVE' : _formatDuration(duration),
                      style: _timeStyle),
                ],
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ],
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

  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            if (widget.isFullscreen)
              IconButton(
                onPressed: _enterFullscreen,
                icon: const Icon(CupertinoIcons.chevron_down,
                    color: Colors.white),
              ),
            Expanded(
              child: Text(
                widget.watchInfo.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              tooltip: 'Captions',
              onPressed: (widget.watchInfo.subtitles ?? []).isEmpty
                  ? null
                  : () => _openSettings(initialPage: SettingsPage.captions),
              icon: Icon(
                CupertinoIcons.captions_bubble,
                color: _currentSubtitle == null ? Colors.white : Colors.red,
              ),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: _openSettings,
              icon: const Icon(CupertinoIcons.gear_alt, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Rewind',
              onPressed:
                  _config.isLive ? null : () => _skipBy(-widget.skipInterval),
              icon: const Icon(CupertinoIcons.gobackward, color: Colors.white),
            ),
            IconButton(
              tooltip: 'Forward',
              onPressed:
                  _config.isLive ? null : () => _skipBy(widget.skipInterval),
              icon: const Icon(CupertinoIcons.goforward, color: Colors.white),
            ),
            TextButton(
              onPressed: () => _openSettings(initialPage: SettingsPage.quality),
              child: Text(_currentQuality,
                  style: const TextStyle(color: Colors.white)),
            ),
            if (_audioTracks.length > 1)
              TextButton(
                onPressed: () =>
                    _openSettings(initialPage: SettingsPage.audioTrack),
                child:
                    const Text('Audio', style: TextStyle(color: Colors.white)),
              ),
            const Spacer(),
            IconButton(
              tooltip: 'Resize',
              onPressed: _cycleFitMode,
              icon: Icon(
                switch (_fitMode) {
                  'cover' => CupertinoIcons.rectangle_expand_vertical,
                  'fill' => CupertinoIcons.rectangle_fill,
                  _ => CupertinoIcons.rectangle,
                },
                color: Colors.white,
              ),
            ),
            IconButton(
              tooltip: widget.isFullscreen ? 'Exit fullscreen' : 'Fullscreen',
              onPressed: _enterFullscreen,
              icon: const Icon(
                CupertinoIcons.arrow_up_left_arrow_down_right,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _timeStyle => const TextStyle(
        color: Colors.white,
        fontSize: 12,
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
