import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:fluxtube/domain/channel/models/newpipe/newpipe_channel_resp.dart';
import 'package:fluxtube/domain/search/models/newpipe/newpipe_search_resp.dart';
import 'package:fluxtube/domain/trending/models/newpipe/newpipe_trending_resp.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_comments_resp.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';

/// Platform channel for communicating with NewPipe Extractor on Android.
/// This service is Android-only. On iOS, it returns unavailable.
class NewPipeChannel {
  static const _channel = MethodChannel('com.fazilvk.fluxtube/newpipe');

  // Cache for stream URLs with TTL (5 minutes)
  static final Map<String, _CachedStreamInfo> _streamCache = {};
  static const _cacheTtl = Duration(minutes: 5);

  /// Check if NewPipe Extractor is available on this platform.
  /// Returns true on Android, false on iOS/other platforms.
  static Future<bool> get isAvailable async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Get video stream info including metadata and stream URLs
  static Future<NewPipeWatchResp> getStreamInfo(String videoId) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getStreamInfo',
        {'id': videoId},
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'No data returned from NewPipe Extractor',
        );
      }
      final resp = await _decodeJson(result, NewPipeWatchResp.fromJson);
      // Cache the result
      _streamCache[videoId] = _CachedStreamInfo(resp, DateTime.now());
      return resp;
    } on PlatformException catch (e) {
      throw Exception('Failed to get stream info: ${e.message}');
    }
  }

  /// Get video stream info fast (essential data only - no related videos).
  /// Use this for faster initial playback. Fetches related videos separately.
  /// Falls back to regular getStreamInfo if fast method is not available.
  static Future<NewPipeWatchResp> getStreamInfoFast(String videoId) async {
    // Check cache first
    final cached = _streamCache[videoId];
    if (cached != null && !cached.isExpired(_cacheTtl)) {
      return cached.data;
    }

    try {
      final result = await _channel.invokeMethod<String>(
        'getStreamInfoFast',
        {'id': videoId},
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'No data returned from NewPipe Extractor',
        );
      }
      final resp = await _decodeJson(result, NewPipeWatchResp.fromJson);
      // Cache the result
      _streamCache[videoId] = _CachedStreamInfo(resp, DateTime.now());
      return resp;
    } on MissingPluginException {
      // Fall back to regular getStreamInfo if fast method is not available
      // This can happen if native code hasn't been rebuilt
      return getStreamInfo(videoId);
    } on PlatformException catch (e) {
      throw Exception('Failed to get stream info: ${e.message}');
    }
  }

  /// Get cached stream info if available and not expired
  static NewPipeWatchResp? getCachedStreamInfo(String videoId) {
    final cached = _streamCache[videoId];
    if (cached != null && !cached.isExpired(_cacheTtl)) {
      return cached.data;
    }
    return null;
  }

  /// Pre-fetch stream info for a video (e.g., from thumbnails)
  static Future<void> prefetchStreamInfo(String videoId) async {
    // Check if already cached
    final cached = _streamCache[videoId];
    if (cached != null && !cached.isExpired(_cacheTtl)) {
      return;
    }

    try {
      await getStreamInfoFast(videoId);
    } catch (_) {
      // Silently fail for prefetch - it's just an optimization
    }
  }

  /// Clear expired cache entries
  static void clearExpiredCache() {
    _streamCache.removeWhere((_, cached) => cached.isExpired(_cacheTtl));
  }

  /// Clear all cache
  static void clearCache() {
    _streamCache.clear();
  }

  /// Get trending videos for a specific region.
  ///
  /// [kioskId], when given, picks a specific YouTube kiosk category instead
  /// of the extractor's default one — see [HomeCategory] for the exact ids.
  static Future<List<NewPipeTrendingResp>> getTrending(
    String region, {
    String? kioskId,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getTrending',
        {
          'region': region,
          if (kioskId != null) 'kioskId': kioskId,
        },
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'No data returned from NewPipe Extractor',
        );
      }
      final json = jsonDecode(result) as Map<String, dynamic>;
      final videos = json['videos'] as List<dynamic>?;
      if (videos == null) return [];
      return videos
          .map((v) => NewPipeTrendingResp.fromJson(v as Map<String, dynamic>))
          .toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to get trending: ${e.message}');
    }
  }

  /// Search for videos, channels, or playlists
  static Future<NewPipeSearchResp> search({
    required String query,
    required String filter,
    String? nextPage,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'search',
        {
          'query': query,
          'filter': filter,
          if (nextPage != null) 'nextPage': nextPage,
        },
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'No data returned from NewPipe Extractor',
        );
      }
      return await _decodeJson(result, NewPipeSearchResp.fromJson);
    } on PlatformException catch (e) {
      throw Exception('Failed to search: ${e.message}');
    }
  }

  /// Get search suggestions for autocomplete
  static Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getSearchSuggestions',
        {'query': query},
      );
      if (result == null) return [];
      final json = jsonDecode(result) as List<dynamic>;
      return json.map((s) => s.toString()).toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to get suggestions: ${e.message}');
    }
  }

  /// Get channel info and videos
  static Future<NewPipeChannelResp> getChannel(String channelId) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getChannel',
        {'id': channelId},
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'No data returned from NewPipe Extractor',
        );
      }
      return await _decodeJson(result, NewPipeChannelResp.fromJson);
    } on PlatformException catch (e) {
      throw Exception('Failed to get channel: ${e.message}');
    }
  }

  /// Get comments for a video
  static Future<NewPipeCommentsResp> getComments(String videoId) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getComments',
        {'id': videoId},
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'No data returned from NewPipe Extractor',
        );
      }
      return await _decodeJson(result, NewPipeCommentsResp.fromJson);
    } on PlatformException catch (e) {
      throw Exception('Failed to get comments: ${e.message}');
    }
  }

  /// Get more comments (pagination)
  static Future<NewPipeCommentsResp> getMoreComments({
    required String videoId,
    required String nextPage,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getMoreComments',
        {
          'id': videoId,
          'nextPage': nextPage,
        },
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'No data returned from NewPipe Extractor',
        );
      }
      return await _decodeJson(result, NewPipeCommentsResp.fromJson);
    } on PlatformException catch (e) {
      throw Exception('Failed to get more comments: ${e.message}');
    }
  }

  /// Get comment replies
  static Future<NewPipeCommentsResp> getCommentReplies({
    required String videoId,
    required String repliesPage,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getCommentReplies',
        {
          'id': videoId,
          'repliesPage': repliesPage,
        },
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'No data returned from NewPipe Extractor',
        );
      }
      return await _decodeJson(result, NewPipeCommentsResp.fromJson);
    } on PlatformException catch (e) {
      throw Exception('Failed to get comment replies: ${e.message}');
    }
  }

  /// Get channel tab content (shorts, playlists, etc.) by tab URL
  static Future<NewPipeChannelResp> getChannelTab(
    String tabUrl, {
    String? tabId,
    List<String>? contentFilters,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getChannelTab',
        {
          'url': tabUrl,
          if (tabId != null) 'id': tabId,
          if (contentFilters != null) 'contentFilters': contentFilters,
        },
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'No data returned from NewPipe Extractor',
        );
      }
      return await _decodeJson(result, NewPipeChannelResp.fromJson);
    } on PlatformException catch (e) {
      throw Exception('Failed to get channel tab: ${e.message}');
    }
  }

  /// Get more channel tab content (pagination)
  static Future<NewPipeChannelResp> getChannelTabWithPagination(
    String tabUrl, {
    required String nextPage,
    String? tabId,
    List<String>? contentFilters,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getChannelTab',
        {
          'url': tabUrl,
          if (tabId != null) 'id': tabId,
          if (contentFilters != null) 'contentFilters': contentFilters,
          'nextPage': nextPage,
        },
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'No data returned from NewPipe Extractor',
        );
      }
      return await _decodeJson(result, NewPipeChannelResp.fromJson);
    } on PlatformException catch (e) {
      throw Exception('Failed to get more channel tab content: ${e.message}');
    }
  }
}

/// Cache entry for stream info with timestamp
class _CachedStreamInfo {
  final NewPipeWatchResp data;
  final DateTime timestamp;

  _CachedStreamInfo(this.data, this.timestamp);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

/// Stream/channel/comment payloads can run to hundreds of KB; decoding them on
/// the UI isolate shows up as dropped frames when a screen opens.
Future<T> _decodeJson<T>(
    String raw, T Function(Map<String, dynamic>) fromJson) {
  if (raw.length < 32 * 1024) {
    return Future.value(fromJson(jsonDecode(raw) as Map<String, dynamic>));
  }
  return Isolate.run(() => fromJson(jsonDecode(raw) as Map<String, dynamic>));
}
