import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_subtitle.dart';
import 'package:fluxtube/domain/watch/playback/models/stream_quality_info.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_stream_helper.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

import 'player_settings_sheet.dart';

/// YouTube-like custom video player controls overlay
class PlayerControlsOverlay extends StatefulWidget {
  const PlayerControlsOverlay({
    super.key,
    required this.player,
    required this.videoState,
    required this.availableQualities,
    required this.currentQuality,
    required this.onQualityChanged,
    required this.subtitles,
    required this.skipInterval,
    required this.isLive,
    this.enableBrightnessVolumeGestures = true,
    this.currentFitMode = BoxFit.contain,
    this.onFitModeChanged,
    this.availableAudioTracks,
    this.currentAudioTrackId,
    this.onAudioTrackChanged,
    this.isInitializing = false,
  });

  final Player player;
  final VideoState videoState;
  final List<StreamQualityInfo>? availableQualities;
  final String? currentQuality;
  final Function(String) onQualityChanged;
  final List<NewPipeSubtitle> subtitles;
  final int skipInterval;
  final bool isLive;
  final bool enableBrightnessVolumeGestures;
  final BoxFit currentFitMode;
  final Function(BoxFit)? onFitModeChanged;
  final List<AudioTrackInfo>? availableAudioTracks;
  final String? currentAudioTrackId;
  final Function(String)? onAudioTrackChanged;
  /// When true, shows a loading spinner instead of play/pause button
  final bool isInitializing;

  @override
  State<PlayerControlsOverlay> createState() => _PlayerControlsOverlayState();
}

