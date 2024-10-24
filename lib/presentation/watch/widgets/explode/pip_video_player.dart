// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/generated/l10n.dart';

class ExplodePipVideoPlayerWidget extends StatefulWidget {
  const ExplodePipVideoPlayerWidget({
    super.key,
    required this.watchInfo,
    required this.availableVideoTracks,
    required this.videoId,
    this.defaultQuality = "720p",
    required this.playbackPosition,
    this.isSaved = false,
    this.liveUrl,
    required this.subtitles,
    required this.watchState,
  });

  final ExplodeWatchResp watchInfo;
  final List<MyMuxedStreamInfo> availableVideoTracks;
  final String videoId;
  final String defaultQuality;
  final int playbackPosition;
  final bool isSaved;
  final String? liveUrl;
  final List<Map<String, String>> subtitles;
  final WatchState watchState;

  @override
  State<ExplodePipVideoPlayerWidget> createState() =>
      _ExplodePipVideoPlayerWidget();
}

class _ExplodePipVideoPlayerWidget extends State<ExplodePipVideoPlayerWidget> {
  BetterPlayerController? _betterPlayerController;
  MyMuxedStreamInfo? selectedVideoTrack;
  late final double aspectRatio;
  late final SavedBloc _savedBloc;
  BetterPlayerDataSource? betterPlayerDataSource;

  // Track the position of the video player on the screen
  Offset position = const Offset(20, 20);

  WatchBloc? _watchBloc;

  @override
  void initState() {
    super.initState();

    _savedBloc = BlocProvider.of<SavedBloc>(context);
    aspectRatio = _selectAspectRatio();
    selectedVideoTrack = _selectVideoTrack();
    _setupPlayer(widget.playbackPosition);
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
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Use Positioned to allow free movement on the screen
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable(
            feedback: _buildPlayer(),
            childWhenDragging:
                Container(), // Show an empty container while dragging
            onDraggableCanceled: (Velocity velocity, Offset offset) {
              setState(() {
                // Update the position of the player based on the drag
                position = offset;
              });
            },
            child: _buildPlayer(),
          ),
        ),
        // Close button to stop Picture in Picture and toggle the state
      ],
    );
  }

  Widget _buildPlayer() {
    return SizedBox(
      width: 250, // or any width you prefer
      height: 140, // maintain a suitable aspect ratio
      child: Stack(children: [
        widget.watchState.fetchExplodeWatchInfoStatus == ApiStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : AspectRatio(
                aspectRatio: 16 / 8,
                child: _betterPlayerController != null
                    ? BetterPlayer(controller: _betterPlayerController!)
                    : const Center(child: CircularProgressIndicator()),
              ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () {
              _updateVideoHistory();
              _betterPlayerController?.dispose(forceDispose: true);
              _watchBloc?.add(WatchEvent.togglePip(value: false));
            },
            icon: const Icon(CupertinoIcons.xmark),
          ),
        )
      ]),
    );
  }

  double _selectAspectRatio() {
    //final firstStream = widget.availableVideoTracks.firstOrNull;
    // if (firstStream != null &&
    //     firstStream.width != null &&
    //     firstStream.height != null) {
    //   return firstStream.width! / firstStream.height!;
    // }
    return 16 / 9; // Default aspect ratio
  }

  MyMuxedStreamInfo? _selectVideoTrack() {
    // Check if the availableVideoTracks list is empty or is it hls player
    if (widget.availableVideoTracks.isEmpty || widget.watchInfo.isLive) {
      return null;
    }

    MyMuxedStreamInfo? defaultTrack;
    for (var video in widget.availableVideoTracks) {
      if (video.quality == widget.defaultQuality) {
        defaultTrack = video;
        break;
      }
    }

    if (defaultTrack == null) {
      // If the default quality is not found, find the closest quality.
      final defaultQualityValue =
          int.tryParse(widget.defaultQuality.replaceAll('p', '')) ?? 0;

      int smallestDifference = double.maxFinite.toInt();
      for (var track in widget.availableVideoTracks) {
        int trackQualityValue =
            int.tryParse(track.quality.replaceAll('p', '')) ?? 0;
        int difference = (trackQualityValue - defaultQualityValue).abs();

        if (difference < smallestDifference) {
          smallestDifference = difference;
          defaultTrack = track;
        }
      }
    }

    // Ensure that the return statement is safe
    return defaultTrack ?? widget.availableVideoTracks.first;
  }

  void _setupPlayer(int startPosition) {
    if (selectedVideoTrack == null && !widget.watchInfo.isLive) {
      _showNoVideoAvailableToast();
      return;
    }

    betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.watchInfo.isLive ? widget.liveUrl! : selectedVideoTrack!.url,
      subtitles: _createSubtitles(),
      liveStream: widget.watchInfo.isLive,
      videoFormat: widget.watchInfo.isLive
          ? BetterPlayerVideoFormat.hls
          : BetterPlayerVideoFormat.other,
      // cacheConfiguration: const BetterPlayerCacheConfiguration(
      //   useCache: true,
      //   preCacheSize: 10 * 1024 * 1024, // 10 MB
      //   maxCacheSize: 30 * 1024 * 1024, // 30 MB
      //   maxCacheFileSize: 30 * 1024 * 1024,
      //   key: "ftCacheKey",
      // ),
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            controlBarColor: Colors.black26,
            iconsColor: Colors.white,
            playIcon: Icons.play_arrow_outlined,
            progressBarPlayedColor: Colors.indigo,
            progressBarHandleColor: Colors.indigo,
            controlBarHeight: 40,
            loadingColor: Colors.red,
            overflowModalColor: Colors.black54,
            overflowModalTextColor: Colors.white,
            overflowMenuIconsColor: Colors.white,
            enableFullscreen: false,
            enableOverflowMenu: false,
            enablePip: false,
            enableProgressText: false,
          ),
          autoPlay: true,
          startAt: Duration(seconds: startPosition),
          autoDetectFullscreenAspectRatio: false,
          aspectRatio: aspectRatio,
          allowedScreenSleep: false,
          expandToFill: false,
          autoDispose: false,
          fit: BoxFit.fitHeight),
      betterPlayerDataSource: betterPlayerDataSource,
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _showNoVideoAvailableToast() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Fluttertoast.showToast(
        msg: S.of(context).noVideoAvailableChangedToHls,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  List<BetterPlayerSubtitlesSource>? _createSubtitles() {
    return widget.subtitles.isNotEmpty
        ? widget.subtitles.map((track) {
            return BetterPlayerSubtitlesSource(
              type: BetterPlayerSubtitlesSourceType.network,
              name: track['name']!,
              urls: [track['url']!],
            );
          }).toList()
        : null;
  }

  void _updateVideoHistory() async {
    final currentPosition =
        _betterPlayerController?.videoPlayerController?.value.position;

    // Check if the current position is available and if the video ID is valid
    if (currentPosition != null && widget.videoId.isNotEmpty) {
      // Create a LocalStoreVideoInfo object with relevant video information
      final videoInfo = LocalStoreVideoInfo(
        id: widget.videoId,
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
        playbackPosition: currentPosition.inSeconds,
      );

      // Add the video information to the SavedBloc
      _savedBloc.add(SavedEvent.addVideoInfo(videoInfo: videoInfo));
    }
  }
}
