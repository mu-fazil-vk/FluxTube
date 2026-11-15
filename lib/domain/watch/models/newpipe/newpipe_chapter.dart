/// A chapter/segment as reported directly by YouTube's own metadata (via
/// NewPipeExtractor's `StreamInfo.getStreamSegments()`) — the real, reliable
/// source, as opposed to the heuristic regex-over-description fallback in
/// [VideoChapter.parseFromDescription] used when a video has no native
/// chapters at all.
///
/// Hand-written `fromJson`/`toJson` rather than `@JsonSerializable()`: this
/// project's `build_runner` currently can't complete a build (the resolved
/// `analyzer` package doesn't support a Dart 3.13 syntax construct used
/// elsewhere in the app, so `freezed`'s AST visitor throws), so codegen
/// isn't available right now. The shape here is simple enough that this
/// isn't a real loss.
class NewPipeChapter {
  final String? title;
  final int? startTimeSeconds;
  final String? previewUrl;

  NewPipeChapter({
    this.title,
    this.startTimeSeconds,
    this.previewUrl,
  });

  factory NewPipeChapter.fromJson(Map<String, dynamic> json) => NewPipeChapter(
        title: json['title'] as String?,
        startTimeSeconds: json['startTimeSeconds'] as int?,
        previewUrl: json['previewUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'startTimeSeconds': startTimeSeconds,
        'previewUrl': previewUrl,
      };
}
