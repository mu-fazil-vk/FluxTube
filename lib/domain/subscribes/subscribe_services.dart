import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:isar/isar.dart';

abstract class SubscribeServices {
  Future<Either<MainFailure, List<Subscribe>>> addSubscriberInfo(
      {required Subscribe subscribeInfo});
  Future<Either<MainFailure, List<Subscribe>>> getSubscriberInfoList();
  Future<Either<MainFailure, List<Subscribe>>> deleteSubscriberInfo(
      {required Id id});
  Future<Either<MainFailure, Subscribe>> checkSubscriberInfo(
      {required String id});
}
