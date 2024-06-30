import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/saved/models/local_store.dart';
import 'package:isar/isar.dart';

abstract class SavedServices {
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>> addVideoInfo({required LocalStoreVideoInfo videoInfo});
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>> getVideoInfoList();
  Future<Either<MainFailure, List<LocalStoreVideoInfo>>> deleteVideoInfo({required Id id});
  Future<Either<MainFailure, LocalStoreVideoInfo>> checkVideoInfo({required String id});
}
