
import 'package:dartz/dartz.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/subscribes/models/subscribe.dart';
import 'package:fluxtube/domain/subscribes/subscribe_services.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

import '../settings/setting_impliment.dart';

@LazySingleton(as: SubscribeServices)
class SubscribeImpliment extends SubscribeServices {
  Isar isar = SettingImpliment.isar;

  // add new channel info to local database
  Future<void> _addSubscribeInformations(Subscribe subscribeInfo) async {
    await isar.writeTxn(() async {
      await isar.subscribes.put(subscribeInfo);
    });
  }

  // get all stored video infos from local database

  Future<List<Subscribe>> _getSubscribeInformations() async {
    return await isar.subscribes.where().findAll();
  }

// delete a video info from local database

  Future<void> _deleteSubscribeInformations(Id id) async {
    await isar.writeTxn(() async {
      await isar.subscribes.delete(id);
    });
  }

  // add subscribe implement
  @override
  Future<Either<MainFailure, List<Subscribe>>> addSubscriberInfo(
      {required Subscribe subscribeInfo}) async {
    await _addSubscribeInformations(subscribeInfo);
    List<Subscribe> subscribeListAfter = await _getSubscribeInformations();
    if (subscribeListAfter.isNotEmpty) {
      return Right(subscribeListAfter);
    } else {
      return const Left(MainFailure.clientFailure());
    }
  }

  // delete subscriber info impliment
  @override
  Future<Either<MainFailure, List<Subscribe>>> deleteSubscriberInfo(
      {required Id id}) async {
    await _deleteSubscribeInformations(id);
    List<Subscribe> subscribeListAfter = await _getSubscribeInformations();
    if (subscribeListAfter.isNotEmpty) {
      return Right(subscribeListAfter);
    } else {
      return const Left(MainFailure.clientFailure());
    }
  }

  // get all subscribed channel list
  @override
  Future<Either<MainFailure, List<Subscribe>>> getSubscriberInfoList() async {
    List<Subscribe> subscribesList = await _getSubscribeInformations();
    if (subscribesList.isNotEmpty) {
      return Right(subscribesList);
    } else {
      return const Left(MainFailure.clientFailure());
    }
  }

  // check the channel is present in the local storage
  @override
  Future<Either<MainFailure, Subscribe>> checkSubscriberInfo(
      {required String id}) async {
    List<Subscribe> subscribesList = await _getSubscribeInformations();
    if (subscribesList.isNotEmpty) {
      try {
        // Find the video with the specified ID
        Subscribe foundChannel =
            subscribesList.firstWhere((channel) => channel.id == id);

        return Right(foundChannel);
      } catch (e) {
        // Handle the case where the video is not found
        return const Left(MainFailure.clientFailure());
      }
    } else {
      return const Left(MainFailure.clientFailure());
    }
  }
}
