import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/adaptive_format.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/caption.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/format_stream.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_chapter.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_stream.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_subtitle.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/domain/watch/models/piped/video/audio_stream.dart';
import 'package:fluxtube/domain/watch/models/piped/video/subtitle.dart';
import 'package:fluxtube/domain/watch/models/piped/video/video_stream.dart';
import 'package:fluxtube/domain/watch/models/piped/video/watch_resp.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Converts Piped / Invidious / youtube_explode watch data into a
/// [NewPipeWatchResp] so those backends can play through the native
/// ExoPlayer path (`NewPipePlaybackResolver` + `NewPipeStreamHelper`).
///
/// Stream URLs are passed through untouched: Piped/Invidious users rely on
/// the instance's proxying, so nothing here is re-extracted via NewPipe.
///
/// Unit conventions expected by `NewPipeStreamHelper`:
/// - `NewPipeAudioStream.averageBitrate` is kbps (track selection targets
///   ~128), `bitrate` is bps.
/// - `resolution` is "{height}p"; fps lives in `fps` so labels read
///   "1080p 60fps".
///
/// `extraSubtitles` takes the `{code, name, url}` maps the watch screens
/// already fetch via youtube_explode (`WatchState.subtitles`, VTT). Those
/// URLs point at youtube.com directly, so for Piped/Invidious the backend's
/// own (proxied) captions win and the extras are only a fallback.
NewPipeWatchResp newPipeRespFromPiped(
  WatchResp resp, {
  required String videoId,
  List<Map<String, String>> extraSubtitles = const [],
}) {
  final videos = resp.videoStreams.map(_pipedVideo).toList();
  final pipedSubtitles = (resp.subtitles ?? []).map(_pipedSubtitle).toList();

  return NewPipeWatchResp(
    id: videoId,
    title: resp.title,
    description: resp.description,
    uploaderName: resp.uploader,
    uploaderUrl: resp.uploaderUrl,
    uploaderAvatarUrl: _httpUrl(resp.uploaderAvatar),
    uploaderVerified: resp.uploaderVerified,
    uploaderSubscriberCount: resp.uploaderSubscriberCount,
    thumbnailUrl: _httpUrl(resp.thumbnailUrl),
    duration: resp.duration,
    viewCount: resp.views,
    likeCount: resp.likes,
    dislikeCount: resp.dislikes,
    uploadDate: resp.uploadDate,
    category: resp.category,
    tags: resp.tags,
    isLive: resp.livestream == true,
    // The Piped model defaults `hls` to a "fetching..." placeholder.
    hlsUrl: _httpUrl(resp.hls),
    dashMpdUrl: resp.dash is String ? _httpUrl(resp.dash as String) : null,
    videoStreams: videos.where((v) => v.isVideoOnly != true).toList(),
    videoOnlyStreams: videos.where((v) => v.isVideoOnly == true).toList(),
    audioStreams: (resp.audioStreams ?? []).map(_pipedAudio).toList(),
    chapters: _pipedChapters(resp.chapters),
    subtitles: _dedupeSubtitles(
      pipedSubtitles.isNotEmpty
          ? pipedSubtitles
          : _explodeSubtitles(extraSubtitles),
    ),
  );
}

