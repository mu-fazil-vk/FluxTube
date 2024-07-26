import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';

abstract class SettingsService {
  Future<List<Map<String, String>>> initializeSettings();
  Future<Either<MainFailure, String>> selectDefaultLanguage(
      {required String language});
  Future<Either<MainFailure, String>> selectDefaultQuality(
      {required String quality});
  Future<Either<MainFailure, String>> selectRegion({required String region});
  Future<Either<MainFailure, String>> setTheme({required String themeMode});
  Future<Either<MainFailure, bool>> toggleHistoryVisibility(
      {required bool isHistoryVisible});
  Future<Either<MainFailure, bool>> toggleDislikeVisibility(
      {required bool isDislikeVisible});
  Future<Either<MainFailure, bool>> toggleHlsPlayer(
      {required bool isHlsPlayer});
  Future<Either<MainFailure, bool>> toggleHideComments(
      {required bool isHideComments});
  Future<Either<MainFailure, bool>> toggleHideRelatedVideos(
      {required bool isHideRelated});
}
