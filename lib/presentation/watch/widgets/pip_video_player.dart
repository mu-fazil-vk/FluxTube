import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/domain/watch/models/video/video_stream.dart';
import 'package:fluxtube/domain/watch/models/video/watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';

import '../../../domain/saved/models/local_store.dart';

class PipVideoPlayerWidget extends StatefulWidget {
  const PipVideoPlayerWidget({
    super.key,
    required this.watchInfo,
    required this.videoId,
    required this.playbackPosition,
    this.defaultQuality = "720p",
    this.isSaved = false,
    this.isHlsPlayer = false,
    required this.subtitles,
  });

  final WatchResp watchInfo;
  final String videoId;
  final String defaultQuality;
  final int playbackPosition;
  final bool isSaved;
  final bool isHlsPlayer;
  final List<Map<String, String>> subtitles;

  @override
  State<PipVideoPlayerWidget> createState() => _PipVideoPlayerWidgetState();
}

class _PipVideoPlayerWidgetState extends State<PipVideoPlayerWidget> {
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

    _setupPlayer(widget.playbackPosition, controlsConfiguration);

    // Start history update timer
    _updateVideoHistory();
  }

  @override
  void dispose() {
    _updateVideoHistory();
    BlocProvider.of<WatchBloc>(context).add(WatchEvent.togglePip(value: false));
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 8,
          child: _betterPlayerController != null
              ? BetterPlayer(
                  controller: _betterPlayerController!,
                  //key: UniqueKey()
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
              onPressed: () {
                _updateVideoHistory();
                PictureInPicture.stopPiP();
                BlocProvider.of<WatchBloc>(context)
                    .add(WatchEvent.togglePip(value: false));
              },
              icon: const Icon(CupertinoIcons.xmark)),
        )
      ],
    );
  }

  BetterPlayerControlsConfiguration controlsConfiguration =
        const BetterPlayerControlsConfiguration(
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
    );


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
    if (widget.subtitles.isNotEmpty) {
      betterPlayerSubtitles = widget.subtitles.map((track) {
        return BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.network,
          name: track['name'].toString(),
          urls: [track['url'].toString()],
        );
      }).toList();
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
          BetterPlayerDataSourceType.network, selectedVideoTrack!.url ?? '',
          subtitles: betterPlayerSubtitles,
          resolutions: resolutions,
          liveStream: widget.watchInfo.livestream,
          videoFormat: BetterPlayerVideoFormat.other,
          cacheConfiguration: const BetterPlayerCacheConfiguration(
            useCache: false,
            preCacheSize: 10 * 1024 * 1024, // 10 mb
            maxCacheSize: 30 * 1024 * 1024, // 30 mb
            maxCacheFileSize: 30 * 1024 * 1024,
            key: "ftCacheKey",
          ),
          videoExtension: selectedVideoTrack?.format ?? 'mp4');
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
          useAsmsSubtitles: false,
          subtitles: betterPlayerSubtitles,
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
          fit: BoxFit.fitHeight),
      betterPlayerDataSource: betterPlayerDataSource,
    );

    // Ensure the controller is set in state
    setState(() {});
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
}
