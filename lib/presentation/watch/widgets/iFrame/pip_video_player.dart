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

  @override
  State<IFramePipVideoPlayer> createState() => _IFramePipVideoPlayerState();
}

class _IFramePipVideoPlayerState extends State<IFramePipVideoPlayer> {
  YoutubePlayerController? _controller;

  Offset position = const Offset(20, 20);

  WatchBloc? _watchBloc;
  SavedBloc? _savedBloc;

  @override
  void initState() {
    _savedBloc = BlocProvider.of<SavedBloc>(context);
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.id,
      autoPlay: true,
      startSeconds: (widget.savedState.localSavedHistoryVideos
                  .firstWhere(
                    (element) => element.id == widget.id,
                    orElse: () => LocalStoreVideoInfo(
                      playbackPosition: 0, // Default value
                      // other properties with default values
                      id: '',
                      title: '',
                      views: 0,
                      thumbnail: '',
                      uploadedDate: '',
                      uploaderAvatar: null,
                      uploaderName: '',
                      uploaderId: '',
                      uploaderSubscriberCount: null,
                      duration: 0,
                      uploaderVerified: false,
                      isHistory: true,
                      isLive: false,
                      isSaved: false,
                    ),
                  )
                  .playbackPosition ??
              0)
          .toDouble(),
      params: const YoutubePlayerParams(
          showFullscreenButton: false,
          playsInline: false,
          enableCaption: false,
          showVideoAnnotations: false,
          pointerEvents: PointerEvents.auto),
    );
    // Start history update timer
    _updateVideoHistory();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache the reference to the WatchBloc ancestor here
    _watchBloc = BlocProvider.of<WatchBloc>(context);
  }

  @override
  void dispose() {
    _updateVideoHistory();
    _watchBloc?.add(WatchEvent.togglePip(value: false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: _buildPlayer(),
        ),
      ],
    );
  }

  Widget _buildPlayer() {
    return SizedBox(
      child: Stack(
        children: [
          SizedBox(
              width: 300,
              height: 200,
              child: widget.watchState.fetchExplodeWatchInfoStatus ==
                      ApiStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : YoutubePlayer(
                      controller: _controller!,
                      aspectRatio: 16 / 9,
                      enableFullScreenOnVerticalDrag: false,
                    )),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              //onPressed: pipClose,
              onPressed: () {
                _updateVideoHistory();
                _watchBloc?.add(WatchEvent.togglePip(value: false));
              },
              icon: const Icon(CupertinoIcons.xmark),
            ),
          )
        ],
      ),
    );
  }

  void _updateVideoHistory() async {
    final currentPosition = _controller?.currentTime;
    if (currentPosition != null && widget.id.isNotEmpty) {
      // Create a LocalStoreVideoInfo object with relevant video information
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
        playbackPosition: int.tryParse('$currentPosition') ?? 0,
      );
      // Add the video information to the SavedBloc
      _savedBloc!.add(SavedEvent.addVideoInfo(videoInfo: videoInfo));
    }
  }
}
