import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/models/playback_configuration.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_stream_helper.dart';

/// Playback resolver that decides which media source strategy to use
/// (mimics NewPipe's VideoPlaybackResolver.java)
class NewPipePlaybackResolver {
  /// Resolve playback configuration from watch response
  /// Returns the best playback configuration for the given parameters
  PlaybackConfiguration resolve({
    required NewPipeWatchResp watchResp,
    required String preferredQuality,
    bool preferHighQuality = true,
    bool preferAdaptive = false,
  }) {
    // Priority: Live streams -> optionally adaptive -> selected quality ->
    // adaptive fallback -> progressive fallback.

    // 1. Check for live stream - use HLS/DASH
    if (watchResp.isLive == true) {
      return _resolveLiveStream(watchResp);
    }

    // 2. Battery-friendly mode: prefer one adaptive media source over merging
    // separate video/audio streams. This usually reduces decoder/sync/network
    // overhead on phones.
    if (preferAdaptive) {
      final adaptiveConfig = _resolveAdaptiveStream(watchResp);
      if (adaptiveConfig?.isValid == true) {
        return adaptiveConfig!;
      }
    }

    // 3. Try to get the preferred quality via merging or progressive
    final qualityInfo = NewPipeStreamHelper.getAvailableQualities(watchResp)
        .where((q) => q.label == preferredQuality)
        .firstOrNull;

    if (qualityInfo != null) {
      if (qualityInfo.requiresMerging) {
        // High-quality stream (>360p) - needs merging
        return _resolveMergingStream(
          videoStream: qualityInfo.videoStream!,
          audioStream: qualityInfo.audioStream!,
          qualityLabel: qualityInfo.label,
          subtitles: watchResp.subtitles ?? [],
        );
      } else {
        // Muxed stream (≤360p)
        return _resolveProgressiveStream(
          videoStream: qualityInfo.videoStream!,
          qualityLabel: qualityInfo.label,
          subtitles: watchResp.subtitles ?? [],
        );
      }
    }

    // 4. Preferred quality not available - find closest alternative from merging/progressive
    if (preferHighQuality) {
      final availableQualities =
          NewPipeStreamHelper.getAvailableQualities(watchResp);
      if (availableQualities.isNotEmpty) {
        final bestQuality = availableQualities.first;
        if (bestQuality.requiresMerging) {
          return _resolveMergingStream(
            videoStream: bestQuality.videoStream!,
            audioStream: bestQuality.audioStream!,
            qualityLabel: bestQuality.label,
            subtitles: watchResp.subtitles ?? [],
          );
        } else {
          return _resolveProgressiveStream(
            videoStream: bestQuality.videoStream!,
            qualityLabel: bestQuality.label,
            subtitles: watchResp.subtitles ?? [],
          );
        }
      }
    }

    // 5. Fallback to adaptive playback.
    final adaptiveConfig = _resolveAdaptiveStream(watchResp);
    if (adaptiveConfig?.isValid == true) {
      return adaptiveConfig!;
    }

    // 6. Last resort - any muxed/progressive stream
    final videoStreams = watchResp.videoStreams ?? [];
    if (videoStreams.isNotEmpty) {
      final sorted = NewPipeStreamHelper.sortVideoStreams(videoStreams);
      final firstValid =
          sorted.where((s) => s.url != null && s.url!.isNotEmpty).firstOrNull;
      if (firstValid != null) {
        return _resolveProgressiveStream(
          videoStream: firstValid,
          qualityLabel: firstValid.resolution ?? 'Unknown',
          subtitles: watchResp.subtitles ?? [],
        );
      }
    }

    // No valid stream found - return invalid config
    return const PlaybackConfiguration(
      sourceType: MediaSourceType.progressive,
      qualityLabel: 'Unknown',
    );
  }

