enum YouTubeServices {
  newpipe, // Primary service - direct extraction via NewPipe Extractor (Android only)
  piped,
  explode,
  invidious,
}

/// Providers no longer offered in the service picker (checked 2026-10-02).
/// Root cause for both: YouTube's 2024-26 anti-bot changes (PoToken, SABR,
/// datacenter-IP blocking).
/// - piped: server-side; instances run on datacenter IPs YouTube blocks.
///   14/15 public APIs dead, the last one serves only 401 mirror media.
///   Upstream is active but moving to rustypipe (too young to depend on).
///   Maintained server-side alternative: Invidious (+ invidious-companion).
/// - explode: youtube_explode_dart has had no release or merge since
///   2026-05; adaptive streams 403 (only 360p muxed plays). NewPipe
///   Extractor fills the same on-device role and is actively maintained.
/// Their code paths stay in place; users still on them are moved over.
const removedYouTubeServices = {YouTubeServices.piped, YouTubeServices.explode};

enum ApiStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Home feed display mode
enum HomeFeedMode {
  /// Show subscription feed if available, otherwise trending
  feedOrTrending,
  /// Always show subscription feed only (empty if no subscriptions)
  feedOnly,
  /// Always show trending videos only
  trendingOnly,
}
