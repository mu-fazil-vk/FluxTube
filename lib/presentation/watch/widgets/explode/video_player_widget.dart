// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/basic_info.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/generated/l10n.dart';

class ExplodeVideoPlayerWidget extends StatefulWidget {
  const ExplodeVideoPlayerWidget({
    super.key,
    required this.watchInfo,
    required this.availableVideoTracks,
    required this.videoId,
    this.defaultQuality = "720p",
    required this.playbackPosition,
    this.isSaved = false,
    this.liveUrl,
    required this.subtitles,
    this.selectedVideoBasicDetails,
  });

  final ExplodeWatchResp watchInfo;
  final List<MyMuxedStreamInfo> availableVideoTracks;
  final String videoId;
  final String defaultQuality;
  final int playbackPosition;
  final bool isSaved;
  final String? liveUrl;
  final List<Map<String, String>> subtitles;
  final VideoBasicInfo? selectedVideoBasicDetails;

  @override
  State<ExplodeVideoPlayerWidget> createState() => _ExplodeVideoPlayerWidget();
}

class _ExplodeVideoPlayerWidget extends State<ExplodeVideoPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  BetterPlayerController? _betterPlayerController;
  MyMuxedStreamInfo? selectedVideoTrack;
  late final double aspectRatio;
  late final SavedBloc _savedBloc;
  BetterPlayerDataSource? betterPlayerDataSource;

  @override
  void initState() {
    super.initState();

    _savedBloc = BlocProvider.of<SavedBloc>(context);
    aspectRatio = _selectAspectRatio();
    selectedVideoTrack = _selectVideoTrack();
    _setupPlayer(widget.playbackPosition);
  }

  @override
  void dispose() {
    _updateVideoHistory();
    //_betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Ensure that AutomaticKeepAliveClientMixin is correctly applied.
    super.build(context);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: _betterPlayerController != null
          ? BetterPlayer(controller: _betterPlayerController!)
          : const Center(child: CircularProgressIndicator()),
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
          ),
          autoPlay: true,
          startAt: Duration(seconds: startPosition),
          aspectRatio: aspectRatio,
          allowedScreenSleep: false,
          expandToFill: false,
          autoDispose: true,
          fit: BoxFit.contain,
          handleLifecycle: true),
      betterPlayerDataSource: betterPlayerDataSource,
    );
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
        uploaderAvatar: widget.selectedVideoBasicDetails?.channelThumbnailUrl,
        uploaderName: widget.watchInfo.author,
        uploaderId: widget.watchInfo.channelId,
        uploaderSubscriberCount: null,
        duration: widget.watchInfo.duration.inSeconds,
        uploaderVerified:
            widget.selectedVideoBasicDetails?.uploaderVerified ?? false,
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
