/// Generic quality info model for all video services (non-NewPipe)
class GenericQualityInfo {
  final String label;
  final String displayLabel;
  final int resolution;
  final int? fps;
  final String? format;
  final String? url;

  GenericQualityInfo({
    required this.label,
    required this.displayLabel,
    required this.resolution,
    this.fps,
    this.format,
    this.url,
  });

  /// Parse resolution from quality string like "720p" or "1080p60"
  static int parseResolution(String quality) {
    final match = RegExp(r'(\d+)').firstMatch(quality);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  /// Parse FPS from quality string if present
  static int? parseFps(String quality) {
    // Check for formats like "1080p60", "720p 60fps", or "720p30"
    final match =
        RegExp(r'(?:\d+p\s*(\d{2,3}))|(?:(\d+)\s*fps)', caseSensitive: false)
            .firstMatch(quality);
    if (match != null) {
      return int.parse((match.group(1) ?? match.group(2))!);
    }
    return null;
  }

  static GenericQualityInfo? findBestMatchingQuality(
    List<GenericQualityInfo> qualities,
    String preferredQuality,
  ) {
    if (qualities.isEmpty) return null;

    final normalizedPreference = preferredQuality.toLowerCase().trim();
    final exact = qualities
        .where((quality) =>
            quality.label.toLowerCase().trim() == normalizedPreference)
        .firstOrNull;
    if (exact != null) return exact;

    final targetResolution = parseResolution(preferredQuality);
    if (targetResolution <= 0) return qualities.first;

    final targetFps = parseFps(preferredQuality);
    final sorted = List<GenericQualityInfo>.from(qualities);
    sorted.sort((a, b) {
      final resolutionCompare = (a.resolution - targetResolution)
          .abs()
          .compareTo((b.resolution - targetResolution).abs());
      if (resolutionCompare != 0) return resolutionCompare;

      final fpsCompare = _fpsPenalty(a.fps, targetFps)
          .compareTo(_fpsPenalty(b.fps, targetFps));
      if (fpsCompare != 0) return fpsCompare;

      final lowerResolutionCompare = a.resolution.compareTo(b.resolution);
      if (lowerResolutionCompare != 0) return lowerResolutionCompare;

      return _formatPenalty(a.format).compareTo(_formatPenalty(b.format));
    });

    return sorted.first;
  }

  static int _fpsPenalty(int? fps, int? targetFps) {
    final normalizedFps = fps ?? 30;
    if (targetFps != null) return (normalizedFps - targetFps).abs();
    return normalizedFps > 30 ? 1 : 0;
  }

  static int _formatPenalty(String? format) {
    const preferredFormats = ['MP4', 'M4A', 'WEBM'];
    final index = preferredFormats.indexOf(format?.toUpperCase() ?? '');
    return index == -1 ? preferredFormats.length : index;
  }
}
