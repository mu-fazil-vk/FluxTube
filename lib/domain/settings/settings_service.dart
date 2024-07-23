import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';

abstract class SettingsService {
  Future<List<Map<String, String>>> initializeSettings();
  Future<Either<MainFailure, String>> selectDefaultLanguage(
      {required String language});
  Future<Either<MainFailure, String>> selectDefaultQuality(
      {required String quality});
  Future<Either<MainFailure, String>> selectRegion({required String region});
  Future<Either<MainFailure, bool>> toggleTheme({required String theme});
  Future<Either<MainFailure, bool>> toggleHistoryVisibility(
      {required bool isHistoryVisible});
  Future<Either<MainFailure, bool>> toggleDislikeVisibility(
      {required bool isDislikeVisible});
  Future<Either<MainFailure, bool>> toggleHlsPlayer(
      {required bool isHlsPlayer});
}
