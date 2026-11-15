/// A newer release fetched from GitHub, ready to be shown in the
/// update-available dialog. Hand-written rather than JSON-serializable
/// codegen — the shape only ever comes from one place ([UpdateChecker]) and
/// this project's `build_runner` currently can't complete a build (see
/// `newpipe_chapter.dart`'s doc comment for why).
class UpdateInfo {
  final String version;
  final String releaseName;
  final String changelog;
  final String htmlUrl;

  const UpdateInfo({
    required this.version,
    required this.releaseName,
    required this.changelog,
    required this.htmlUrl,
  });

  factory UpdateInfo.fromGitHubRelease(Map<String, dynamic> json) {
    final tag = (json['tag_name'] as String?) ?? '';
    return UpdateInfo(
      version: tag.startsWith('v') ? tag.substring(1) : tag,
      releaseName: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : tag,
      changelog: (json['body'] as String?)?.trim() ?? '',
      htmlUrl: (json['html_url'] as String?) ?? '',
    );
  }
}
