import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/saved/saved_services.dart';
import 'package:fluxtube/infrastructure/database/database.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SavedServices)
class SavedImpl extends SavedServices {
  AppDatabase get db => AppDatabase.instance;

  // Convert Drift LocalStoreVideo to domain LocalStoreVideoInfo
  LocalStoreVideoInfo _toDomain(LocalStoreVideo video) {
    return LocalStoreVideoInfo(
      id: video.videoId,
      title: video.title,
      views: video.views,
      thumbnail: video.thumbnail,
      uploadedDate: video.uploadedDate,
      uploaderName: video.uploaderName,
      uploaderId: video.uploaderId,
      uploaderAvatar: video.uploaderAvatar,
      uploaderSubscriberCount: video.uploaderSubscriberCount,
      duration: video.duration,
      uploaderVerified: video.uploaderVerified,
      isSaved: video.isSaved,
      isHistory: video.isHistory,
      isLive: video.isLive,
      playbackPosition: video.playbackPosition,
      time: video.time,
      profileName: video.profileName,
    );
  }

  // Convert domain LocalStoreVideoInfo to Drift companion
  LocalStoreVideosCompanion _toCompanion(LocalStoreVideoInfo videoInfo) {
    return LocalStoreVideosCompanion.insert(
      videoId: videoInfo.id,
      profileName: videoInfo.profileName,
      title: Value(videoInfo.title),
      views: Value(videoInfo.views),
      thumbnail: Value(videoInfo.thumbnail),
      uploadedDate: Value(videoInfo.uploadedDate),
      uploaderName: Value(videoInfo.uploaderName),
      uploaderId: Value(videoInfo.uploaderId),
      uploaderAvatar: Value(videoInfo.uploaderAvatar),
      uploaderSubscriberCount: Value(videoInfo.uploaderSubscriberCount),
      duration: Value(videoInfo.duration),
      uploaderVerified: Value(videoInfo.uploaderVerified ?? false),
      isSaved: Value(videoInfo.isSaved ?? false),
      isHistory: Value(videoInfo.isHistory ?? false),
      isLive: Value(videoInfo.isLive ?? false),
      playbackPosition: Value(videoInfo.playbackPosition),
      time: Value(videoInfo.time ?? DateTime.now()),
    );
  }

  // get all stored video infos for a specific profile
  Future<List<LocalStoreVideoInfo>> _getVideoInformations(String profileName) async {
    final videos = await db.getAllVideos(profileName);
    return videos.map(_toDomain).toList();
  }

  // add video info implement
  @override
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>> addVideoInfo(
      {required LocalStoreVideoInfo videoInfo, String profileName = 'default'}) async {
    try {
      // Ensure profileName is set
      videoInfo.profileName = profileName;
      videoInfo.time = DateTime.now();
      await db.upsertVideo(_toCompanion(videoInfo));
      List<LocalStoreVideoInfo> videoInfoListAfter =
          await _getVideoInformations(profileName);
      return Right(videoInfoListAfter);
    } catch (e) {
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, LocalStoreVideoInfo>> upsertVideoInfo(
      {required LocalStoreVideoInfo videoInfo,
      String profileName = 'default'}) async {
    try {
      videoInfo.profileName = profileName;
      videoInfo.time = DateTime.now();
      await db.upsertVideo(_toCompanion(videoInfo));
      return Right(videoInfo);
    } catch (e) {
      return const Left(MainFailure.clientFailure());
    }
  }

  // delete video info
  @override
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>> deleteVideoInfo(
      {required String id, String profileName = 'default'}) async {
    try {
      await db.deleteVideo(id, profileName);
      List<LocalStoreVideoInfo> videoInfoList = await _getVideoInformations(profileName);
      return Right(videoInfoList);
    } catch (e) {
      return const Left(MainFailure.clientFailure());
    }
  }

  // get all video info list for a profile
  @override
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>>
      getVideoInfoList({String profileName = 'default'}) async {
    try {
      List<LocalStoreVideoInfo> videoInfoList = await _getVideoInformations(profileName);
      return Right(videoInfoList);
    } catch (e) {
      return const Left(MainFailure.clientFailure());
    }
  }

  // check the video info is present in the local storage for a profile
  @override
  Future<Either<MainFailure, LocalStoreVideoInfo>> checkVideoInfo(
      {required String id, String profileName = 'default'}) async {
    try {
      final video = await db.getVideoById(id, profileName);
      if (video == null) {
        return const Left(MainFailure.clientFailure());
      }
      return Right(_toDomain(video));
    } catch (e) {
      // Handle the case where the video is not found
      return const Left(MainFailure.clientFailure());
    }
  }
}