/// [instanceBaseUrl] resolves the relative URLs Invidious returns (captions
/// always, thumbnails/dashUrl on some instances). Pass
/// `BaseUrl.kInvidiousBaseUrl`.
///
/// Not mappable from the current [InvidiousWatchResp] model:
/// - `hlsUrl` (live HLS) is not parsed, so live falls back to `dashUrl`,
///   same as the media_kit player did.
/// - per-stream `audioTrack` info is not parsed; dubbed tracks are only
///   distinguished via the googlevideo `xtags` URL parameter.
/// - `subCountText` is a localized string ("1.2M"), so no subscriber count.
NewPipeWatchResp newPipeRespFromInvidious(
  InvidiousWatchResp resp, {
  required String videoId,
  String? instanceBaseUrl,
  List<Map<String, String>> extraSubtitles = const [],
}) {
  String? resolve(String? url) => _resolveUrl(url, instanceBaseUrl);

  final adaptive = resp.adaptiveFormats ?? [];
  final captions = (resp.captions ?? [])
      .map((c) => _invidiousCaption(c, resolve))
      .where((s) => s.url != null)
      .toList();

  return NewPipeWatchResp(
    id: videoId,
    title: resp.title,
    description: resp.description,
    uploaderName: resp.author,
    uploaderUrl: resp.authorUrl ??
        (resp.authorId != null ? '/channel/${resp.authorId}' : null),
    uploaderAvatarUrl: resolve(_largest(resp.authorThumbnails
        ?.map((t) => (url: t.url, width: t.width))
        .toList())),
    uploaderVerified: resp.authorVerified,
    thumbnailUrl: resolve(_invidiousThumbnail(resp)),
    duration: resp.lengthSeconds,
    viewCount: resp.viewCount,
    likeCount: resp.likeCount,
    dislikeCount: resp.dislikeCount,
    uploadDate: resp.published != null
        ? DateTime.fromMillisecondsSinceEpoch(resp.published! * 1000,
                isUtc: true)
            .toIso8601String()
        : null,
    textualUploadDate: resp.publishedText,
    category: resp.genre,
    tags: resp.keywords?.map((k) => k.toString()).toList(),
    isLive: resp.liveNow == true,
    dashMpdUrl: resolve(resp.dashUrl),
    videoStreams: (resp.formatStreams ?? [])
        .map((f) => _invidiousMuxed(f, resolve))
        .toList(),
    videoOnlyStreams: adaptive
        .where((f) => f.type?.startsWith('video/') == true)
        .map((f) => _invidiousVideoOnly(f, resolve))
        .toList(),
    audioStreams: adaptive
        .where((f) => f.type?.startsWith('audio/') == true)
        .map((f) => _invidiousAudio(f, resolve))
        .toList(),
    subtitles: _dedupeSubtitles(
      captions.isNotEmpty ? captions : _explodeSubtitles(extraSubtitles),
    ),
  );
}

/// The Explode watch screen only holds [ExplodeWatchResp], the muxed streams
/// (`WatchState.muxedStreams`), `WatchState.liveStreamUrl` and the VTT
/// subtitle maps. Muxed streams top out at 360p, so pass the full
/// [manifest] (`yt.videos.streamsClient.getManifest(id)`) to unlock
/// video-only + audio merging and audio-track selection; when given, its
/// muxed streams replace [muxedStreams].
///
/// Not available from youtube_explode: uploader avatar/subscriber count,
/// DASH manifest, chapters (description fallback applies).
NewPipeWatchResp newPipeRespFromExplode(
  ExplodeWatchResp video, {
  required String videoId,
  List<MyMuxedStreamInfo> muxedStreams = const [],
  StreamManifest? manifest,
  String? liveUrl,
  List<Map<String, String>> subtitles = const [],
}) {
  final hlsUrl = _httpUrl(liveUrl);

  return NewPipeWatchResp(
    id: videoId,
    title: video.title,
    description: video.description,
    uploaderName: video.author,
    uploaderUrl:
        video.channelId.isNotEmpty ? '/channel/${video.channelId}' : null,
    thumbnailUrl: _httpUrl(video.thumbnailUrl),
    duration: video.duration.inSeconds,
    viewCount: video.viewCount,
    likeCount: video.likeCount,
    dislikeCount: video.dislikeCount,
    uploadDate: video.uploadDate.toIso8601String(),
    isLive: video.isLive || hlsUrl != null,
    hlsUrl: hlsUrl,
    videoStreams: manifest != null
        ? manifest.muxed.map(_explodeMuxed).toList()
        : muxedStreams.map(_explodeMyMuxed).toList(),
    videoOnlyStreams:
        manifest?.videoOnly.map(_explodeVideoOnly).toList() ?? const [],
    audioStreams: manifest?.audioOnly.map(_explodeAudio).toList() ?? const [],
    subtitles: _dedupeSubtitles(_explodeSubtitles(subtitles)),
  );
}

