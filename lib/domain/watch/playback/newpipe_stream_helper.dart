import 'package:fluxtube/domain/watch/models/newpipe/newpipe_stream.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/domain/watch/playback/models/stream_quality_info.dart';

/// Stream selection and sorting utilities (mimics NewPipe's ListHelper.java)
class NewPipeStreamHelper {
  /// Format preferences (best to worst)
  static const List<String> _preferredVideoFormats = ['MP4', 'WEBM', 'M4A'];
  static const List<String> _preferredAudioFormats = ['M4A', 'OPUS', 'WEBM'];

  /// Check if a quality requires stream merging (video-only + audio)
  static bool requiresMerging(String qualityLabel) {
    // Extract resolution number
    final resolution =
        int.tryParse(qualityLabel.replaceAll(RegExp(r'[^\d]'), ''));
    if (resolution == null) return false;

    // YouTube muxed streams are only available up to 360p
    return resolution > 360;
  }

  /// Get all available qualities from watch response
  static List<StreamQualityInfo> getAvailableQualities(
      NewPipeWatchResp watchResp) {
    final qualities = <StreamQualityInfo>[];
    final seenLabels = <String>{};

    // Process video-only streams FIRST (videoOnlyStreams - need audio, >360p)
    // These are higher quality and should be preferred
    final bestAudio = getBestAudioStream(watchResp.audioStreams ?? []);

    for (var videoStream
        in sortVideoStreams(watchResp.videoOnlyStreams ?? [])) {
      if (videoStream.url == null || videoStream.url!.isEmpty) continue;

      final resolution = _parseResolution(videoStream.resolution);
      if (resolution == null) continue;

      final label = _getQualityLabel(videoStream);

      // Skip if we already have this quality label
      if (seenLabels.contains(label)) continue;
      seenLabels.add(label);

      qualities.add(StreamQualityInfo(
        label: label,
        resolution: resolution,
        fps: videoStream.fps,
        format: videoStream.format,
        requiresMerging: true, // Video-only needs audio
        isVideoOnly: videoStream.isVideoOnly ?? true,
        videoStream: videoStream,
        audioStream: bestAudio,
      ));
    }

    // Process muxed streams (videoStreams - have audio, ≤360p)
    for (var videoStream in sortVideoStreams(watchResp.videoStreams ?? [])) {
      if (videoStream.url == null || videoStream.url!.isEmpty) continue;

      final resolution = _parseResolution(videoStream.resolution);
      if (resolution == null) continue;

      final label = _getQualityLabel(videoStream);

      // Skip if we already have this quality label (prefer video-only + audio)
      if (seenLabels.contains(label)) continue;
      seenLabels.add(label);

      qualities.add(StreamQualityInfo(
        label: label,
        resolution: resolution,
        fps: videoStream.fps,
        format: videoStream.format,
        requiresMerging: false, // Muxed streams already have audio
        isVideoOnly: false,
        videoStream: videoStream,
        audioStream: null,
      ));
    }

    // Sort by resolution (highest first), then fps (highest first)
    qualities.sort((a, b) => a.compareTo(b));

    return qualities;
  }

  /// Get quality label for video stream (e.g., "1080p", "720p 60fps")
  static String _getQualityLabel(NewPipeVideoStream stream) {
    String label = stream.resolution ?? 'Unknown';

    // Add fps if higher than 30
    if (stream.fps != null && stream.fps! > 30) {
      label += ' ${stream.fps}fps';
    }

    return label;
  }

  /// Parse resolution from string (e.g., "1080p" -> 1080)
  static int? _parseResolution(String? resolution) {
    if (resolution == null) return null;
    return int.tryParse(resolution.replaceAll(RegExp(r'[^\d]'), ''));
  }

  /// Sort video streams by quality (NewPipe's algorithm)
  static List<NewPipeVideoStream> sortVideoStreams(
    List<NewPipeVideoStream> streams, {
    List<String> preferredFormats = _preferredVideoFormats,
  }) {
    final sorted = List<NewPipeVideoStream>.from(streams);

    sorted.sort((a, b) {
      // 1. Resolution (higher first)
      final aRes = _parseResolution(a.resolution) ?? 0;
      final bRes = _parseResolution(b.resolution) ?? 0;
      if (aRes != bRes) return bRes.compareTo(aRes);

      // 2. FPS preference. Prefer standard frame rate before high-FPS for
      // equivalent resolutions to reduce decoder load & heat by default.
      final aFps = a.fps ?? 0;
      final bFps = b.fps ?? 0;
      final aIsHighFps = aFps > 30;
      final bIsHighFps = bFps > 30;
      if (aIsHighFps != bIsHighFps) {
        return aIsHighFps ? 1 : -1;
      }
      if (aFps != bFps) return bFps.compareTo(aFps);

      // 3. Format preference
      final aFormatIndex =
          preferredFormats.indexOf(a.format?.toUpperCase() ?? '');
      final bFormatIndex =
          preferredFormats.indexOf(b.format?.toUpperCase() ?? '');

      // If both are in preferred list, compare indices (lower index = more preferred)
      if (aFormatIndex >= 0 && bFormatIndex >= 0) {
        return aFormatIndex.compareTo(bFormatIndex);
      }

      // Preferred format wins over non-preferred
      if (aFormatIndex >= 0) return -1;
      if (bFormatIndex >= 0) return 1;

      // 4. Bitrate (higher first)
      final aBitrate = a.bitrate ?? 0;
      final bBitrate = b.bitrate ?? 0;
      return bBitrate.compareTo(aBitrate);
    });

    return sorted;
  }

