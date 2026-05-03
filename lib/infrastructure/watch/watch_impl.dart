import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/watch/models/invidious/comments/invidious_comments_resp.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_watch_resp.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_comments_resp.dart';
import 'package:fluxtube/domain/watch/models/piped/comments/comments_resp.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/domain/watch/models/piped/video/watch_resp.dart';
import 'package:fluxtube/domain/watch/watch_service.dart';
import 'package:fluxtube/infrastructure/newpipe/newpipe_channel.dart';
import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../domain/core/api_end_points.dart';

@LazySingleton(as: WatchService)
class WatchImpl implements WatchService {
  MainFailure _mapDioExceptionToFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return MainFailure.timeout(message: e.message);
      case DioExceptionType.connectionError:
        return MainFailure.networkError(message: e.message);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) return const MainFailure.notFound();
        if (statusCode == 429) return const MainFailure.rateLimited();
        return MainFailure.serverError(statusCode: statusCode, message: e.message);
      case DioExceptionType.cancel:
        return MainFailure.unknown(message: 'Request cancelled');
      default:
        return MainFailure.unknown(message: e.message);
    }
  }

  //Piped

  @override
  Future<Either<MainFailure, WatchResp>> getVideoData(
      {required String id}) async {
    log(ApiEndPoints.watch + id);
    try {
      final Response response = await ApiClient.dio.get(ApiEndPoints.watch + id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(WatchResp.fromJson(response.data));
      } else if (response.statusCode == 404) {
        log('Video not found: $id');
        return Left(MainFailure.notFound(resource: 'video $id'));
      } else if (response.statusCode == 429) {
        log('Rate limited on getVideoData');
        return const Left(MainFailure.rateLimited());
      } else {
        log('Err on getVideoData: ${response.statusCode}');
        return Left(MainFailure.serverError(
            statusCode: response.statusCode, message: 'Failed to load video'));
      }
    } on DioException catch (e) {
      log('Err on getVideoData: $e');
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      log('Err on getVideoData: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, CommentsResp>> getCommentsData(
      {required String id}) async {
    try {
      final Response response =
          await ApiClient.dio.get(ApiEndPoints.comments + id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(CommentsResp.fromJson(response.data));
      } else {
        log('Err on getCommentsData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getCommentsData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, CommentsResp>> getCommentRepliesData(
      {required String id, required String repliesPage}) async {
    try {
      final Response response = await ApiClient.dio
          .get('${ApiEndPoints.commentReplies}$id/?nextpage=$repliesPage');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(CommentsResp.fromJson(response.data));
      } else {
        log('Err on getCommentRepliesData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getCommentRepliesData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, CommentsResp>> getMoreCommentsData(
      {required String id, String? nextPage}) async {
    try {
      final Response response = await ApiClient.dio
          .get('${ApiEndPoints.commentReplies}$id/?nextpage=$nextPage');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(CommentsResp.fromJson(response.data));
      } else {
        log('Err on getMoreCommentsData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getMoreCommentsData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  //Explode

  @override
  Future<Either<MainFailure, List<Map<String, String>>>> getSubtitles(
      {required String id}) async {
    try {
      var yt = YoutubeExplode();
      var manifest = await yt.videos.closedCaptions.getManifest(id);
      var vttTracks = manifest.tracks
          .where((track) => track.format.formatCode == 'vtt')
          .toList();
      var vttTrackInfo = vttTracks
          .map((track) => {
                'code': track.language.code,
                'name': track.language.name,
                'url': track.url.toString()
              })
          .toList();
      yt.close();
      return Right(vttTrackInfo);
    } catch (e) {
      log('Err on getSubtitles: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, ExplodeWatchResp>> getExplodeVideoData(
      {required String id}) async {
    final YoutubeExplode youtubeExplode = YoutubeExplode();
    try {
      var video = await youtubeExplode.videos.get(id);
      return Right(ExplodeWatchResp.fromYoutubeVideo(video));
    } catch (e) {
      log('Error fetching video data: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      youtubeExplode.close();
    }
  }

  @override
  Future<Either<MainFailure, List<MyMuxedStreamInfo>>>
      getExplodeMuxedStreamData({required String id}) async {
    final YoutubeExplode youtubeExplode = YoutubeExplode();
    try {
      var manifest =
          await youtubeExplode.videos.streamsClient.getManifest(id);
      List<MyMuxedStreamInfo> muxedStreams = manifest.muxed
          .map((stream) => MyMuxedStreamInfo.fromYoutubeStream(stream))
          .toList();
      return Right(muxedStreams);
    } catch (e) {
      log('Error fetching muxed streams: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      youtubeExplode.close();
    }
  }

  @override
  Future<Either<MainFailure, List<MyRelatedVideo>>> getExplodeRelatedVideosData(
      {required String id}) async {
    final YoutubeExplode youtubeExplode = YoutubeExplode();
    try {
      var video = await youtubeExplode.videos.get(id);
      var relatedVideos = await youtubeExplode.videos.getRelatedVideos(video);
      List<MyRelatedVideo> relatedVideoList = (relatedVideos ?? [])
          .map((video) => MyRelatedVideo.fromYoutubeVideo(video))
          .toList();
      return Right(relatedVideoList);
    } catch (e) {
      log('Error fetching related videos: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      youtubeExplode.close();
    }
  }

  @override
  Future<Either<MainFailure, String>> getExplodeLiveStreamUrl(
      {required String id}) async {
    final YoutubeExplode youtubeExplode = YoutubeExplode();
    try {
      var liveStreamUrl = await youtubeExplode.videos.streamsClient
          .getHttpLiveStreamUrl(VideoId(id));
      return Right(liveStreamUrl);
    } catch (e) {
      log('Error fetching live stream URL: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      youtubeExplode.close();
    }
  }

  //Invidious

  @override
  Future<Either<MainFailure, InvidiousCommentsResp>> getInvidiousCommentsData(
      {required String id}) async {
    try {
      log(InvidiousApiEndpoints.comments + id);
      final Response response =
          await ApiClient.dio.get(InvidiousApiEndpoints.comments + id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(InvidiousCommentsResp.fromJson(response.data));
      } else {
        log('Err on getInvidiousCommentsData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousCommentsData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, InvidiousWatchResp>> getInvidiousVideoData(
      {required String id}) async {
    try {
      log(InvidiousApiEndpoints.watch + id);
      final Response response =
          await ApiClient.dio.get(InvidiousApiEndpoints.watch + id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(InvidiousWatchResp.fromJson(response.data));
      } else if (response.statusCode == 404) {
        log('Video not found: $id');
        return Left(MainFailure.notFound(resource: 'video $id'));
      } else if (response.statusCode == 429) {
        log('Rate limited on getInvidiousVideoData');
        return const Left(MainFailure.rateLimited());
      } else {
        log('Err on getInvidiousVideoData: ${response.statusCode}');
        return Left(MainFailure.serverError(
            statusCode: response.statusCode, message: 'Failed to load video'));
      }
    } on DioException catch (e) {
      log('Err on getInvidiousVideoData: $e');
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      log('Err on getInvidiousVideoData: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, InvidiousCommentsResp>>
      getInvidiousCommentRepliesData(
          {required String id, required String continuation}) async {
    try {
      final Response response = await ApiClient.dio
          .get('${InvidiousApiEndpoints.comments}$id?continuation=$continuation');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(InvidiousCommentsResp.fromJson(response.data));
      } else {
        log('Err on getInvidiousCommentRepliesData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousCommentRepliesData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, InvidiousCommentsResp>>
      getInvidiousMoreCommentsData(
          {required String id, required String continuation}) async {
    try {
      final Response response = await ApiClient.dio
          .get('${InvidiousApiEndpoints.comments}$id?continuation=$continuation');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(InvidiousCommentsResp.fromJson(response.data));
      } else {
        log('Err on getInvidiousMoreCommentsData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousMoreCommentsData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  //NewPipe

  @override
  Future<Either<MainFailure, NewPipeWatchResp>> getNewPipeVideoData(
      {required String id}) async {
    try {
      log('NewPipe: Getting video data for $id');
      final result = await NewPipeChannel.getStreamInfo(id);
      return Right(result);
    } catch (e) {
      log('Err on getNewPipeVideoData: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, NewPipeWatchResp>> getNewPipeVideoDataFast(
      {required String id}) async {
    try {
      log('NewPipe: Getting fast video data for $id');
      final result = await NewPipeChannel.getStreamInfoFast(id);
      return Right(result);
    } catch (e) {
      log('Err on getNewPipeVideoDataFast: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, NewPipeCommentsResp>> getNewPipeCommentsData(
      {required String id}) async {
    try {
      log('NewPipe: Getting comments for $id');
      final result = await NewPipeChannel.getComments(id);
      return Right(result);
    } catch (e) {
      log('Err on getNewPipeCommentsData: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, NewPipeCommentsResp>> getNewPipeMoreCommentsData(
      {required String id, required String nextPage}) async {
    try {
      log('NewPipe: Getting more comments for $id');
      final result = await NewPipeChannel.getMoreComments(
        videoId: id,
        nextPage: nextPage,
      );
      return Right(result);
    } catch (e) {
      log('Err on getNewPipeMoreCommentsData: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, NewPipeCommentsResp>> getNewPipeCommentRepliesData(
      {required String videoId, required String repliesPage}) async {
    try {
      log('NewPipe: Getting comment replies for $videoId');
      final result = await NewPipeChannel.getCommentReplies(
        videoId: videoId,
        repliesPage: repliesPage,
      );
      return Right(result);
    } catch (e) {
      log('Err on getNewPipeCommentRepliesData: $e');
      return Left(MainFailure.unknown(message: e.toString()));
    }
  }
}