// ---------------------------------------------------------------- Piped

NewPipeVideoStream _pipedVideo(VideoStream s) {
  return NewPipeVideoStream(
    url: s.url,
    resolution: _resolutionLabel(s.quality, s.height),
    format: _videoFormat(s.format ?? s.mimeType),
    mimeType: s.mimeType,
    codec: s.codec,
    quality: s.quality,
    width: s.width,
    height: s.height,
    fps: s.fps,
    isVideoOnly: s.videoOnly == true,
    itag: s.itag,
    initStart: s.initStart,
    initEnd: s.initEnd,
    indexStart: s.indexStart,
    indexEnd: s.indexEnd,
    contentLength: s.contentLength,
    bitrate: s.bitrate,
  );
}

NewPipeAudioStream _pipedAudio(AudioStream s) {
  final xtags = _audioXtags(s.url);
  return NewPipeAudioStream(
    url: s.url,
    averageBitrate: s.bitrate != null ? s.bitrate! ~/ 1000 : null,
    format: _audioFormat(s.format ?? s.mimeType, s.codec),
    mimeType: s.mimeType,
    codec: s.codec,
    quality: s.quality,
    itag: s.itag,
    initStart: s.initStart,
    initEnd: s.initEnd,
    indexStart: s.indexStart,
    indexEnd: s.indexEnd,
    contentLength: s.contentLength,
    bitrate: s.bitrate,
    audioTrackId: _nonEmpty(s.audioTrackId),
    audioTrackName: _nonEmpty(s.audioTrackName),
    audioTrackType: _nonEmpty(s.audioTrackType) ?? xtags.type,
    audioLocale: _nonEmpty(s.audioTrackLocale) ?? xtags.locale,
  );
}

NewPipeSubtitle _pipedSubtitle(Subtitle s) {
  return NewPipeSubtitle(
    url: s.url,
    mimeType: s.mimeType,
    languageCode: s.code,
    autoGenerated: s.autoGenerated,
  );
}

/// Piped chapters are `{title, image, start}` maps (start in seconds).
List<NewPipeChapter>? _pipedChapters(List<dynamic>? chapters) {
  if (chapters == null || chapters.isEmpty) return null;
  return chapters
      .whereType<Map>()
      .map((c) => NewPipeChapter(
            title: c['title']?.toString(),
            startTimeSeconds: (c['start'] as num?)?.toInt(),
            previewUrl: c['image']?.toString(),
          ))
      .toList();
}

// ------------------------------------------------------------ Invidious

NewPipeVideoStream _invidiousMuxed(
  FormatStream f,
  String? Function(String?) resolve,
) {
  final size = _parseSize(f.size ?? f.resolution);
  final mime = _parseMime(f.type);
  return NewPipeVideoStream(
    url: resolve(f.url),
    resolution: _resolutionLabel(f.qualityLabel ?? f.resolution, size?.$2),
    format: _videoFormat(f.container ?? mime.base),
    mimeType: mime.base,
    codec: mime.codecs ?? f.encoding,
    quality: f.qualityLabel ?? f.quality,
    width: size?.$1,
    height: size?.$2,
    fps: f.fps,
    isVideoOnly: false,
    itag: int.tryParse(f.itag ?? ''),
    bitrate: int.tryParse(f.bitrate ?? ''),
  );
}

