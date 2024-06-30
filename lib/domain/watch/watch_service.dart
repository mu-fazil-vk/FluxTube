import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/watch/models/video/watch_resp.dart';

import 'models/comments/comments_resp.dart';

abstract class WatchService {
  Future<Either<MainFailure, WatchResp>> getVideoData({
    required String id,
  });

  Future<Either<MainFailure, CommentsResp>> getCommentsData({
    required String id,
  });

  Future<Either<MainFailure, CommentsResp>> getCommentRepliesData({
    required String id,
    required String repliesPage,
  });
}
