import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/format_stream.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';

class InvidiousVideoPlayerWidget extends StatefulWidget {
  const InvidiousVideoPlayerWidget({
    super.key,
    required this.watchInfo,
    required this.videoId,
    required this.playbackPosition,
    this.defaultQuality = "720p",
    this.isSaved = false,
    this.isHlsPlayer = false,
    required this.subtitles,
  });

  final InvidiousWatchResp watchInfo;
  final String videoId;
  final String defaultQuality;
  final int playbackPosition;
  final bool isSaved;
  final bool isHlsPlayer;
  final List<Map<String, String>> subtitles;

  @override
  State<InvidiousVideoPlayerWidget> createState() =>
      _InvidiousVideoPlayerWidgetState();
}

class _InvidiousVideoPlayerWidgetState
    extends State<InvidiousVideoPlayerWidget> {
  BetterPlayerController? _betterPlayerController;
  FormatStream? selectedVideoTrack;
  late final List<FormatStream> availableVideoTracks;
  late final double aspectRatio;
  late final SavedBloc _savedBloc;
  BetterPlayerDataSource? betterPlayerDataSource;

  @override
  void initState() {
    super.initState();

    _savedBloc = BlocProvider.of<SavedBloc>(context);
    availableVideoTracks = widget.watchInfo.formatStreams ?? [];
    aspectRatio = _selectAspectRatio();
    selectedVideoTrack = _selectVideoTrack();
    _setupPlayer(widget.playbackPosition);
  }

  @override
  void dispose() {
    _updateVideoHistory();
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: _betterPlayerController != null
          ? BetterPlayer(controller: _betterPlayerController!)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  double _selectAspectRatio() {
    final firstStream = widget.watchInfo.formatStreams?.firstOrNull;
    if (firstStream != null && firstStream.size != null) {
      return int.parse(firstStream.size!.split('x').first) /
          int.parse(firstStream.size!.split('x').last);
    }
    return 16 / 9; // Default aspect ratio
  }

  FormatStream? _selectVideoTrack() {
    // Check if the availableVideoTracks list is empty or is it hls player
    if (availableVideoTracks.isEmpty || widget.isHlsPlayer) {
      return null;
    }

    FormatStream? defaultTrack;
    for (var video in availableVideoTracks) {
      if (video.qualityLabel == widget.defaultQuality) {
        defaultTrack = video;
        break;
      }
    }

    if (defaultTrack == null) {
      // If the default quality is not found, find the closest quality.
      final defaultQualityValue =
          int.tryParse(widget.defaultQuality.replaceAll('p', '')) ?? 0;

      int smallestDifference = double.maxFinite.toInt();
      for (var track in availableVideoTracks) {
        int trackQualityValue = int.tryParse(track.resolution ?? '0') ?? 0;
        int difference = (trackQualityValue - defaultQualityValue).abs();

        if (difference < smallestDifference) {
          smallestDifference = difference;
          defaultTrack = track;
        }
      }
    }

    // Ensure that the return statement is safe
    return defaultTrack ?? availableVideoTracks.first;
  }

  void _setupPlayer(int startPosition) {
    if (selectedVideoTrack == null && !widget.isHlsPlayer) {
      _showNoVideoAvailableToast();
      return;
    }

    betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.isHlsPlayer ? widget.watchInfo.dashUrl! : selectedVideoTrack!.url!,
      subtitles: _createSubtitles(),
      liveStream: widget.watchInfo.liveNow,
      videoFormat: widget.isHlsPlayer
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
      ),
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

    BlocProvider.of<WatchBloc>(context)
        .add(WatchEvent.updatePlayBack(playBack: currentPosition?.inSeconds));

    // Check if the current position is available and if the video ID is valid
    if (currentPosition != null && widget.videoId.isNotEmpty) {
      // Create a LocalStoreVideoInfo object with relevant video information
      final videoInfo = LocalStoreVideoInfo(
        id: widget.videoId,
        title: widget.watchInfo.title,
        views: widget.watchInfo.viewCount,
        thumbnail: widget.watchInfo.videoThumbnails!.first.url,
        uploadedDate: widget.watchInfo.published.toString(),
        uploaderAvatar: widget.watchInfo.authorThumbnails!.first.url,
        uploaderName: widget.watchInfo.author,
        uploaderId: widget.watchInfo.authorId,
        uploaderSubscriberCount: widget.watchInfo.subCountText ?? '0',
        duration: widget.watchInfo.lengthSeconds,
        uploaderVerified: widget.watchInfo.authorVerified,
        isHistory: true,
        isLive: widget.watchInfo.liveNow,
        isSaved: widget.isSaved,
        playbackPosition: currentPosition.inSeconds,
      );

      // Add the video information to the SavedBloc
      _savedBloc.add(SavedEvent.addVideoInfo(videoInfo: videoInfo));
    }
  }
}
