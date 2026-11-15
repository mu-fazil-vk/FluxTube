class VideoChapter {
  final int startSeconds;
  final String title;

  const VideoChapter({required this.startSeconds, required this.title});

  /// Extracts chapters from a video description.
  ///
  /// Applies the same shape rules YouTube itself requires, so stray timestamps
  /// in prose ("we recorded this at 12:30") do not turn into chapters:
  ///
  ///  * at least [_minChapters] entries,
  ///  * the first one starts at 0,
  ///  * timestamps strictly increase,
  ///  * every timestamp is within [durationSeconds] when that is known.
  ///
  /// Returns an empty list when the description does not satisfy them.
  static List<VideoChapter> parseFromDescription(
    String? description, {
    int? durationSeconds,
  }) {
    if (description == null || description.isEmpty) return [];
    final cleaned = _stripHtml(description);
    final candidates = <VideoChapter>[];
    // Tolerates the common real-world chapter-list prefixes YouTube's own
    // creators use before the timestamp — bullets ("• 0:00"), dashes
    // ("- 0:00"), brackets ("[0:00]"), and numbered lists ("1. 0:00") —
    // not just a bare timestamp at the start of the line.
    final regex = RegExp(
      r'(?:^|\n)\s*(?:[-•*–—]|\(?\d{1,2}[.)])?\s*\[?(\d{1,3}:\d{2}(?::\d{2})?)\]?\s*[-–—:\s]+\s*([^\n]+)',
      multiLine: true,
    );
    for (final match in regex.allMatches(cleaned)) {
      final time = _parseTime(match.group(1) ?? '');
      final title = (match.group(2) ?? '').trim();
      if (time == null || title.isEmpty || title.length >= 200) continue;
      candidates.add(VideoChapter(startSeconds: time, title: title));
    }

    if (candidates.length < _minChapters) return [];
    if (candidates.first.startSeconds != 0) return [];

    for (int i = 1; i < candidates.length; i++) {
      if (candidates[i].startSeconds <= candidates[i - 1].startSeconds) {
        return [];
      }
    }

    if (durationSeconds != null && durationSeconds > 0) {
      if (candidates.last.startSeconds >= durationSeconds) return [];
    }

    return candidates;
  }

  /// YouTube's own threshold — fewer than this and it is not a chapter list.
  static const _minChapters = 3;

  static String _stripHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
  }

  static int? _parseTime(String time) {
    final parts = time.split(':').reversed.toList();
    int seconds = 0;
    try {
      seconds += int.parse(parts[0]);
      if (parts.length > 1) seconds += int.parse(parts[1]) * 60;
      if (parts.length > 2) seconds += int.parse(parts[2]) * 3600;
      return seconds;
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is VideoChapter &&
      other.startSeconds == startSeconds &&
      other.title == title;

  @override
  int get hashCode => Object.hash(startSeconds, title);
}
