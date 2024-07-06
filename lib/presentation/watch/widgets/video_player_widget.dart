
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluxtube/domain/watch/models/video/subtitle.dart';
import 'package:fluxtube/domain/watch/models/video/video_stream.dart';
import 'package:fluxtube/domain/watch/models/video/watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';

import '../../../application/saved/saved_bloc.dart';
import '../../../domain/saved/models/local_store.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.watchInfo,
    required this.videoId,
    required this.playbackPosition,
    this.defaultQuality = "720p",
    this.isSaved = false,
    this.isHlsPlayer = false,
  });

  final WatchResp watchInfo;
  final String videoId;
  final String defaultQuality;
  final int playbackPosition;
  final bool isSaved;
  final bool isHlsPlayer;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  BetterPlayerController? _betterPlayerController;

  VideoStream? selectedVideoTrack;
  late List<VideoStream> availableVideoTracks;
  Map<String, String>? resolutions;

  late final double aspectRatio;
  late SavedBloc _savedBloc;
  List<BetterPlayerSubtitlesSource>? betterPlayerSubtitles;

  BetterPlayerDataSource? betterPlayerDataSource;

  @override
  void initState() {
    super.initState();

    _savedBloc = BlocProvider.of<SavedBloc>(context);

    aspectRatio = selectAspectRatio();

    fetchSubtitles();

    // Filter streams where videoOnly is false
    availableVideoTracks = widget.watchInfo.videoStreams
        .where((video) => video.videoOnly == false)
        .toList();

    // Convert availableVideoTracks to a map of resolutions
    resolutions = Map.fromEntries(availableVideoTracks.map((videoStream) {
      return MapEntry(videoStream.quality ?? S.of(context).unknownQuality,
          videoStream.url ?? '');
    }));

    // Select default video track
    selectVideoTrack();

    BetterPlayerControlsConfiguration controlsConfiguration =
        const BetterPlayerControlsConfiguration(
      controlBarColor: Colors.black26,
      iconsColor: Colors.white,
      playIcon: Icons.play_arrow_outlined,
      progressBarPlayedColor: Colors.indigo,
      progressBarHandleColor: Colors.indigo,
      skipBackIcon: Icons.replay_10_outlined,
      skipForwardIcon: Icons.forward_10_outlined,
      backwardSkipTimeInMilliseconds: 10000,
      forwardSkipTimeInMilliseconds: 10000,
      enableSkips: true,
      enableFullscreen: true,
      enablePip: true,
      enablePlayPause: true,
      enableMute: true,
      enableAudioTracks: true,
      enableProgressText: true,
      enableSubtitles: true,
      showControlsOnInitialize: true,
      enablePlaybackSpeed: true,
      controlBarHeight: 40,
      loadingColor: Colors.red,
      overflowModalColor: Colors.black54,
      overflowModalTextColor: Colors.white,
      overflowMenuIconsColor: Colors.white,
    );

    _setupPlayer(widget.playbackPosition, controlsConfiguration);

    // Start history update timer
    _updateVideoHistory();
  }

  double selectAspectRatio() {
    if (widget.watchInfo.videoStreams.isNotEmpty) {
      return widget.watchInfo.videoStreams[0].width!.toDouble() < 1
          ? 16 / 9
          : widget.watchInfo.videoStreams.isNotEmpty
              ? widget.watchInfo.videoStreams[0].width!.toDouble() /
                  widget.watchInfo.videoStreams[0].height!.toDouble()
              : 16 / 9;
    } else {
      return 16 / 9;
    }
  }

  void fetchSubtitles() {
    if (widget.watchInfo.subtitles != null &&
        widget.watchInfo.subtitles!.isNotEmpty) {
      betterPlayerSubtitles = convertSubtitles(widget.watchInfo.subtitles!);
    }
  }

  void selectVideoTrack() {
    if (availableVideoTracks.isNotEmpty) {
      // Check if the default quality is available
      selectedVideoTrack = availableVideoTracks.firstWhere(
        (video) => video.quality == widget.defaultQuality,
        orElse: () {
          // Find the closest quality if default is not found
          var closestQuality =
              findClosestQuality(widget.defaultQuality, availableVideoTracks);
          return closestQuality ?? availableVideoTracks[0];
        },
      );
    }
  }

  VideoStream? findClosestQuality(
      String defaultQuality, List<VideoStream> availableVideoTracks) {
    // Assuming available qualities are in the format "360p", "480p", etc.
    int defaultQualityValue =
        int.tryParse(defaultQuality.replaceAll('p', '')) ?? 0;

    VideoStream? closestTrack;
    int smallestDifference = double.maxFinite.toInt();

    for (var track in availableVideoTracks) {
      int trackQualityValue =
          int.tryParse(track.quality!.replaceAll('p', '')) ?? 0;
      int difference = (trackQualityValue - defaultQualityValue).abs();

      if (difference < smallestDifference) {
        smallestDifference = difference;
        closestTrack = track;
      }
    }

    return closestTrack;
  }

  void _setupPlayer(int startPosition, controlsConfiguration) {
    // Dispose of the current player if it exists
    _betterPlayerController?.dispose();

    if (widget.isHlsPlayer != true &&
        selectedVideoTrack != null &&
        selectedVideoTrack?.url != null) {
      betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        selectedVideoTrack!.url ?? '',
        subtitles: betterPlayerSubtitles,
        resolutions: resolutions,
        liveStream: widget.watchInfo.livestream,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 10 * 1024 * 1024, // 10 mb
          maxCacheSize: 30 * 1024 * 1024, // 30 mb
          maxCacheFileSize: 30 * 1024 * 1024,
          key: "ftCacheKey",
        ),
      );
    } else {
      if (!widget.isHlsPlayer) {
        if (context.mounted) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => Fluttertoast.showToast(
                    msg: S.of(context).noVideoAvailableChangedToHls,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  ));
        }
      }

      betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network, widget.watchInfo.hls!,
          useAsmsTracks: true,
          useAsmsAudioTracks: true,
          useAsmsSubtitles: true,
          liveStream: widget.watchInfo.livestream,
          videoFormat: BetterPlayerVideoFormat.hls,
          cacheConfiguration: const BetterPlayerCacheConfiguration(
            useCache: true,
            preCacheSize: 10 * 1024 * 1024, // 10 mb
            maxCacheSize: 30 * 1024 * 1024, // 30 mb
            maxCacheFileSize: 30 * 1024 * 1024,
            key: "ftCacheKey",
          ));
    }

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
          controlsConfiguration: controlsConfiguration,
          autoPlay: true,
          startAt: Duration(seconds: startPosition),
          autoDetectFullscreenAspectRatio: false,
          aspectRatio: aspectRatio,
          allowedScreenSleep: false,
          expandToFill: false,
          autoDispose: true,
          fit: BoxFit.contain),
      betterPlayerDataSource: betterPlayerDataSource,
    );

    // Ensure the controller is set in state
    setState(() {});
  }

  @override
  void dispose() {
    _updateVideoHistory();
    _betterPlayerController?.dispose();
    super.dispose();
  }

  //subtitle to betterplayer subtitle list
  List<BetterPlayerSubtitlesSource> convertSubtitles(List<Subtitle> subtitles) {
    return subtitles.map((subtitle) {
      return BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.network,
        name: subtitle.name ?? "Unknown",
        urls: [subtitle.url ?? ""],
      );
    }).toList();
  }

  void _updateVideoHistory() async {
    final currentPosition =
        _betterPlayerController?.videoPlayerController?.value.position;
    if (currentPosition != null) {
      _savedBloc.add(SavedEvent.addVideoInfo(
        videoInfo: LocalStoreVideoInfo(
          id: widget.videoId,
          title: widget.watchInfo.title,
          views: widget.watchInfo.views,
          thumbnail: widget.watchInfo.thumbnailUrl,
          uploadedDate: widget.watchInfo.uploadDate,
          uploaderAvatar: widget.watchInfo.uploaderAvatar,
          uploaderName: widget.watchInfo.uploader,
          uploaderId: widget.watchInfo.uploaderUrl!.split("/").last,
          uploaderSubscriberCount: widget.watchInfo.uploaderSubscriberCount,
          duration: widget.watchInfo.duration,
          uploaderVerified: widget.watchInfo.uploaderVerified,
          isHistory: true,
          isLive: widget.watchInfo.livestream,
          isSaved: widget.isSaved,
          playbackPosition:
              currentPosition.inSeconds, // Save the current playback position
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: _betterPlayerController != null
          ? BetterPlayer(
              controller: _betterPlayerController!,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
