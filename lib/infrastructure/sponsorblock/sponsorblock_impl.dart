import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/sponsorblock/models/sponsor_segment.dart';
import 'package:fluxtube/domain/sponsorblock/sponsorblock_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SponsorBlockService)
class SponsorBlockImpl implements SponsorBlockService {
  static const String _baseUrl = 'https://sponsor.ajay.app/api';
  static const int _maxCacheEntries = 64;
  static const Duration _cacheTtl = Duration(minutes: 30);

  final _cache = <String, (DateTime, List<SponsorSegment>)>{};
  final _inFlight =
      <String, Future<Either<MainFailure, List<SponsorSegment>>>>{};

  @override
  Future<Either<MainFailure, List<SponsorSegment>>> getSegments({
    required String videoId,
    required List<String> categories,
  }) {
    final key = '$videoId|${(List.of(categories)..sort()).join(',')}';
    final cached = _cache.remove(key);
    if (cached != null && DateTime.now().difference(cached.$1) < _cacheTtl) {
      _cache[key] = cached; // re-insert to mark as most recently used
      return Future.value(Right(cached.$2));
    }
    return _inFlight[key] ??= _fetchSegments(videoId, categories).then((r) {
      _inFlight.remove(key);
      r.fold((_) {}, (segments) {
        _cache[key] = (DateTime.now(), segments);
        if (_cache.length > _maxCacheEntries) _cache.remove(_cache.keys.first);
      });
      return r;
    });
  }

  Future<Either<MainFailure, List<SponsorSegment>>> _fetchSegments(
      String videoId, List<String> categories) async {
    try {
      if (categories.isEmpty) {
        return const Right([]);
      }

      // Build categories query parameter
      final categoriesJson = jsonEncode(categories);

      final Response response = await ApiClient.dio.get(
        '$_baseUrl/skipSegments',
        queryParameters: {
          'videoID': videoId,
          'categories': categoriesJson,
        },
        options: Options(
          // SponsorBlock can be slow on cold cache — give it a bit more.
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final segments = data
            .map((json) => SponsorSegment.fromJson(json as Map<String, dynamic>))
            .where((segment) => segment.actionType == 'skip')
            .toList();

        // Sort segments by start time
        segments.sort((a, b) => a.startTime.compareTo(b.startTime));

        log('[SponsorBlock] Found ${segments.length} segments for video $videoId');
        for (final segment in segments) {
          log('[SponsorBlock] $segment');
        }

        return Right(segments);
      } else if (response.statusCode == 404) {
        // No segments found for this video - this is not an error
        log('[SponsorBlock] No segments found for video $videoId');
        return const Right([]);
      } else {
        log('[SponsorBlock] Error fetching segments: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } on DioException catch (e) {
      // Dio rejects non-2xx by default; 404 means the video has no segments.
      if (e.response?.statusCode == 404) return const Right([]);
      log('[SponsorBlock] Error: $e');
      return const Left(MainFailure.clientFailure());
    } catch (e) {
      log('[SponsorBlock] Error: $e');
      return const Left(MainFailure.clientFailure());
    }
  }
}
