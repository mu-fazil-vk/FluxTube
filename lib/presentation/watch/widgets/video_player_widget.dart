import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluxtube/domain/watch/models/video/video_stream.dart';
import 'package:fluxtube/domain/watch/models/video/watch_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:river_player/river_player.dart';

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
  late Timer _historyUpdateTimer;

  VideoStream? selectedVideoTrack;
  late List<VideoStream> availableVideoTracks;
  Map<String, String>? resolutions;

  late final double aspectRatio;

  BetterPlayerDataSource? betterPlayerDataSource;

  @override
  void initState() {
    super.initState();

    aspectRatio = widget.watchInfo.videoStreams[0].width!.toDouble() < 1
        ? 16 / 9
        : widget.watchInfo.videoStreams.isNotEmpty
            ? widget.watchInfo.videoStreams[0].width!.toDouble() /
                widget.watchInfo.videoStreams[0].height!.toDouble()
            : 16 / 9;

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

    _setupPlayer(widget.playbackPosition);

    // Start history update timer
    _startHistoryUpdateTimer();
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

  void _setupPlayer(int startPosition) {
    // Dispose of the current player if it exists
    _betterPlayerController?.dispose();

    if (widget.isHlsPlayer != true &&
        selectedVideoTrack != null &&
        selectedVideoTrack?.url != null) {
      betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        selectedVideoTrack!.url ?? '',
        useAsmsSubtitles: true,
        resolutions: resolutions,
        liveStream: widget.watchInfo.livestream,
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
        widget.watchInfo.hls!,
        useAsmsSubtitles: true,
        useAsmsTracks: true,
        useAsmsAudioTracks: true,
        liveStream: widget.watchInfo.livestream,
      );
    }

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        startAt: Duration(seconds: startPosition),
        autoDetectFullscreenAspectRatio: false,
        aspectRatio: aspectRatio,
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );

    // Ensure the controller is set in state
    setState(() {});
  }

  @override
  void dispose() {
    _historyUpdateTimer.cancel();
    _betterPlayerController?.dispose();
    super.dispose();
  }

  // Update history every 30 seconds
  void _startHistoryUpdateTimer() {
    _historyUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateVideoHistory();
    });
  }

  void _updateVideoHistory() {
    final currentPosition =
        _betterPlayerController?.videoPlayerController?.value.position;
    if (currentPosition != null) {
      BlocProvider.of<SavedBloc>(context).add(SavedEvent.addVideoInfo(
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
