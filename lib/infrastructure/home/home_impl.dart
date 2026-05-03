import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/home/home_services.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/trending/models/newpipe/newpipe_trending_resp.dart';
import 'package:fluxtube/domain/trending/models/piped/trending_resp.dart';
import 'package:fluxtube/infrastructure/newpipe/newpipe_channel.dart';
import 'package:injectable/injectable.dart';

import '../../domain/core/api_end_points.dart';

@LazySingleton(as: HomeServices)
class HomeImpl extends HomeServices {
  @override
  Future<Either<MainFailure, List<TrendingResp>>> getHomeFeedData(
      {required List<Subscribe> channels}) async {
    try {
      final subscribedChannelIds =
          channels.map((channel) => channel.id.toString()).toList();
      final String idsAsString = subscribedChannelIds.join(",");

      final Response response = await ApiClient.dio.get(
        ApiEndPoints.feed + idsAsString,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<TrendingResp> result = (response.data as List)
            .map((e) => TrendingResp.fromJson(e))
            .toList();

        return Right(result);
      } else {
        log('Err on getHomeFeedData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getHomeFeedData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, List<NewPipeTrendingResp>>> getNewPipeHomeFeedData(
      {required List<Subscribe> channels, int videosPerChannel = 10}) async {
    try {
      if (channels.isEmpty) {
        return const Right([]);
      }

      final stopwatch = Stopwatch()..start();
      log('[HomeImpl] Starting parallel fetch for ${channels.length} channels');

      // OPTIMIZATION: Fetch ALL channels in parallel with batching
      // Limit concurrent requests to avoid overwhelming the system
      const int batchSize = 10;
      final List<NewPipeTrendingResp> allVideos = [];

      // Process channels in batches for better performance
      for (int i = 0; i < channels.length; i += batchSize) {
        final batch = channels.skip(i).take(batchSize).toList();

        // Fetch batch in parallel
        final batchResults = await Future.wait(
          batch.map((channel) => _fetchChannelVideos(channel, videosPerChannel)),
          eagerError: false, // Continue even if some fail
        );

        // Collect results from this batch
        for (final videos in batchResults) {
          allVideos.addAll(videos);
        }
      }

      stopwatch.stop();
      log('[HomeImpl] Fetched ${allVideos.length} videos from ${channels.length} channels in ${stopwatch.elapsedMilliseconds}ms');

      // Sort by recency using smart date parsing
      _sortByRecency(allVideos);

      return Right(allVideos);
    } catch (e) {
      log('Err on getNewPipeHomeFeedData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  /// Fetch videos from a single channel - used for parallel execution
  Future<List<NewPipeTrendingResp>> _fetchChannelVideos(
      Subscribe channel, int videosPerChannel) async {
    try {
      final channelInfo = await NewPipeChannel.getChannel(channel.id);
      if (channelInfo.videos == null || channelInfo.videos!.isEmpty) {
        return [];
      }

      return channelInfo.videos!.take(videosPerChannel).map((video) {
        return NewPipeTrendingResp(
          url: video.url,
          name: video.name,
          thumbnailUrl: video.thumbnailUrl,
          type: video.type,
          uploaderName: channelInfo.name ?? channel.channelName,
          uploaderUrl: 'https://www.youtube.com/channel/${channel.id}',
          uploaderAvatarUrl: channelInfo.avatarUrl,
          uploaderVerified: channelInfo.isVerified,
          duration: video.duration,
          viewCount: video.viewCount,
          uploadDate: video.uploadDate,
          isLive: video.isLive,
          isShort: video.isShort,
        );
      }).toList();
    } catch (e) {
      log('Error fetching channel ${channel.id}: $e');
      return []; // Return empty on error, don't block other channels
    }
  }

  /// Sort videos by recency using smart date string parsing
  void _sortByRecency(List<NewPipeTrendingResp> videos) {
    videos.sort((a, b) {
      final aScore = _parseUploadDateToScore(a.uploadDate);
      final bScore = _parseUploadDateToScore(b.uploadDate);
      return bScore.compareTo(aScore); // Higher score = more recent
    });
  }

  /// Parse upload date string to a numeric score for sorting
  /// Higher score = more recent
  int _parseUploadDateToScore(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 0;

    final lower = dateStr.toLowerCase();

    // Live streams get highest priority
    if (lower.contains('streaming') || lower.contains('live')) return 100000;

    // Parse relative time strings
    final numMatch = RegExp(r'(\d+)').firstMatch(lower);
    final num = numMatch != null ? int.tryParse(numMatch.group(1)!) ?? 1 : 1;

    if (lower.contains('second')) return 99999 - num;
    if (lower.contains('minute')) return 90000 - num;
    if (lower.contains('hour')) return 80000 - num;
    if (lower.contains('day')) return 70000 - num;
    if (lower.contains('week')) return 60000 - (num * 7);
    if (lower.contains('month')) return 50000 - (num * 30);
    if (lower.contains('year')) return 40000 - (num * 365);

    // Unknown format
    return 0;
  }
}
