import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/watch/models/explode/explode_watch.dart';
import 'package:fluxtube/domain/watch/models/invidious/comments/invidious_comments_resp.dart';
import 'package:fluxtube/domain/watch/models/invidious/video/invidious_watch_resp.dart';
import 'package:fluxtube/domain/watch/models/piped/video/watch_resp.dart';

import 'models/piped/comments/comments_resp.dart';

abstract class WatchService {
  //Piped

  ///[getVideoData] used to fetch video data from Piped.
  Future<Either<MainFailure, WatchResp>> getVideoData({
    required String id,
  });

  ///[getCommentsData] used to fetch comments data from Piped.
  Future<Either<MainFailure, CommentsResp>> getCommentsData({
    required String id,
  });

  ///[getCommentRepliesData] used to fetch comment replies data from Piped.
  Future<Either<MainFailure, CommentsResp>> getCommentRepliesData({
    required String id,
    required String repliesPage,
  });

  ///[getMoreCommentsData] used to fetch more comments data from Piped.
  Future<Either<MainFailure, CommentsResp>> getMoreCommentsData({
    required String id,
    required String? nextPage,
  });

  ///[getSubtitles] used to fetch subtitles data from Piped.
  Future<Either<MainFailure, List<Map<String, String>>>> getSubtitles({
    required String id,
  });

  //Explode

  ///[getExplodeVideoData] used to fetch video data from Explode.
  Future<Either<MainFailure, ExplodeWatchResp>> getExplodeVideoData({
    required String id,
  });

  ///[getExplodeRelatedVideosData] used to fetch related videos data from Explode.
  Future<Either<MainFailure, List<MyRelatedVideo>>>
      getExplodeRelatedVideosData({
    required String id,
  });

  ///[getExplodeMuxedStreamData] used to fetch muxed stream data from Explode.
  Future<Either<MainFailure, List<MyMuxedStreamInfo>>>
      getExplodeMuxedStreamData({
    required String id,
  });

  ///[getExplodeLiveStreamUrl] used to fetch live stream url from Explode.
  Future<Either<MainFailure, String>> getExplodeLiveStreamUrl({
    required String id,
  });

  //Invidious

  ///[getInvidiousVideoData] used to fetch video data from Invidious.
  Future<Either<MainFailure, InvidiousWatchResp>> getInvidiousVideoData({
    required String id,
  });

  ///[getInvidiousCommentsData] used to fetch comments data from Invidious.
  Future<Either<MainFailure, InvidiousCommentsResp>> getInvidiousCommentsData({
    required String id,
  });

  ///[getInvidiousCommentRepliesData] used to fetch comment replies data from Invidious.
  Future<Either<MainFailure, InvidiousCommentsResp>> getInvidiousCommentRepliesData({
    required String id,
    required String continuation,
  });

  ///[getInvidiousMoreCommentsData] used to fetch more comments data from Invidious.
  ///[continuation] is the next page token.
  Future<Either<MainFailure, InvidiousCommentsResp>> getInvidiousMoreCommentsData({
    required String id,
    required String continuation,
  });
}
