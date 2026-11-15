import 'package:dio/dio.dart';
import 'package:fluxtube/core/api_client.dart';

/// Dislike counts from the Return YouTube Dislike API, since YouTube itself no
/// longer exposes them. Futures are memoised per video so rebuilding widgets
/// can hand the same future to a FutureBuilder without refetching.
class RydService {
  RydService._();
  static final RydService instance = RydService._();

  static const _maxEntries = 100;
  final _futures = <String, Future<int?>>{};

  Future<int?> dislikes(String videoId) {
    final existing = _futures.remove(videoId);
    if (existing != null) {
      _futures[videoId] = existing;
      return existing;
    }
    final future = _fetch(videoId);
    _futures[videoId] = future;
    if (_futures.length > _maxEntries) _futures.remove(_futures.keys.first);
    return future;
  }

  Future<int?> _fetch(String videoId) async {
    try {
      final response = await ApiClient.dio.get(
        'https://returnyoutubedislikeapi.com/votes',
        queryParameters: {'videoId': videoId},
        options: Options(receiveTimeout: const Duration(seconds: 6)),
      );
      final data = response.data;
      if (data is Map && data['dislikes'] is num) {
        return (data['dislikes'] as num).toInt();
      }
    } catch (_) {
      // Let a later rebuild retry instead of caching the failure.
      _futures.remove(videoId);
    }
    return null;
  }
}