  /// Sort audio streams by quality (NewPipe's algorithm)
  static List<NewPipeAudioStream> sortAudioStreams(
    List<NewPipeAudioStream> streams, {
    List<String> preferredFormats = _preferredAudioFormats,
  }) {
    final sorted = List<NewPipeAudioStream>.from(streams);

    sorted.sort((a, b) {
      // 1. Format preference. On Android, a hardware-friendly container/codec
      // is usually more important than a slightly higher bitrate.
      final aFormatIndex =
          preferredFormats.indexOf(a.format?.toUpperCase() ?? '');
      final bFormatIndex =
          preferredFormats.indexOf(b.format?.toUpperCase() ?? '');

      if (aFormatIndex >= 0 && bFormatIndex >= 0) {
        return aFormatIndex.compareTo(bFormatIndex);
      }

      if (aFormatIndex >= 0) return -1;
      if (bFormatIndex >= 0) return 1;

      // 2. Average bitrate (higher first)
      final aBitrate = a.averageBitrate ?? 0;
      final bBitrate = b.averageBitrate ?? 0;
      if (aBitrate != bBitrate) return bBitrate.compareTo(aBitrate);

      // 3. Audio channels (more first)
      final aChannels = a.audioChannels ?? 0;
      final bChannels = b.audioChannels ?? 0;
      if (aChannels != bChannels) return bChannels.compareTo(aChannels);

      // 4. Sample rate (higher first)
      final aSampleRate = a.sampleRate ?? 0;
      final bSampleRate = b.sampleRate ?? 0;
      return bSampleRate.compareTo(aSampleRate);
    });

    return sorted;
  }

  /// Get best video stream for target quality
  static NewPipeVideoStream? getBestVideoStream(
    List<NewPipeVideoStream> streams,
    String targetQuality, {
    bool allowVideoOnly = true,
  }) {
    if (streams.isEmpty) return null;

    // Filter by video-only preference
    var filtered = streams
        .where((s) =>
            s.url != null &&
            s.url!.isNotEmpty &&
            (allowVideoOnly || s.isVideoOnly != true))
        .toList();

    if (filtered.isEmpty) return null;

    // Sort streams
    final sorted = sortVideoStreams(filtered);

    // Extract target resolution
    final targetRes = _parseResolution(targetQuality) ?? 720;

    // Try to find exact match first
    for (var stream in sorted) {
      final streamRes = _parseResolution(stream.resolution) ?? 0;
      if (streamRes == targetRes) return stream;
    }

    // Find closest match
    NewPipeVideoStream? closest = sorted.first;
    int smallestDiff = double.maxFinite.toInt();

    for (var stream in sorted) {
      final streamRes = _parseResolution(stream.resolution) ?? 0;
      final diff = (streamRes - targetRes).abs();

      if (diff < smallestDiff) {
        smallestDiff = diff;
        closest = stream;
      }
    }

    return closest;
  }

  /// Get best audio stream (highest quality with best format)
  static NewPipeAudioStream? getBestAudioStream(
    List<NewPipeAudioStream> streams,
  ) {
    if (streams.isEmpty) return null;

    // Filter valid streams
    final filtered =
        streams.where((s) => s.url != null && s.url!.isNotEmpty).toList();

    if (filtered.isEmpty) return null;

    // Sort and return best
    final sorted = sortAudioStreams(filtered);
    return sorted.first;
  }

  /// Get video stream from quality info
  static NewPipeVideoStream? getVideoStreamForQuality(
    NewPipeWatchResp watchResp,
    String qualityLabel,
  ) {
    // Check if quality requires merging (>360p)
    if (requiresMerging(qualityLabel)) {
      // Look in video-only streams
      final sorted = sortVideoStreams(watchResp.videoOnlyStreams ?? []);
      return getBestVideoStream(sorted, qualityLabel, allowVideoOnly: true);
    } else {
      // Look in muxed streams
      final sorted = sortVideoStreams(watchResp.videoStreams ?? []);
      return getBestVideoStream(sorted, qualityLabel, allowVideoOnly: false);
    }
  }

  /// Get maximum available quality
  static String? getMaxAvailableQuality(NewPipeWatchResp watchResp) {
    final qualities = getAvailableQualities(watchResp);
    if (qualities.isEmpty) return null;
    return qualities.first.label;
  }

