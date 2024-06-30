import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/trending/models/trending_resp.dart';

abstract class HomeServices {
  Future<Either<MainFailure, List<TrendingResp>>> getHomeFeedData({required List<Subscribe> channels});
}
