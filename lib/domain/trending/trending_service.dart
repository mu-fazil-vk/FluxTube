import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/trending/models/trending_resp.dart';

abstract class TrendingService {
  Future<Either<MainFailure, List<TrendingResp>>> getTrendingData(
      {required String region});
}