NewPipeVideoStream _invidiousVideoOnly(
  AdaptiveFormat f,
  String? Function(String?) resolve,
) {
  final size = _parseSize(f.size);
  final mime = _parseMime(f.type);
  final init = _parseRange(f.init);
  final index = _parseRange(f.index);
  return NewPipeVideoStream(
    url: resolve(f.url),
    resolution: _resolutionLabel(f.qualityLabel ?? f.resolution, size?.$2),
    format: _videoFormat(f.container ?? mime.base),
    mimeType: mime.base,
    codec: mime.codecs ?? f.encoding,
    quality: f.qualityLabel,
    width: size?.$1,
    height: size?.$2,
    fps: f.fps,
    isVideoOnly: true,
    itag: int.tryParse(f.itag ?? ''),
    initStart: init?.$1,
    initEnd: init?.$2,
    indexStart: index?.$1,
    indexEnd: index?.$2,
    contentLength: int.tryParse(f.clen ?? ''),
    bitrate: int.tryParse(f.bitrate ?? ''),
  );
}

NewPipeAudioStream _invidiousAudio(
  AdaptiveFormat f,
  String? Function(String?) resolve,
) {
  final mime = _parseMime(f.type);
  final init = _parseRange(f.init);
  final index = _parseRange(f.index);
  final bps = int.tryParse(f.bitrate ?? '');
  final url = resolve(f.url);
  final xtags = _audioXtags(url);
  return NewPipeAudioStream(
    url: url,
    averageBitrate: bps != null ? bps ~/ 1000 : null,
    format: _audioFormat(f.container ?? mime.base, mime.codecs ?? f.encoding),
    mimeType: mime.base,
    codec: mime.codecs ?? f.encoding,
    quality: f.audioQuality ?? (bps != null ? '${bps ~/ 1000}kbps' : null),
    itag: int.tryParse(f.itag ?? ''),
    initStart: init?.$1,
    initEnd: init?.$2,
    indexStart: index?.$1,
    indexEnd: index?.$2,
    contentLength: int.tryParse(f.clen ?? ''),
    bitrate: bps,
    audioChannels: f.audioChannels,
    sampleRate: f.audioSampleRate,
    audioTrackType: xtags.type,
    audioLocale: xtags.locale,
  );
}

/// Invidious `/api/v1/captions/{id}?label=..` serves WebVTT.
NewPipeSubtitle _invidiousCaption(
  Caption c,
  String? Function(String?) resolve,
) {
  return NewPipeSubtitle(
    url: resolve(c.url),
    mimeType: 'text/vtt',
    languageCode: c.languageCode,
    autoGenerated: c.label?.toLowerCase().contains('auto') ?? false,
  );
}

String? _invidiousThumbnail(InvidiousWatchResp resp) {
  final thumbs = resp.videoThumbnails ?? [];
  if (thumbs.isEmpty) return null;
  for (final quality in const [
    'maxres',
    'maxresdefault',
    'sddefault',
    'high'
  ]) {
    final match = thumbs.where((t) => t.quality == quality).firstOrNull;
    if (match?.url != null) return match!.url;
  }
  return _largest(thumbs.map((t) => (url: t.url, width: t.width)).toList());
}

// -------------------------------------------------------------- Explode

NewPipeVideoStream _explodeMyMuxed(MyMuxedStreamInfo s) {
  final size = _parseSize(s.resolution);
  final container = s.container.toLowerCase();
  return NewPipeVideoStream(
    url: s.url,
    resolution: _resolutionLabel(s.quality, size?.$2),
    format: _videoFormat(container),
    mimeType: 'video/$container',
    codec: s.videoCodec,
    quality: s.quality,
    width: size?.$1,
    height: size?.$2,
    fps: s.framerate.framesPerSecond.round(),
    isVideoOnly: false,
    itag: s.itag,
    // youtube_explode's kiloBitsPerSecond divides by 1024.
    bitrate: (s.bitrate * 1024).round(),
  );
}

