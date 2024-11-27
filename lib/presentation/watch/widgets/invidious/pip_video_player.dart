import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/format_stream.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';

class InvidiousPipVideoPlayerWidget extends StatefulWidget {
  const InvidiousPipVideoPlayerWidget({
    super.key,
    required this.watchInfo,
    required this.videoId,
    required this.playbackPosition,
    this.defaultQuality = "720p",
    this.isSaved = false,
    this.isHlsPlayer = false,
    required this.subtitles,
    required this.watchState,
  });

  final InvidiousWatchResp watchInfo;
  final String videoId;
  final String defaultQuality;
  final int playbackPosition;
  final bool isSaved;
  final bool isHlsPlayer;
  final List<Map<String, String>> subtitles;
  final WatchState watchState;

  @override
  State<InvidiousPipVideoPlayerWidget> createState() =>
      _InvidiousPipVideoPlayerWidgetState();
}

class _InvidiousPipVideoPlayerWidgetState
    extends State<InvidiousPipVideoPlayerWidget> {
  BetterPlayerController? _betterPlayerController;

  FormatStream? selectedVideoTrack;
  late List<FormatStream> availableVideoTracks;
  Map<String, String>? resolutions;

  late final double aspectRatio;
  late SavedBloc _savedBloc;
  List<BetterPlayerSubtitlesSource>? betterPlayerSubtitles;

  BetterPlayerDataSource? betterPlayerDataSource;

  // Track the position of the video player on the screen
  Offset position = const Offset(20, 20);

  WatchBloc? _watchBloc;

  @override
  void initState() {
    super.initState();

    _savedBloc = BlocProvider.of<SavedBloc>(context);

    aspectRatio = selectAspectRatio();

    fetchSubtitles();

    // Filter streams where videoOnly is false
    availableVideoTracks = widget.watchInfo.formatStreams ?? [];

    // Convert availableVideoTracks to a map of resolutions
    resolutions = Map.fromEntries(availableVideoTracks.map((videoStream) {
      return MapEntry(videoStream.qualityLabel ?? S.of(context).unknownQuality,
          videoStream.url ?? '');
    }));

    // Select default video track
    selectVideoTrack();

    _setupPlayer(widget.playbackPosition, controlsConfiguration);

    // Start history update timer
    _updateVideoHistory();
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
      width: 300,
      height: 200,
      child: Stack(children: [
        widget.watchState.fetchInvidiousWatchInfoStatus == ApiStatus.loading
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
            //onPressed: pipClose,
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

  void pipClose() {
    _updateVideoHistory();
    BlocProvider.of<WatchBloc>(context).add(WatchEvent.togglePip(value: false));
    _betterPlayerController?.dispose(forceDispose: true);
  }

  double selectAspectRatio() {
    final firstStream = widget.watchInfo.formatStreams?.firstOrNull;
    if (firstStream != null && firstStream.size != null) {
      return int.parse(firstStream.size!.split('x').first) /
          int.parse(firstStream.size!.split('x').last);
    }
    return 16 / 9; // Default aspect ratio
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
        (video) => video.qualityLabel == widget.defaultQuality,
        orElse: () {
          // Find the closest quality if default is not found
          var closestQuality =
              findClosestQuality(widget.defaultQuality, availableVideoTracks);
          return closestQuality ?? availableVideoTracks[0];
        },
      );
    }
  }

  FormatStream? findClosestQuality(
      String defaultQuality, List<FormatStream> availableVideoTracks) {
    int defaultQualityValue =
        int.tryParse(defaultQuality.replaceAll('p', '')) ?? 0;

    FormatStream? closestTrack;
    int smallestDifference = double.maxFinite.toInt();

    for (var track in availableVideoTracks) {
      int trackQualityValue =
          int.tryParse(track.qualityLabel!.replaceAll('p', '')) ?? 0;
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
        liveStream: widget.watchInfo.liveNow,
        videoFormat: BetterPlayerVideoFormat.other,
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
        BetterPlayerDataSourceType.network,
        widget.watchInfo.dashUrl ?? '',
        useAsmsTracks: true,
        useAsmsAudioTracks: true,
        useAsmsSubtitles: false,
        subtitles: betterPlayerSubtitles,
        liveStream: widget.watchInfo.liveNow,
        videoFormat: BetterPlayerVideoFormat.hls,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 10 * 1024 * 1024, // 10 mb
          maxCacheSize: 30 * 1024 * 1024, // 30 mb
          maxCacheFileSize: 30 * 1024 * 1024,
          key: "ftCacheKey",
        ),
      );
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
        autoDispose: false,
        fit: BoxFit.fitHeight,
      ),
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
          views: widget.watchInfo.viewCount,
          thumbnail: widget.watchInfo.videoThumbnails!.first.url,
          uploadedDate: widget.watchInfo.published.toString(),
          uploaderAvatar: widget.watchInfo.authorThumbnails!.first.url,
          uploaderName: widget.watchInfo.author,
          uploaderId: widget.watchInfo.authorId,
          uploaderSubscriberCount: widget.watchInfo.subCountText,
          duration: widget.watchInfo.lengthSeconds,
          uploaderVerified: widget.watchInfo.authorVerified,
          isHistory: true,
          isLive: widget.watchInfo.liveNow,
          isSaved: widget.isSaved,
          playbackPosition: currentPosition.inSeconds,
        ),
      ));
    }
  }
}
