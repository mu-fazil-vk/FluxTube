import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:fluxtube/domain/saved/saved_services.dart';
import 'package:fluxtube/infrastructure/settings/setting_impliment.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

@LazySingleton(as: SavedServices)
class SavedImplimentation extends SavedServices {
  Isar isar = SettingImpliment.isar;

// add new video info to local database
  Future<void> _addVideoInformations(LocalStoreVideoInfo videoInfo) async {
    videoInfo.time = DateTime.now();
    await isar.writeTxn(() async {
      await isar.localStoreVideoInfos.put(videoInfo);
    });
  }

// get all stored video infos from local database

  Future<List<LocalStoreVideoInfo>> _getVideoInformations() async {
    return await isar.localStoreVideoInfos.where().findAll();
  }

// delete a video info from local database

  Future<void> _deleteVideoInformations(Id id) async {
    await isar.writeTxn(() async {
      await isar.localStoreVideoInfos.delete(id);
    });
  }

// add video info implement
  @override
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>> addVideoInfo(
      {required LocalStoreVideoInfo videoInfo}) async {
    try {
      await _addVideoInformations(videoInfo);
      List<LocalStoreVideoInfo> videoInfoListAfter =
          await _getVideoInformations();
      return Right(videoInfoListAfter);
    } catch (e) {
      return const Left(MainFailure.clientFailure());
    }
  }

  // delete video info impliment

  @override
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>> deleteVideoInfo(
      {required Id id}) async {
    try {
      await _deleteVideoInformations(id);
      List<LocalStoreVideoInfo> videoInfoList = await _getVideoInformations();
      return Right(videoInfoList);
    } catch (e) {
      return const Left(MainFailure.clientFailure());
    }
  }

  // get all video info list

  @override
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>>
      getVideoInfoList() async {
    try {
      List<LocalStoreVideoInfo> videoInfoList = await _getVideoInformations();
      return Right(videoInfoList);
    } catch (e) {
      return const Left(MainFailure.clientFailure());
    }
  }

  // check the video info is present in the local storage
  @override
  Future<Either<MainFailure, LocalStoreVideoInfo>> checkVideoInfo(
      {required String id}) async {
    try {
      List<LocalStoreVideoInfo> videoInfoList = await _getVideoInformations();
      // Find the video with the specified ID
      LocalStoreVideoInfo foundVideo =
          videoInfoList.firstWhere((video) => video.id == id);

      return Right(foundVideo);
    } catch (e) {
      // Handle the case where the video is not found
      return const Left(MainFailure.clientFailure());
    }
  }
}
