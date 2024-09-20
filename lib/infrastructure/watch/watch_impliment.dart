import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/watch/models/invidious/comments/invidious_comments_resp.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/domain/watch/models/piped/comments/comments_resp.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/domain/watch/models/piped/video/watch_resp.dart';
import 'package:fluxtube/domain/watch/watch_service.dart';
import 'package:injectable/injectable.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../domain/core/api_end_points.dart';

@LazySingleton(as: WatchService)
class WatchImpliment implements WatchService {
  //Piped

  ///[getVideoData] used to fetch video data from Piped.
  @override
  Future<Either<MainFailure, WatchResp>> getVideoData(
      {required String id}) async {
    final dioClient = Dio();
    try {
      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        ApiEndPoints.watch + id,
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final WatchResp result = WatchResp.fromJson(response.data);

        return Right(result);
      } else {
        log('Err on getVideoData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getVideoData: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      dioClient.close();
    }
  }

  ///[getCommentsData] used to fetch comments data from Piped.
  @override
  Future<Either<MainFailure, CommentsResp>> getCommentsData(
      {required String id}) async {
    final dioClient = Dio();
    try {
      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        ApiEndPoints.comments + id,
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final CommentsResp result = CommentsResp.fromJson(response.data);

        return Right(result);
      } else {
        log('Err on getCommentsData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getCommentsData: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      dioClient.close();
    }
  }

  ///[getCommentRepliesData] used to fetch comment replies data from Piped.
  @override
  Future<Either<MainFailure, CommentsResp>> getCommentRepliesData(
      {required String id, required String repliesPage}) async {
    final dioClient = Dio();
    try {
      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        '${ApiEndPoints.commentReplies}$id/?nextpage=$repliesPage',
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final CommentsResp result = CommentsResp.fromJson(response.data);

        return Right(result);
      } else {
        log('Err on getCommentRepliesData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getCommentRepliesData: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      dioClient.close();
    }
  }

  ///[getMoreCommentsData] used to fetch more comments/replies data from Piped.
  @override
  Future<Either<MainFailure, CommentsResp>> getMoreCommentsData(
      {required String id, String? nextPage}) async {
    final dioClient = Dio();
    try {
      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        '${ApiEndPoints.commentReplies}$id/?nextpage=$nextPage',
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final CommentsResp result = CommentsResp.fromJson(response.data);
        return Right(result);
      } else {
        log('Err on getMoreCommentsData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getMoreCommentsData: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      dioClient.close();
    }
  }

  //Explode

  ///[getSubtitles] used to fetch subtitles data from Explode.
  @override
  Future<Either<MainFailure, List<Map<String, String>>>> getSubtitles(
      {required String id}) async {
    try {
      var yt = YoutubeExplode();
      var manifest = await yt.videos.closedCaptions.getManifest(id);

      // Filter tracks to get only those with type 'vtt'
      var vttTracks = manifest.tracks
          .where((track) => track.format.formatCode == 'vtt')
          .toList();

      // Create a list with code, name, and type
      var vttTrackInfo = vttTracks
          .map((track) => {
                'code': track.language.code,
                'name': track.language.name,
                'url': track.url.toString()
              })
          .toList();

      // Close the YoutubeExplode instance
      yt.close();

      return Right(vttTrackInfo);
    } catch (e) {
      log('Err on getSubtitles: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  ///[getExplodeVideoData] used to fetch video data from Explode.
  @override
  Future<Either<MainFailure, ExplodeWatchResp>> getExplodeVideoData(
      {required String id}) async {
    final YoutubeExplode _youtubeExplode = YoutubeExplode();
    try {
      var video = await _youtubeExplode.videos.get(id);

      final ExplodeWatchResp result = ExplodeWatchResp.fromYoutubeVideo(video);

      return Right(result);
    } catch (e) {
      log('Error fetching video data: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      _youtubeExplode.close(); // Close the YoutubeExplode instance
    }
  }

  ///[getExplodeMuxedStreamData] used to fetch muxed stream data from Explode.
  @override
  Future<Either<MainFailure, List<MyMuxedStreamInfo>>>
      getExplodeMuxedStreamData({required String id}) async {
    final YoutubeExplode _youtubeExplode = YoutubeExplode();
    try {
      var manifest = await _youtubeExplode.videos.streamsClient.getManifest(id);
      List<MyMuxedStreamInfo> muxedStreams = manifest.muxed
          .map((stream) => MyMuxedStreamInfo.fromYoutubeStream(stream))
          .toList();

      return Right(muxedStreams);
    } catch (e) {
      log('Error fetching muxed streams: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      _youtubeExplode.close(); // Close the YoutubeExplode instance
    }
  }

  ///[getExplodeRelatedVideosData] used to fetch related videos data from Explode.
  @override
  Future<Either<MainFailure, List<MyRelatedVideo>>> getExplodeRelatedVideosData(
      {required String id}) async {
    final YoutubeExplode _youtubeExplode = YoutubeExplode();
    try {
      var video = await _youtubeExplode.videos.get(id);
      var relatedVideos = await _youtubeExplode.videos.getRelatedVideos(video);
      List<MyRelatedVideo> relatedVideoList = relatedVideos!
          .map((video) => MyRelatedVideo.fromYoutubeVideo(video))
          .toList();

      return Right(relatedVideoList);
    } catch (e) {
      log('Error fetching related videos: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      _youtubeExplode.close(); // Close the YoutubeExplode instance
    }
  }

  ///[getExplodeLiveStreamUrl] used to fetch live stream url from Explode.
  @override
  Future<Either<MainFailure, String>> getExplodeLiveStreamUrl(
      {required String id}) async {
    final YoutubeExplode _youtubeExplode = YoutubeExplode();
    try {
      var liveStreamUrl = await _youtubeExplode.videos.streamsClient
          .getHttpLiveStreamUrl(VideoId(id));
      return Right(liveStreamUrl);
    } catch (e) {
      log('Error fetching live stream URL: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      _youtubeExplode.close(); // Close the YoutubeExplode instance
    }
  }

  //Invidious

  ///[getInvidiousCommentsData] used to fetch comments data from Invidious.
  @override
  Future<Either<MainFailure, InvidiousCommentsResp>> getInvidiousCommentsData(
      {required String id}) async {
    final dioClient = Dio();
    try {
      log(InvidiousApiEndpoints.comments + id);
      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        InvidiousApiEndpoints.comments + id,
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final InvidiousCommentsResp result =
            InvidiousCommentsResp.fromJson(response.data);

        return Right(result);
      } else {
        log('Err on getInvidiousCommentsData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousCommentsData: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      dioClient.close();
    }
  }

  ///[getInvidiousVideoData] used to fetch video data from Invidious.
  @override
  Future<Either<MainFailure, InvidiousWatchResp>> getInvidiousVideoData(
      {required String id}) async {
    final dioClient = Dio();
    try {
      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        InvidiousApiEndpoints.watch + id,
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final InvidiousWatchResp result =
            InvidiousWatchResp.fromJson(response.data);

        return Right(result);
      } else {
        log('Err on getInvidiousVideoData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousVideoData: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      dioClient.close();
    }
  }

  ///[getInvidiousCommentRepliesData] used to fetch comment replies data from Invidious.
  @override
  Future<Either<MainFailure, InvidiousCommentsResp>>
      getInvidiousCommentRepliesData(
          {required String id, required String continuation}) async {
    final dioClient = Dio();
    try {
      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        '${InvidiousApiEndpoints.comments}$id?continuation=$continuation',
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final InvidiousCommentsResp result =
            InvidiousCommentsResp.fromJson(response.data);

        return Right(result);
      } else {
        log('Err on getInvidiousCommentRepliesData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousCommentRepliesData: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      dioClient.close();
    }
  }

  ///[getInvidiousMoreCommentsData] used to fetch more comments data from Invidious.
  @override
  Future<Either<MainFailure, InvidiousCommentsResp>>
      getInvidiousMoreCommentsData(
          {required String id, required String continuation}) async {
    final dioClient = Dio();
    try {
      dioClient.httpClientAdapter = NativeAdapter();
      final Response response = await dioClient.get(
        '${InvidiousApiEndpoints.comments}$id?continuation=$continuation',
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final InvidiousCommentsResp result =
            InvidiousCommentsResp.fromJson(response.data);

        return Right(result);
      } else {
        log('Err on getInvidiousMoreCommentsData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousMoreCommentsData: $e');
      return const Left(MainFailure.clientFailure());
    } finally {
      dioClient.close();
    }
  }
}