NewPipeVideoStream _explodeMuxed(MuxedStreamInfo s) {
  return NewPipeVideoStream(
    url: s.url.toString(),
    resolution: _resolutionLabel(s.qualityLabel, s.videoResolution.height),
    format: _videoFormat(s.container.name),
    mimeType: s.codec.mimeType,
    codec: s.videoCodec,
    quality: s.qualityLabel,
    width: s.videoResolution.width,
    height: s.videoResolution.height,
    fps: s.framerate.framesPerSecond.round(),
    isVideoOnly: false,
    itag: s.tag,
    contentLength: s.size.totalBytes,
    bitrate: s.bitrate.bitsPerSecond,
  );
}

NewPipeVideoStream _explodeVideoOnly(VideoOnlyStreamInfo s) {
  return NewPipeVideoStream(
    url: s.url.toString(),
    resolution: _resolutionLabel(s.qualityLabel, s.videoResolution.height),
    format: _videoFormat(s.container.name),
    mimeType: s.codec.mimeType,
    codec: s.videoCodec,
    quality: s.qualityLabel,
    width: s.videoResolution.width,
    height: s.videoResolution.height,
    fps: s.framerate.framesPerSecond.round(),
    isVideoOnly: true,
    itag: s.tag,
    contentLength: s.size.totalBytes,
    bitrate: s.bitrate.bitsPerSecond,
  );
}

NewPipeAudioStream _explodeAudio(AudioOnlyStreamInfo s) {
  final url = s.url.toString();
  final xtags = _audioXtags(url);
  final track = s.audioTrack;
  String? trackType = xtags.type;
  if (trackType == null && track != null) {
    // youtube_explode only flags the default track; its displayName carries
    // "original" for the source language.
    trackType = track.audioIsDefault ||
            track.displayName.toLowerCase().contains('original')
        ? 'ORIGINAL'
        : null;
  }
  return NewPipeAudioStream(
    url: url,
    averageBitrate: s.bitrate.bitsPerSecond ~/ 1000,
    format: _audioFormat(s.container.name, s.audioCodec),
    mimeType: s.codec.mimeType,
    codec: s.audioCodec,
    quality: '${s.bitrate.bitsPerSecond ~/ 1000}kbps',
    itag: s.tag,
    contentLength: s.size.totalBytes,
    bitrate: s.bitrate.bitsPerSecond,
    audioTrackId: track?.id,
    audioTrackName: track?.displayName,
    audioTrackType: trackType,
    audioLocale: xtags.locale ?? track?.id.split('.').first,
  );
}

/// Maps the `{code, name, url}` VTT tracks from `WatchService.getSubtitles`.
List<NewPipeSubtitle> _explodeSubtitles(List<Map<String, String>> maps) {
  return maps
      .where((m) => _httpUrl(m['url']) != null)
      .map((m) => NewPipeSubtitle(
            url: m['url'],
            mimeType: 'text/vtt',
            languageCode: m['code'] ?? m['name']?.split(' - ').first,
            autoGenerated: m['name']?.toLowerCase().contains('auto') ?? false,
          ))
      .toList();
}

// --------------------------------------------------------------- shared

/// The player selects captions by `languageCode` (first match), so a
/// duplicate code (manual + auto "en") would be unreachable; keep the
/// manual track.
List<NewPipeSubtitle> _dedupeSubtitles(List<NewPipeSubtitle> subtitles) {
  final sorted = [
    ...subtitles.where((s) => s.autoGenerated != true),
    ...subtitles.where((s) => s.autoGenerated == true),
  ];
  final seen = <String>{};
  return sorted
      .where((s) => s.url != null && s.url!.isNotEmpty)
      .where((s) => seen.add(s.languageCode ?? ''))
      .toList();
}

String? _httpUrl(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  return trimmed.startsWith('http://') || trimmed.startsWith('https://')
      ? trimmed
      : null;
}

String? _resolveUrl(String? url, String? baseUrl) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('//')) return 'https:$url';
  final absolute = _httpUrl(url);
  if (absolute != null) return absolute;
  if (baseUrl == null || baseUrl.isEmpty) return null;
  return Uri.parse(baseUrl).resolve(url).toString();
}