  PlaybackConfiguration? _resolveAdaptiveStream(NewPipeWatchResp watchResp) {
    if (watchResp.dashMpdUrl != null && watchResp.dashMpdUrl!.isNotEmpty) {
      return _resolveDashStream(
          watchResp.dashMpdUrl!, watchResp.subtitles ?? []);
    }

    if (watchResp.hlsUrl != null && watchResp.hlsUrl!.isNotEmpty) {
      return _resolveHlsStream(watchResp.hlsUrl!, watchResp.subtitles ?? []);
    }

    return null;
  }

  /// Resolve live stream (HLS)
  PlaybackConfiguration _resolveLiveStream(NewPipeWatchResp watchResp) {
    final hlsUrl = watchResp.hlsUrl;

    if (hlsUrl != null && hlsUrl.isNotEmpty) {
      return PlaybackConfiguration(
        sourceType: MediaSourceType.hls,
        qualityLabel: 'Live',
        manifestUrl: hlsUrl,
        subtitles: watchResp.subtitles ?? [],
        isLive: true,
      );
    }

    // Fallback to DASH for live if HLS not available
    final dashUrl = watchResp.dashMpdUrl;
    if (dashUrl != null && dashUrl.isNotEmpty) {
      return PlaybackConfiguration(
        sourceType: MediaSourceType.dash,
        qualityLabel: 'Live',
        manifestUrl: dashUrl,
        subtitles: watchResp.subtitles ?? [],
        isLive: true,
      );
    }

    return const PlaybackConfiguration(
      sourceType: MediaSourceType.hls,
      qualityLabel: 'Live',
      isLive: true,
    );
  }

  /// Resolve progressive stream (muxed video+audio, ≤360p)
  PlaybackConfiguration _resolveProgressiveStream({
    required dynamic videoStream,
    required String qualityLabel,
    required List<dynamic> subtitles,
  }) {
    return PlaybackConfiguration(
      sourceType: MediaSourceType.progressive,
      qualityLabel: qualityLabel,
      videoUrl: videoStream.url,
      subtitles: subtitles.cast(),
      isLive: false,
    );
  }

  /// Resolve merging stream (video-only + audio, >360p)
  PlaybackConfiguration _resolveMergingStream({
    required dynamic videoStream,
    required dynamic audioStream,
    required String qualityLabel,
    required List<dynamic> subtitles,
  }) {
    return PlaybackConfiguration(
      sourceType: MediaSourceType.merging,
      qualityLabel: qualityLabel,
      videoUrl: videoStream.url,
      audioUrl: audioStream.url,
      subtitles: subtitles.cast(),
      isLive: false,
    );
  }

  /// Resolve DASH stream
  PlaybackConfiguration _resolveDashStream(String dashUrl, List subtitles) {
    return PlaybackConfiguration(
      sourceType: MediaSourceType.dash,
      qualityLabel: 'Auto',
      manifestUrl: dashUrl,
      subtitles: subtitles.cast(),
      isLive: false,
    );
  }

  /// Resolve HLS stream
  PlaybackConfiguration _resolveHlsStream(String hlsUrl, List subtitles) {
    return PlaybackConfiguration(
      sourceType: MediaSourceType.hls,
      qualityLabel: 'Auto',
      manifestUrl: hlsUrl,
      subtitles: subtitles.cast(),
      isLive: false,
    );
  }

  /// Check if stream merging is needed for target quality
  bool needsStreamMerging(NewPipeWatchResp watchResp, String targetQuality) {
    return NewPipeStreamHelper.requiresMerging(targetQuality);
  }

  /// Get maximum available quality
  String? getMaxAvailableQuality(NewPipeWatchResp watchResp) {
    return NewPipeStreamHelper.getMaxAvailableQuality(watchResp);
  }

  /// Get all available qualities
  List<String> getAvailableQualityLabels(NewPipeWatchResp watchResp) {
    return NewPipeStreamHelper.getAvailableQualities(watchResp)
        .map((q) => q.label)
        .toList();
  }
}
