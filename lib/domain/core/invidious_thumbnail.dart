final _instanceThumbPath = RegExp(r'^(?:https?://[^/]+)?/vi/([^/]+)/([^/?]+)');

/// Invidious instances proxy thumbnails through `/vi/...`. Their image proxy
/// is often seconds-slow or failing (all thumbnails blank on the 2026-10-02
/// test instance) while playback already talks to googlevideo directly, so
/// load the same image from YouTube's CDN. `maxres` is Invidious's alias for
/// a size many videos lack; `hqdefault` exists for every video.
String? directYouTubeThumbnail(String? url) {
  if (url == null) return null;
  final match = _instanceThumbPath.firstMatch(url);
  if (match == null) return url;
  var name = match.group(2)!;
  if (name.startsWith('maxres')) name = 'hqdefault.jpg';
  return 'https://i.ytimg.com/vi/${match.group(1)}/$name';
}