  /// Get available audio tracks grouped by track ID/locale
  /// Returns a list of AudioTrackInfo representing distinct audio tracks
  static List<AudioTrackInfo> getAvailableAudioTracks(
    List<NewPipeAudioStream> audioStreams,
  ) {
    if (audioStreams.isEmpty) return [];

    final trackMap = <String, List<NewPipeAudioStream>>{};

    // Group streams by audio track identifier
    for (var stream in audioStreams) {
      if (stream.url == null || stream.url!.isEmpty) continue;

      // Use audioTrackId if available, otherwise fall back to locale or 'default'
      final trackId = stream.audioTrackId ??
          stream.audioLocale ??
          (stream.isOriginal ? 'original' : 'default');

      trackMap.putIfAbsent(trackId, () => []).add(stream);
    }

    // Convert to AudioTrackInfo list
    final tracks = <AudioTrackInfo>[];

    for (var entry in trackMap.entries) {
      final streams = entry.value;
      if (streams.isEmpty) continue;

      // Use the first stream for metadata (all streams in group share same track info)
      final representative = streams.first;

      // Determine display name
      String displayName;
      if (representative.audioTrackName != null &&
          representative.audioTrackName!.isNotEmpty) {
        displayName = representative.audioTrackName!;
      } else if (representative.audioLocale != null) {
        displayName = _getLanguageDisplayName(representative.audioLocale!);
      } else if (representative.isOriginal) {
        displayName = 'Original';
      } else {
        displayName = 'Default';
      }

      // Add type suffix if dubbed or descriptive
      if (representative.isDubbed) {
        displayName += ' (Dubbed)';
      } else if (representative.isDescriptive) {
        displayName += ' (Descriptive)';
      }

      tracks.add(AudioTrackInfo(
        trackId: entry.key,
        displayName: displayName,
        locale: representative.audioLocale,
        isOriginal: representative.isOriginal,
        isDubbed: representative.isDubbed,
        isDescriptive: representative.isDescriptive,
        streams: sortAudioStreams(streams),
      ));
    }

    // Sort: Original first (not dubbed), then non-dubbed, then dubbed, then alphabetically
    // When metadata is missing, non-dubbed is preferred over unknown
    tracks.sort((a, b) {
      // Dubbed tracks go last
      if (a.isDubbed && !b.isDubbed) return 1;
      if (!a.isDubbed && b.isDubbed) return -1;

      // Descriptive tracks go after dubbed
      if (a.isDescriptive && !b.isDescriptive) return 1;
      if (!a.isDescriptive && b.isDescriptive) return -1;

      // Explicitly marked Original tracks come first
      if (a.isOriginal && !b.isOriginal) return -1;
      if (!a.isOriginal && b.isOriginal) return 1;

      // Then alphabetically by display name
      return a.displayName.compareTo(b.displayName);
    });

    return tracks;
  }

  /// Get best audio stream from a specific track (around 128kbps target)
  static NewPipeAudioStream? getBestStreamForTrack(
    AudioTrackInfo track, {
    int targetBitrate = 128,
  }) {
    if (track.streams.isEmpty) return null;

    // Find stream closest to target bitrate
    NewPipeAudioStream? best = track.streams.first;
    int smallestDiff = double.maxFinite.toInt();

    for (var stream in track.streams) {
      final bitrate = stream.averageBitrate ?? 0;
      final diff = (bitrate - targetBitrate).abs();

      if (diff < smallestDiff) {
        smallestDiff = diff;
        best = stream;
      }
    }

    return best;
  }

  /// Convert locale code to display name
  static String _getLanguageDisplayName(String locale) {
    // Common language codes
    const languageNames = {
      'en': 'English',
      'en-US': 'English (US)',
      'en-GB': 'English (UK)',
      'es': 'Spanish',
      'es-ES': 'Spanish (Spain)',
      'es-MX': 'Spanish (Mexico)',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'pt-BR': 'Portuguese (Brazil)',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
      'zh-CN': 'Chinese (Simplified)',
      'zh-TW': 'Chinese (Traditional)',
      'hi': 'Hindi',
      'ar': 'Arabic',
      'tr': 'Turkish',
      'pl': 'Polish',
      'nl': 'Dutch',
      'sv': 'Swedish',
      'th': 'Thai',
      'vi': 'Vietnamese',
      'id': 'Indonesian',
      'ml': 'Malayalam',
      'ta': 'Tamil',
      'te': 'Telugu',
    };

    return languageNames[locale] ?? locale.toUpperCase();
  }
}

/// Represents a distinct audio track with its available streams
class AudioTrackInfo {
  final String trackId;
  final String displayName;
  final String? locale;
  final bool isOriginal;
  final bool isDubbed;
  final bool isDescriptive;
  final List<NewPipeAudioStream> streams;

  const AudioTrackInfo({
    required this.trackId,
    required this.displayName,
    this.locale,
    this.isOriginal = false,
    this.isDubbed = false,
    this.isDescriptive = false,
    required this.streams,
  });

  /// Get best quality stream for this track (targets ~128kbps)
  NewPipeAudioStream? get bestStream =>
      NewPipeStreamHelper.getBestStreamForTrack(this);
}
