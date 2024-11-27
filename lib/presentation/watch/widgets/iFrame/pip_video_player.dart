import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class IFramePipVideoPlayer extends StatefulWidget {
  const IFramePipVideoPlayer({
    super.key,
    required this.id,
    required this.channelId,
    required this.settingsState,
    required this.isSaved,
    required this.savedState,
    required this.watchState,
    required this.watchInfo,
    required this.playBack,
    this.isLive = false,
  });

  final String id;
  final String channelId;
  final SettingsState settingsState;
  final bool isSaved;
  final SavedState savedState;
  final WatchState watchState;
  final bool isLive;
  final ExplodeWatchResp watchInfo;
  final int playBack;

  @override
  State<IFramePipVideoPlayer> createState() => _IFramePipVideoPlayerState();
}

class _IFramePipVideoPlayerState extends State<IFramePipVideoPlayer> {
  late final YoutubePlayerController _controller;
  Offset position = const Offset(20, 20);
  Timer? _historyUpdateTimer;
  bool _isDragging = false;

  // Store screen boundaries
  late final double _maxWidth;
  late final double _maxHeight;

  // Constants
  static const double _playerWidth = 300.0;
  static const double _playerHeight = 200.0;
  static const Duration _historyUpdateInterval = Duration(seconds: 5);

  late final WatchBloc _watchBloc;
  late final SavedBloc _savedBloc;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _setupHistoryUpdateTimer();

    // Get screen dimensions after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _maxWidth = size.width - _playerWidth;
      _maxHeight = size.height - _playerHeight;
    });
  }

  void _initializeController() {
    _controller.close();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.id,
      autoPlay: true,
      startSeconds: widget.playBack.toDouble(),
      params: const YoutubePlayerParams(
        showFullscreenButton: false,
        playsInline: false,
        enableCaption: false,
        showVideoAnnotations: false,
        pointerEvents: PointerEvents.auto,
        interfaceLanguage: 'en',
      ),
    );
  }

  void _setupHistoryUpdateTimer() {
    _historyUpdateTimer?.cancel();
    _historyUpdateTimer = Timer.periodic(
      _historyUpdateInterval,
      (_) => _updateVideoHistory(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchBloc = context.read<WatchBloc>();
    _savedBloc = context.read<SavedBloc>();
  }

  @override
  void dispose() {
    _historyUpdateTimer?.cancel();
    _updateVideoHistory(); // Final update before disposing
    _controller.close();
    _watchBloc.add(WatchEvent.togglePip(value: false));
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      position = Offset(
        (position.dx + details.delta.dx).clamp(0, _maxWidth),
        (position.dy + details.delta.dy).clamp(0, _maxHeight),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onPanStart: (_) => _isDragging = true,
            onPanUpdate: _handleDragUpdate,
            onPanEnd: (_) => _isDragging = false,
            child: _buildPlayer(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayer() {
    return Container(
      width: _playerWidth,
      height: _playerHeight,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (widget.watchState.fetchExplodeWatchInfoStatus ==
              ApiStatus.loading)
            const Center(child: CircularProgressIndicator())
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: _playerWidth,
                height: _playerHeight,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _playerWidth,
                    height: _playerHeight,
                    child: YoutubePlayer(
                      controller: _controller,
                      aspectRatio: 16 / 9,
                      enableFullScreenOnVerticalDrag: false,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            left: 8,
            child: _buildCloseButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
      child: IconButton(
        onPressed: () {
          _updateVideoHistory();
          _watchBloc.add(WatchEvent.togglePip(value: false));
        },
        icon: const Icon(
          CupertinoIcons.xmark,
          color: Colors.white,
        ),
        tooltip: 'Close PiP',
      ),
    );
  }

  Future<void> _updateVideoHistory() async {
    try {
      final currentPosition = await _controller.currentTime;
      if (widget.id.isEmpty) return;

      final videoInfo = LocalStoreVideoInfo(
        id: widget.id,
        title: widget.watchInfo.title,
        views: widget.watchInfo.viewCount,
        thumbnail: widget.watchInfo.thumbnailUrl,
        uploadedDate: widget.watchInfo.uploadDate.toString(),
        uploaderAvatar: null,
        uploaderName: widget.watchInfo.author,
        uploaderId: widget.watchInfo.channelId,
        uploaderSubscriberCount: null,
        duration: widget.watchInfo.duration.inSeconds,
        uploaderVerified: false,
        isHistory: true,
        isLive: widget.watchInfo.isLive,
        isSaved: widget.isSaved,
        playbackPosition: currentPosition.toInt(),
      );

      _savedBloc.add(SavedEvent.addVideoInfo(videoInfo: videoInfo));
      _watchBloc.add(WatchEvent.updatePlayBack(playBack: currentPosition.toInt()));
    } catch (e) {
      debugPrint('Error updating video history: $e');
    }
  }
}
