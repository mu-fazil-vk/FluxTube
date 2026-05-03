import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_stream.dart';

part 'stream_quality_info.freezed.dart';

/// Represents a quality option available for playback
@freezed
class StreamQualityInfo with _$StreamQualityInfo {
  const factory StreamQualityInfo({
    /// Quality label (e.g., "1080p", "720p 60fps", "360p")
    required String label,

    /// Numeric resolution value (e.g., 1080, 720, 360)
    required int resolution,

    /// Frame rate (null if standard 30fps or less)
    int? fps,

    /// Video format (MP4, WEBM, etc.)
    String? format,

    /// Whether this quality requires stream merging (video-only + audio)
    required bool requiresMerging,

    /// Whether this is a video-only stream (no audio)
    required bool isVideoOnly,

    /// The video stream for this quality
    NewPipeVideoStream? videoStream,

    /// The audio stream (if merging is required)
    NewPipeAudioStream? audioStream,
  }) = _StreamQualityInfo;

  const StreamQualityInfo._();

  /// Get a display label for UI
  String get displayLabel {
    if (isVideoOnly && !requiresMerging) {
      return '$label (no audio)';
    }
    return label;
  }

  /// Compare qualities (for sorting)
  int compareTo(StreamQualityInfo other) {
    // Higher resolution first
    final resolutionCompare = other.resolution.compareTo(resolution);
    if (resolutionCompare != 0) return resolutionCompare;

    // Prefer standard frame rates before high-FPS variants for equivalent
    // resolutions. High-FPS streams are still available, but avoiding them by
    // default keeps decoding cooler on mobile devices.
    final thisFps = fps ?? 30;
    final otherFps = other.fps ?? 30;
    final thisIsHighFps = thisFps > 30;
    final otherIsHighFps = otherFps > 30;
    if (thisIsHighFps != otherIsHighFps) {
      return thisIsHighFps ? 1 : -1;
    }

    return otherFps.compareTo(thisFps);
  }
}
