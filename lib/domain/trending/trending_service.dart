import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/trending/models/invidious/invidious_trending_resp.dart';
import 'package:fluxtube/domain/trending/models/piped/trending_resp.dart';

abstract class TrendingService {
  ///[getTrendingData] used to fetch Trending data from Piped.
  Future<Either<MainFailure, List<TrendingResp>>> getTrendingData(
      {required String region});

  ///[getInvidiousTrendingData] used to fetch Trending data from Invidious.
  Future<Either<MainFailure, List<InvidiousTrendingResp>>>
      getInvidiousTrendingData({required String region});
}
