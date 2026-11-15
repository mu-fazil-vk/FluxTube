import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';

abstract class SavedServices {
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>> addVideoInfo(
      {required LocalStoreVideoInfo videoInfo, String profileName = 'default'});
  /// Writes a single row without re-reading the whole table.
  Future<Either<MainFailure, LocalStoreVideoInfo>> upsertVideoInfo(
      {required LocalStoreVideoInfo videoInfo, String profileName = 'default'});
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>> getVideoInfoList(
      {String profileName = 'default'});
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>> deleteVideoInfo(
      {required String id, String profileName = 'default'});
  Future<Either<MainFailure, LocalStoreVideoInfo>> checkVideoInfo(
      {required String id, String profileName = 'default'});
}