class _PlayerControlsOverlayState extends State<PlayerControlsOverlay>
    with TickerProviderStateMixin {
  bool _showControls = true;
  Timer? _hideTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Seek ripple animation
  late AnimationController _seekRippleController;
  late Animation<double> _seekRippleAnimation;
  bool _showSeekRippleLeft = false;
  bool _showSeekRippleRight = false;
  int _seekAmount = 0;

  // Long press speed boost
  bool _isLongPressing = false;
  double _previousSpeed = 1.0;

  // Global player for persisting state
  final GlobalPlayerController _globalPlayer = GlobalPlayerController();

  // Playback state
  double _currentSpeed = 1.0;
  String? _currentSubtitle;
  bool _isScrubbing = false;
  double? _scrubPositionMs;

  // Volume and brightness gesture state
  bool _isVerticalDragging = false;
  bool _isDraggingBrightness = false;
  bool _isDraggingVolume = false;
  double _currentBrightness = 0.5;
  double _currentVolume = 0.5;
  double _startDragY = 0;
  double _startValue = 0;
  Timer? _indicatorHideTimer;
  bool _showVolumeIndicator = false;
  bool _showBrightnessIndicator = false;

  // Available playback speeds
  static const List<double> _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  // Available video fit modes for fullscreen
  static const List<BoxFit> _fitModes = [BoxFit.contain, BoxFit.cover, BoxFit.fill];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.value = 1.0;

    // Seek ripple animation
    _seekRippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _seekRippleAnimation = CurvedAnimation(
      parent: _seekRippleController,
      curve: Curves.easeOut,
    );
    _seekRippleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showSeekRippleLeft = false;
          _showSeekRippleRight = false;
          _seekAmount = 0;
        });
        _seekRippleController.reset();
      }
    });

    _initBrightnessAndVolume();
    _startHideTimer();

    // Restore subtitle state from global player
    _restoreSubtitleState();
  }

  @override
  void didUpdateWidget(PlayerControlsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If subtitles list changed and we don't have a current subtitle set,
    // try to restore from global state
    if (oldWidget.subtitles != widget.subtitles && _currentSubtitle == null) {
      _restoreSubtitleState();
    }
  }

  void _restoreSubtitleState() {
    final savedSubtitle = _globalPlayer.currentSubtitleCode;
    if (savedSubtitle != null && widget.subtitles.any((s) => s.languageCode == savedSubtitle)) {
      setState(() {
        _currentSubtitle = savedSubtitle;
      });
    }
  }

  StreamSubscription<double>? _volumeSubscription;

  Future<void> _initBrightnessAndVolume() async {
    try {
      // Get current brightness
      _currentBrightness = await ScreenBrightness().application;

      // Get current volume and hide system UI
      VolumeController.instance.showSystemUI = false;
      _currentVolume = await VolumeController.instance.getVolume();

      // Listen to volume changes
      _volumeSubscription = VolumeController.instance.addListener((volume) {
        if (mounted) {
          setState(() => _currentVolume = volume);
        }
      });
    } catch (e) {
      debugPrint('Error initializing brightness/volume: $e');
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _indicatorHideTimer?.cancel();
    _animationController.dispose();
    _seekRippleController.dispose();
    _volumeSubscription?.cancel();
    // Reset brightness to system default when leaving
    ScreenBrightness().resetApplicationScreenBrightness();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (widget.player.state.playing) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && widget.player.state.playing) {
          _hideControls();
        }
      });
    }
  }

  void _showControlsOverlay() {
    setState(() => _showControls = true);
    _animationController.forward();
    _startHideTimer();
  }

  void _hideControls() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControls();
    } else {
      _showControlsOverlay();
    }
  }

  void _onTap() {
    _toggleControls();
  }

  void _onDoubleTapLeft() {
    if (widget.isLive) return;
    _seekBackward();
    _showSeekRipple(isLeft: true);
  }

  void _onDoubleTapRight() {
    if (widget.isLive) return;
    _seekForward();
    _showSeekRipple(isLeft: false);
  }

  void _showSeekRipple({required bool isLeft}) {
    setState(() {
      if (isLeft) {
        _showSeekRippleLeft = true;
        _seekAmount = -widget.skipInterval;
      } else {
        _showSeekRippleRight = true;
        _seekAmount = widget.skipInterval;
      }
    });
    _seekRippleController.forward(from: 0);
  }

  void _seekForward() {
    final newPosition = widget.player.state.position +
        Duration(seconds: widget.skipInterval);
    final duration = widget.player.state.duration;
    if (newPosition < duration) {
      widget.player.seek(newPosition);
    } else {
      widget.player.seek(duration);
    }
  }

  void _seekBackward() {
    final newPosition = widget.player.state.position -
        Duration(seconds: widget.skipInterval);
    if (newPosition > Duration.zero) {
      widget.player.seek(newPosition);
    } else {
      widget.player.seek(Duration.zero);
    }
  }

  void _togglePlayPause() {
    if (widget.player.state.playing) {
      widget.player.pause();
    } else {
      widget.player.play();
    }
    _startHideTimer();
  }

  void _onLongPressStart() {
    if (widget.isLive) return;
    setState(() {
      _isLongPressing = true;
      _previousSpeed = _currentSpeed;
    });
    widget.player.setRate(2.0);
  }

  void _onLongPressEnd() {
    if (!_isLongPressing) return;
    setState(() {
      _isLongPressing = false;
    });
    widget.player.setRate(_previousSpeed);
  }

  void _setPlaybackSpeed(double speed) {
    widget.player.setRate(speed);
    setState(() => _currentSpeed = speed);
  }

  void _toggleFullscreen() {
    toggleFullscreen(context);
  }

  void _cycleFitMode() {
    if (widget.onFitModeChanged == null) return;
    final currentIndex = _fitModes.indexOf(widget.currentFitMode);
    final nextIndex = (currentIndex + 1) % _fitModes.length;
    widget.onFitModeChanged!(_fitModes[nextIndex]);
    _startHideTimer();
  }

  IconData _getFitModeIcon(BoxFit fitMode) {
    switch (fitMode) {
      case BoxFit.contain:
        return CupertinoIcons.rectangle;
      case BoxFit.cover:
        return CupertinoIcons.rectangle_fill;
      case BoxFit.fill:
        return CupertinoIcons.rectangle_expand_vertical;
      default:
        return CupertinoIcons.rectangle;
    }
  }

  String _getFitModeLabel(BoxFit fitMode) {
    switch (fitMode) {
      case BoxFit.contain:
        return 'Fit';
      case BoxFit.cover:
        return 'Crop';
      case BoxFit.fill:
        return 'Stretch';
      default:
        return 'Fit';
    }
  }

  // Vertical drag for brightness/volume
  void _onVerticalDragStart(DragStartDetails details, bool isLeftSide) {
    _hideTimer?.cancel();
    _isVerticalDragging = true;
    _startDragY = details.localPosition.dy;

    if (isLeftSide) {
      _isDraggingBrightness = true;
      _startValue = _currentBrightness;
      setState(() => _showBrightnessIndicator = true);
    } else {
      _isDraggingVolume = true;
      _startValue = _currentVolume;
      setState(() => _showVolumeIndicator = true);
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details, double height) {
    if (!_isVerticalDragging) return;

    final dragDistance = _startDragY - details.localPosition.dy;
    final dragPercentage = dragDistance / (height * 0.7); // 70% of height for full range
    final newValue = (_startValue + dragPercentage).clamp(0.0, 1.0);

    if (_isDraggingBrightness) {
      _setBrightness(newValue);
    } else if (_isDraggingVolume) {
      _setVolume(newValue);
    }
  }

  void _onVerticalDragEnd() {
    _isVerticalDragging = false;
    _isDraggingBrightness = false;
    _isDraggingVolume = false;
    _startHideTimer();

    // Hide indicators after a delay
    _indicatorHideTimer?.cancel();
    _indicatorHideTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showVolumeIndicator = false;
          _showBrightnessIndicator = false;
        });
      }
    });
  }

  Future<void> _setBrightness(double value) async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(value);
      setState(() => _currentBrightness = value);
    } catch (e) {
      debugPrint('Error setting brightness: $e');
    }
  }

  Future<void> _setVolume(double value) async {
    try {
      await VolumeController.instance.setVolume(value);
      setState(() => _currentVolume = value);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  void _showSettingsSheet() {
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PlayerSettingsSheet(
        currentSpeed: _currentSpeed,
        speeds: _speeds,
        onSpeedChanged: _setPlaybackSpeed,
        currentQuality: widget.currentQuality,
        qualities: widget.availableQualities,
        onQualityChanged: widget.onQualityChanged,
        subtitles: widget.subtitles,
        currentSubtitle: _currentSubtitle,
        onSubtitleChanged: _handleSubtitleChange,
        isLive: widget.isLive,
        audioTracks: widget.availableAudioTracks,
        currentAudioTrackId: widget.currentAudioTrackId,
        onAudioTrackChanged: widget.onAudioTrackChanged,
      ),
    ).then((_) => _startHideTimer());
  }

  void _showSpeedSheet() {
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PlayerSettingsSheet(
        currentSpeed: _currentSpeed,
        speeds: _speeds,
        onSpeedChanged: _setPlaybackSpeed,
        currentQuality: widget.currentQuality,
        qualities: widget.availableQualities,
        onQualityChanged: widget.onQualityChanged,
        subtitles: widget.subtitles,
        currentSubtitle: _currentSubtitle,
        onSubtitleChanged: _handleSubtitleChange,
        isLive: widget.isLive,
        initialPage: SettingsPage.speed,
        audioTracks: widget.availableAudioTracks,
        currentAudioTrackId: widget.currentAudioTrackId,
        onAudioTrackChanged: widget.onAudioTrackChanged,
      ),
    ).then((_) => _startHideTimer());
  }

  void _showQualitySheet() {
    if (widget.availableQualities == null || widget.availableQualities!.isEmpty) {
      return;
    }
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PlayerSettingsSheet(
        currentSpeed: _currentSpeed,
        speeds: _speeds,
        onSpeedChanged: _setPlaybackSpeed,
        currentQuality: widget.currentQuality,
        qualities: widget.availableQualities,
        onQualityChanged: widget.onQualityChanged,
        subtitles: widget.subtitles,
        currentSubtitle: _currentSubtitle,
        onSubtitleChanged: _handleSubtitleChange,
        isLive: widget.isLive,
        initialPage: SettingsPage.quality,
        audioTracks: widget.availableAudioTracks,
        currentAudioTrackId: widget.currentAudioTrackId,
        onAudioTrackChanged: widget.onAudioTrackChanged,
      ),
    ).then((_) => _startHideTimer());
  }

  void _showCaptionsSheet() {
    if (widget.subtitles.isEmpty) {
      return;
    }
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PlayerSettingsSheet(
        currentSpeed: _currentSpeed,
        speeds: _speeds,
        onSpeedChanged: _setPlaybackSpeed,
        currentQuality: widget.currentQuality,
        qualities: widget.availableQualities,
        onQualityChanged: widget.onQualityChanged,
        subtitles: widget.subtitles,
        currentSubtitle: _currentSubtitle,
        onSubtitleChanged: _handleSubtitleChange,
        isLive: widget.isLive,
        initialPage: SettingsPage.captions,
        audioTracks: widget.availableAudioTracks,
        currentAudioTrackId: widget.currentAudioTrackId,
        onAudioTrackChanged: widget.onAudioTrackChanged,
      ),
    ).then((_) => _startHideTimer());
  }

  void _handleSubtitleChange(String? subtitle) {
    // If clicking the same subtitle that's already active, turn it off
    if (subtitle != null && subtitle == _currentSubtitle) {
      debugPrint('Same subtitle clicked, turning off: $subtitle');
      setState(() => _currentSubtitle = null);
      _globalPlayer.setCurrentSubtitleCode(null);
      widget.player.setSubtitleTrack(SubtitleTrack.no());
      return;
    }

    setState(() => _currentSubtitle = subtitle);
    // Save to global state for persistence across widget rebuilds
    _globalPlayer.setCurrentSubtitleCode(subtitle);

    if (subtitle != null) {
      final sub = widget.subtitles.firstWhere(
        (s) => s.languageCode == subtitle,
        orElse: () => widget.subtitles.first,
      );
      if (sub.url != null && sub.url!.isNotEmpty) {
        // Convert TTML format to VTT format for media_kit compatibility
        // YouTube subtitles use TTML by default, but media_kit supports VTT better
        String subtitleUrl = sub.url!;
        if (subtitleUrl.contains('fmt=ttml')) {
          subtitleUrl = subtitleUrl.replaceAll('fmt=ttml', 'fmt=vtt');
        } else if (subtitleUrl.contains('&fmt=') == false && subtitleUrl.contains('youtube.com')) {
          // If no format specified, append VTT format
          subtitleUrl = '$subtitleUrl&fmt=vtt';
        }

        debugPrint('Setting subtitle track: ${sub.languageCode}');
        debugPrint('Original URL: ${sub.url}');
        debugPrint('Converted URL: $subtitleUrl');
        widget.player.setSubtitleTrack(
          SubtitleTrack.uri(subtitleUrl, title: sub.languageCode ?? 'Unknown'),
        );
      } else {
        debugPrint('Subtitle URL is null or empty for: ${sub.languageCode}');
      }
    } else {
      debugPrint('Disabling subtitles');
      widget.player.setSubtitleTrack(SubtitleTrack.no());
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Enable brightness/volume gestures only in fullscreen mode
    final isCurrentlyFullscreen = isFullscreen(context);
    final enableGestures = widget.enableBrightnessVolumeGestures && isCurrentlyFullscreen;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        return GestureDetector(
          onTap: _onTap,
          onLongPressStart: (_) => _onLongPressStart(),
          onLongPressEnd: (_) => _onLongPressEnd(),
          onLongPressCancel: _onLongPressEnd,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Left side - brightness gesture zone (only in fullscreen) / double tap zone
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: width / 2,
                child: GestureDetector(
                  onDoubleTap: _onDoubleTapLeft,
                  onVerticalDragStart: enableGestures
                      ? (details) => _onVerticalDragStart(details, true)
                      : null,
                  onVerticalDragUpdate: enableGestures
                      ? (details) => _onVerticalDragUpdate(details, height)
                      : null,
                  onVerticalDragEnd: enableGestures
                      ? (_) => _onVerticalDragEnd()
                      : null,
                  behavior: HitTestBehavior.translucent,
                  child: const SizedBox.expand(),
                ),
              ),

              // Right side - volume gesture zone (only in fullscreen) / double tap zone
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: width / 2,
                child: GestureDetector(
                  onDoubleTap: _onDoubleTapRight,
                  onVerticalDragStart: enableGestures
                      ? (details) => _onVerticalDragStart(details, false)
                      : null,
                  onVerticalDragUpdate: enableGestures
                      ? (details) => _onVerticalDragUpdate(details, height)
                      : null,
                  onVerticalDragEnd: enableGestures
                      ? (_) => _onVerticalDragEnd()
                      : null,
                  behavior: HitTestBehavior.translucent,
                  child: const SizedBox.expand(),
                ),
              ),

              // Seek ripple effect - left
              if (_showSeekRippleLeft)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: width / 2,
                  child: _buildSeekRipple(isLeft: true),
                ),

              // Seek ripple effect - right
              if (_showSeekRippleRight)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: width / 2,
                  child: _buildSeekRipple(isLeft: false),
                ),

              // Brightness indicator
              if (_showBrightnessIndicator)
                Positioned(
                  left: 24,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildVerticalIndicator(
                      value: _currentBrightness,
                      icon: _currentBrightness > 0.5
                          ? CupertinoIcons.sun_max_fill
                          : CupertinoIcons.sun_min_fill,
                      label: '${(_currentBrightness * 100).round()}%',
                    ),
                  ),
                ),

              // Volume indicator
              if (_showVolumeIndicator)
                Positioned(
                  right: 24,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildVerticalIndicator(
                      value: _currentVolume,
                      icon: _currentVolume > 0.5
                          ? CupertinoIcons.speaker_3_fill
                          : _currentVolume > 0
                              ? CupertinoIcons.speaker_2_fill
                              : CupertinoIcons.speaker_slash_fill,
                      label: '${(_currentVolume * 100).round()}%',
                    ),
                  ),
                ),

              // Long press speed indicator
              if (_isLongPressing)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.forward_fill,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '2x',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Controls overlay
              if (_showControls && !_isLongPressing && !_isVerticalDragging)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.25, 0.75, 1.0],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Top bar
                        _buildTopBar(),

                        // Center controls
                        _buildCenterControls(),

                        // Bottom bar with progress and controls
                        _buildBottomBar(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalIndicator({
    required double value,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            width: 4,
            child: RotatedBox(
              quarterTurns: 3,
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekRipple({required bool isLeft}) {
    return AnimatedBuilder(
      animation: _seekRippleAnimation,
      builder: (context, child) {
        final progress = _seekRippleAnimation.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              radius: 1.5 * progress,
              colors: [
                Colors.white.withValues(alpha: 0.3 * (1 - progress)),
                Colors.white.withValues(alpha: 0.1 * (1 - progress)),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? Radius.zero : const Radius.circular(100),
              bottomLeft: isLeft ? Radius.zero : const Radius.circular(100),
              topRight: isLeft ? const Radius.circular(100) : Radius.zero,
              bottomRight: isLeft ? const Radius.circular(100) : Radius.zero,
            ),
          ),
          child: Center(
            child: Opacity(
              opacity: (1 - progress).clamp(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLeft) ...[
                        Icon(
                          CupertinoIcons.gobackward,
                          color: Colors.white,
                          size: 32 + (8 * progress),
                        ),
                      ] else ...[
                        Icon(
                          CupertinoIcons.goforward,
                          color: Colors.white,
                          size: 32 + (8 * progress),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_seekAmount > 0 ? '+' : ''}$_seekAmount seconds',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    final isCurrentlyFullscreen = isFullscreen(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Fit mode button (only in fullscreen)
              if (isCurrentlyFullscreen && widget.onFitModeChanged != null)
                GestureDetector(
                  onTap: _cycleFitMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getFitModeIcon(widget.currentFitMode),
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getFitModeLabel(widget.currentFitMode),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Captions button (if available) - opens directly to captions
              if (widget.subtitles.isNotEmpty)
                _buildIconButton(
                  icon: _currentSubtitle != null
                      ? CupertinoIcons.captions_bubble_fill
                      : CupertinoIcons.captions_bubble,
                  onTap: _showCaptionsSheet,
                ),

              // Settings button
              _buildIconButton(
                icon: CupertinoIcons.gear,
                onTap: _showSettingsSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Positioned.fill(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skip backward button
            if (!widget.isLive)
              _buildSkipButton(
                icon: CupertinoIcons.gobackward,
                label: '${widget.skipInterval}',
                onTap: () {
                  _seekBackward();
                  _showSeekRipple(isLeft: true);
                },
              ),

            const SizedBox(width: 32),

            // Play/Pause button
            _buildPlayPauseButton(),

            const SizedBox(width: 32),

            // Skip forward button
            if (!widget.isLive)
              _buildSkipButton(
                icon: CupertinoIcons.goforward,
                label: '${widget.skipInterval}',
                onTap: () {
                  _seekForward();
                  _showSeekRipple(isLeft: false);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            Positioned(
              bottom: 6,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    // Show loading spinner when initializing (before playback starts)
    if (widget.isInitializing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return StreamBuilder<bool>(
      stream: widget.player.stream.playing,
      initialData: widget.player.state.playing,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                key: ValueKey(isPlaying),
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final isCurrentlyFullscreen = isFullscreen(context);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row with time, indicators, and fullscreen
              Row(
                children: [
                  // Time display
                  _buildTimeDisplay(),

                  const Spacer(),

                  // Speed indicator (if not 1x) - tappable
                  if (_currentSpeed != 1.0)
                    GestureDetector(
                      onTap: _showSpeedSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_currentSpeed}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  // Quality indicator - opens directly to quality sheet
                  if (widget.currentQuality != null)
                    GestureDetector(
                      onTap: _showQualitySheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.currentQuality!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  // Fullscreen button
                  _buildIconButton(
                    icon: isCurrentlyFullscreen
                        ? CupertinoIcons.fullscreen_exit
                        : CupertinoIcons.fullscreen,
                    onTap: _toggleFullscreen,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress bar at the bottom
              if (!widget.isLive) _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder<Duration>(
      stream: widget.player.stream.position,
      initialData: widget.player.state.position,
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration>(
          stream: widget.player.stream.duration,
          initialData: widget.player.state.duration,
          builder: (context, durationSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final duration = durationSnapshot.data ?? Duration.zero;

            return StreamBuilder<Duration>(
              stream: widget.player.stream.buffer,
              initialData: widget.player.state.buffer,
              builder: (context, bufferSnapshot) {
                final buffer = bufferSnapshot.data ?? Duration.zero;

                return SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    activeTrackColor: Colors.red,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: Colors.red,
                    overlayColor: Colors.red.withValues(alpha: 0.2),
                    secondaryActiveTrackColor: Colors.white.withValues(alpha: 0.5),
                  ),
                  child: Slider(
                    value: duration.inMilliseconds > 0
                        ? (_isScrubbing
                                ? (_scrubPositionMs ?? 0)
                                : position.inMilliseconds.toDouble())
                            .clamp(0, duration.inMilliseconds.toDouble())
                        : 0,
                    min: 0,
                    max: duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1,
                    secondaryTrackValue: duration.inMilliseconds > 0
                        ? buffer.inMilliseconds.toDouble().clamp(
                            0, duration.inMilliseconds.toDouble())
                        : 0,
                    onChanged: (value) {
                      setState(() {
                        _isScrubbing = true;
                        _scrubPositionMs = value;
                      });
                    },
                    onChangeStart: (_) {
                      _hideTimer?.cancel();
                    },
                    onChangeEnd: (value) {
                      widget.player.seek(Duration(milliseconds: value.toInt()));
                      setState(() {
                        _isScrubbing = false;
                        _scrubPositionMs = null;
                      });
                      _startHideTimer();
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTimeDisplay() {
    if (widget.isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              color: Colors.white,
              size: 8,
            ),
            SizedBox(width: 4),
            Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<Duration>(
      stream: widget.player.stream.position,
      initialData: widget.player.state.position,
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration>(
          stream: widget.player.stream.duration,
          initialData: widget.player.state.duration,
          builder: (context, durationSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final duration = durationSnapshot.data ?? Duration.zero;

            return Text(
              '${_formatDuration(position)} / ${_formatDuration(duration)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