String? _nonEmpty(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty || text == 'null' ? null : text;
}

String? _largest(List<({String? url, int? width})>? items) {
  final valid = (items ?? []).where((i) => i.url != null).toList();
  if (valid.isEmpty) return null;
  valid.sort((a, b) => (b.width ?? 0).compareTo(a.width ?? 0));
  return valid.first.url;
}

/// "1080p60" / "720p HDR" -> "1080p"; falls back to the pixel height.
String? _resolutionLabel(String? quality, int? height) {
  final match = RegExp(r'(\d{3,4})p').firstMatch(quality ?? '');
  if (match != null) return '${match.group(1)}p';
  if (height != null && height > 0) return '${height}p';
  return quality;
}

/// `NewPipeStreamHelper` ranks video formats by MP4 > WEBM.
String? _videoFormat(String? raw) {
  final value = raw?.toLowerCase() ?? '';
  if (value.contains('mp4') || value.contains('mpeg_4')) return 'MP4';
  if (value.contains('webm')) return 'WEBM';
  if (value.contains('3gp')) return '3GPP';
  return raw?.toUpperCase();
}

/// `NewPipeStreamHelper` ranks audio formats by M4A > OPUS > WEBM.
String? _audioFormat(String? raw, String? codec) {
  final value = raw?.toLowerCase() ?? '';
  final codecValue = codec?.toLowerCase() ?? '';
  if (value.contains('m4a') || value.contains('mp4')) return 'M4A';
  if (value.contains('opus') || codecValue.contains('opus')) return 'OPUS';
  if (value.contains('webm')) return 'WEBM';
  return raw?.toUpperCase();
}

/// `video/mp4; codecs="avc1.4d401f"` -> (base: video/mp4, codecs: avc1.4d401f)
({String? base, String? codecs}) _parseMime(String? type) {
  if (type == null || type.isEmpty) return (base: null, codecs: null);
  final base = type.split(';').first.trim();
  final codecs = RegExp(r'codecs="([^"]+)"').firstMatch(type)?.group(1);
  return (base: base.isEmpty ? null : base, codecs: codecs);
}

(int, int)? _parseSize(String? size) {
  final match = RegExp(r'^(\d+)x(\d+)$').firstMatch(size?.trim() ?? '');
  if (match == null) return null;
  return (int.parse(match.group(1)!), int.parse(match.group(2)!));
}

/// Invidious `init`/`index` byte ranges are "start-end".
(int, int)? _parseRange(String? range) {
  final match = RegExp(r'^(\d+)-(\d+)$').firstMatch(range?.trim() ?? '');
  if (match == null) return null;
  return (int.parse(match.group(1)!), int.parse(match.group(2)!));
}

/// googlevideo audio URLs carry `xtags=acont=dubbed-auto:lang=en-US`; this
/// is the only multi-language signal when the backend omits track metadata.
({String? type, String? locale}) _audioXtags(String? url) {
  if (url == null) return (type: null, locale: null);
  String? xtags;
  try {
    xtags = Uri.tryParse(url)?.queryParameters['xtags'];
  } on FormatException {
    return (type: null, locale: null);
  }
  if (xtags == null || xtags.isEmpty) return (type: null, locale: null);
  final parts = <String, String>{};
  for (final part in xtags.split(':')) {
    final eq = part.indexOf('=');
    if (eq > 0) parts[part.substring(0, eq)] = part.substring(eq + 1);
  }
  final acont = parts['acont']?.toLowerCase();
  final type = acont == null
      ? null
      : acont.startsWith('dubbed')
          ? 'DUBBED'
          : acont.startsWith('descriptive')
              ? 'DESCRIPTIVE'
              : acont.startsWith('original')
                  ? 'ORIGINAL'
                  : null;
  return (type: type, locale: parts['lang']);
}
